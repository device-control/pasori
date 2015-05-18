# coding: utf-8
require 'pasori_api'
require 'station_info'
require 'rail_data'

class PasoriReader
  SERVICE_SUICA_HISTORY = 0x090f
  
  def initialize
    # ここで本当のデバイスの初期化や接続処理を行う
    @pasori_ptr = nil
    
    @station_info = StationInfo.new
    @rail_data = RailData.new
  end
  
  def set_data(data)
    # 特になにもしない
  end
  
  def clear_data
    # 特になにもしない
  end
  
  def read
    pasori_history = nil
    @history = Array.new
    @idm_pmm = Hash.new
    pasori_connect
    pasori_base_read
    pasori_history_read
    pasori_history = create_history_json
  rescue => ex
    puts "ERROR: #{ex.message}".encode('cp932')
  ensure
    pasori_disconnect
    return pasori_history
  end
  
  def read_init
    @pasori_ptr = PasoriAPI::pasori_open(0)
  end
  
  def read_finish
    if !@pasori_ptr.nil?
      PasoriAPI::pasori_close(@pasori_ptr)
      @pasori_ptr = nil
    end
  end
  
  def write(body)
    # dummy...
    sleep(5)
    return 
  end
  
  def pasori_connect
    # pasori 接続
    pasori_res = PasoriAPI::pasori_init(@pasori_ptr)
    if pasori_res == 0
      return # 成功
    end
    raise "Pasoriを接続してください"
  end
  
  def pasori_base_read
    # ベース読み込み
    @base_ptr = PasoriAPI::felica_polling(@pasori_ptr, PasoriAPI::POLLING_ANY, 0, 0)
    if !@base_ptr.null?
      base = PasoriAPI::Felica.new(@base_ptr)
      @idm_pmm[:idm] = base.IDm
      @idm_pmm[:pmm] = base.PMm
      puts "IDm[#{base.IDm}]"
      puts "PMm[#{base.PMm}]"
      return
    end
    raise "ＩＣカードをかざしてください"
  end
  
  # 入出金履歴取得
  def pasori_history_read
    index = 0
    data = ' ' * 16
    while 0 == PasoriAPI::felica_read_without_encryption02(@base_ptr, SERVICE_SUICA_HISTORY, 0, index, data) do
      da = data.unpack('C*')
      p = Hash.new
      # バイナリデータ
      p[:binary] = da.collect{|d| "%02X" % d}.join
      
      # 0: 端末種
      p[:ctype] = da[0]
      # 1: 処理
      p[:proc] = da[1]
      # 2-3: ??
      p[:dummy] = PasoriAPI::get2byte(da,2)
      # 4-5: 日付 (先頭から7ビットが年、４ビットが月、残り５ビットが日)
      p[:date] = PasoriAPI::get2byte(da,4)
      # 6: 入線区
      p[:in_line] = da[6]
      # 7: 入駅順
      p[:in_sta] = da[7]
      # 8: 出線区
      p[:out_line] = da[8]
      # 9: 出駅順
      p[:out_sta] = da[9]
      # 10-11: 残高 (little endian)
      p[:balance] = PasoriAPI::n2hs(PasoriAPI::get2byte(da,10))
      # 12-14: 連番
      p[:seq] = PasoriAPI::get3byte(da,12)
      # 15: リージョン
      p[:region] = da[15]
      
      # 処理別のデータ
      p[:time] = nil
      case p[:proc]
      when 70,73,74,75,198,203 # 物販
        p[:time] = PasoriAPI::get2byte(da,6)
      when 0x05 # // 車載機(0x05)
        p[:in_line] = nil
        p[:in_sta] = nil
        p[:out_line] = PasoriAPI::get2byte(da, 6)
        p[:out_sta] = PasoriAPI::get2byte(da, 8)
      end
      
      @history << p
      index += 1
    end
    # puts @history
  end
  
  def create_history_json
    ## coding: utf-8
    # content-type: ic_log
    # content-version: 0.1
    
    # contents:
    #   description: "PaSoRiを使って読んだ内容"
    #   read_status: 1 # 0:読み込み成功, 1:読み込み失敗
    #   pasori_data:
    yaml = Hash.new
    yaml['content-type'] = 'history'
    yaml['content-version'] = 0.1
    contents = Hash.new
    yaml[:contents] = contents
    contents[:read_status] = 0
    pasori_data = Hash.new
    contents[:pasori_data] = pasori_data
    idm = @idm_pmm[:idm].collect {|item| sprintf("%02x",item) }
    pmm = @idm_pmm[:pmm].collect {|item| sprintf("%02x", item) }
    pasori_data[:idm] = idm.join
    pasori_data[:pmm] = pmm.join
    # 履歴情報に文字列データを付加する
    append_code_to_stringdata
    pasori_data[:history] = @history
    return yaml.to_json
  end
  
  # 文字列データを付加する
  def append_code_to_stringdata()
    @history.each do | history |
      # 文字列データの初期値をセット
      history[:ctype_name] = nil
      history[:proc_name] = nil
      history[:date_string] = nil
      history[:in_company_name] = nil
      history[:in_line_name] = nil
      history[:in_station_name] = nil
      history[:in_station_location] = nil
      history[:out_company_name] = nil
      history[:out_line_name] = nil
      history[:out_station_name] = nil
      history[:out_station_location] = nil
      history[:time_string] = nil
      
      # 端末名
      history[:ctype_name] = PasoriAPI::get_console_type(history[:ctype])
      # 処理名
      history[:proc_name] = PasoriAPI::get_proc_type(history[:proc])
      # 日付 (先頭から7ビットが年、４ビットが月、残り５ビットが日)
      # 年は20XXに補正する
      year = (history[:date] >> 9) + 2000
      month = (history[:date] >> 5) & 0xf
      day = (history[:date] & 0x1f)
      history[:date_string] = sprintf("%04d/%02d/%02d", year, month, day )
      # 入場駅名
      if history[:in_line] && history[:in_sta]
        areacode = PasoriAPI::get_areacode(history[:in_line], history[:region])
        info = @station_info.code_to_info(areacode, history[:in_line], history[:in_sta])
        if info 
          history[:in_company_name] = info[:company]
          history[:in_line_name] = info[:line_name]
          history[:in_station_name] = info[:station_name]
          history[:in_station_location] = @rail_data.get_location(info[:company], info[:line_name], info[:station_name])
        end
      end
      # 出場駅名
      if history[:out_line] && history[:out_sta]
        areacode = PasoriAPI::get_areacode(history[:out_line], history[:region])
        info = @station_info.code_to_info(areacode, history[:out_line], history[:out_sta])
        if info 
          history[:out_company_name] = info[:company]
          history[:out_line_name] = info[:line_name]
          history[:out_station_name] = info[:station_name]
          history[:out_station_location] = @rail_data.get_location(info[:company], info[:line_name], info[:station_name])
        end
      end
      # 残高
      history[:balance_string] = history[:balance].to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,') + "円"
      # 時刻
      if !history[:time].nil?
        p[:time_string] = sprintf("%02d:%02d", (history[:time] >> 11), ((history[:time] >> 5) & 0x3f))
      end
    end
  end
  
  def pasori_disconnect
    if ! @base_ptr.nil?
      PasoriAPI::felica_free(@base_ptr)
      @base_ptr = nil
    end
  end
  
end
