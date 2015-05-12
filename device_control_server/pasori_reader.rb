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
  
  # 入出金情報取得
  def get_deposit_info(da,p)
    p[:time] = nil
    p[:in_line] = nil
    p[:in_sta] = nil
    p[:out_line] = nil
    p[:out_sta] = nil
    case p[:ctype]
    when 0xC7, 0x08 #  // 物販(0xC7), 自販機(0x08)
      p[:time] = PasoriAPI::get2byte(da,6)
      p[:in_line] = da[8]
      p[:in_sta] = da[9]
    when 0x05 # // 車載機(0x05)
      p[:in_line] = PasoriAPI::get2byte(da, 6)
      p[:in_sta] = PasoriAPI::get2byte(da, 8)
    else
      p[:in_line] = da[6];
      p[:in_sta] = da[7];
      p[:out_line] = da[8];
      p[:out_sta] = da[9];
    end
  end
  
  # 駅情報取得
  def get_station_info(p)
    p[:in_company] = nil
    p[:in_line_name] = nil
    p[:in_station_name] = nil
    p[:out_company] = nil
    p[:out_line_name] = nil
    p[:out_station_name] = nil
    # in
    if p[:in_line] && p[:in_sta]
      areacode = PasoriAPI::get_areacode(p[:in_line], p[:region])
      info = @station_info.code_to_info(areacode, p[:in_line], p[:in_sta])
      if info
        p[:in_company] = info[:company]
        p[:in_line_name] = info[:line_name]
        p[:in_station_name] = info[:station_name]
        
        location = @rail_data.get_location(info[:company], info[:line_name], info[:station_name])
        p[:drop_station_name] = info[:station_name]
        p[:drop_station_lat] = location[:lat]
        p[:drop_station_lng] = location[:lng]
      end
    end
    
    # out
    if p[:out_line] && p[:out_sta]
      areacode = PasoriAPI::get_areacode(p[:out_line], p[:region])
      info = @station_info.code_to_info(areacode, p[:out_line], p[:out_sta])
      if info
        p[:out_company] = info[:company]
        p[:out_line_name] = info[:line_name]
        p[:out_station_name] = info[:station_name]
      end
    end
    
  end
  
  # 入出金履歴取得
  def pasori_history_read
    index = 0
    data = ' ' * 16
    while 0 == PasoriAPI::felica_read_without_encryption02(@base_ptr, SERVICE_SUICA_HISTORY, 0, index, data) do
      da = data.unpack('C*')
      p = Hash.new
      p[:ctype] = da[0]
      p[:proc] = da[1]
      p[:date] = PasoriAPI::get2byte(da,4)
      p[:balance] = PasoriAPI::n2hs(PasoriAPI::get2byte(da,10))
      seq = PasoriAPI::get4byte(da,12)
      p[:region] = seq & 0xff
      p[:seq] = seq >> 8
      
      get_deposit_info(da,p)
      
      p[:ctype_name] = PasoriAPI::get_console_type(p[:ctype])
      p[:proc_name] = PasoriAPI::get_proc_type(p[:proc])
      p[:date_string] = sprintf("%02d/%02d/%02d", (p[:date] >> 9), ((p[:date] >> 5) & 0xf), (p[:date] & 0x1f) )
      
      p[:time_string] = nil
      if !p[:time].nil?
        p[:time_string] = sprintf("%02d:%02d", (p[:time] >> 11), ((p[:time] >> 5) & 0x3f))
      end
      
      # 駅情報を取得
      get_station_info(p)
      
      @history << p
      index += 1
    end
    puts @history
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
    pasori_data[:history] = @history
    return yaml.to_json
  end
  
  def pasori_disconnect
    if ! @base_ptr.nil?
      PasoriAPI::felica_free(@base_ptr)
      @base_ptr = nil
    end
  end
  
end
