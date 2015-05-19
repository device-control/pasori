# coding: utf-8
require 'pasori_api'
require 'pasori_history'

class PasoriReader
  SERVICE_SUICA_HISTORY = 0x090f
  
  def initialize
    @station_info = StationInfo.instance
    @rail_data = RailData.instance
    
    # ここで本当のデバイスの初期化や接続処理を行う
    @pasori_ptr = nil
  end
  
  def set_data(data)
    # 特になにもしない
  end
  
  def clear_data
    # 特になにもしない
  end
  
  def read
    @histories = Array.new
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
      history = PasoriHistory.new
      history.set_binarydata(da)
      @histories << history
      index += 1
    end
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
    yaml[:content_type] = 'history'
    yaml[:content_version] = 0.1
    contents = Hash.new
    yaml[:contents] = contents
    contents[:read_status] = 0
    pasori_data = Hash.new
    contents[:pasori_data] = pasori_data
    idm = @idm_pmm[:idm].collect {|item| sprintf("%02x",item) }
    pmm = @idm_pmm[:pmm].collect {|item| sprintf("%02x", item) }
    pasori_data[:idm] = idm.join
    pasori_data[:pmm] = pmm.join
    # 履歴データ
    pasori_data[:histories] = Array.new
    @histories.each do |h|
      # 文字列データを追加する
      h.add_string_data!
      pasori_data[:histories] << h.get_data
    end
    return yaml.to_json
  end
  
  def pasori_disconnect
    if ! @base_ptr.nil?
      PasoriAPI::felica_free(@base_ptr)
      @base_ptr = nil
    end
  end
  
end
