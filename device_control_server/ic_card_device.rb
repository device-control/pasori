# coding: utf-8
require 'pasori_reader'
require 'dropfile_reader'

class ICCardDevice
  RETRY_COUNT_READ = 60
  
  attr_accessor :ws_conn
  attr_accessor :connect_signature
  
  def initialize
    # ここで本当のデバイスの初期化や接続処理を行う
    @connect_signature = nil
    # 使用するReaderを生成
    @reader = Array.new
    @reader.push PasoriReader.new
    @reader.push DropFileReader.new
  end
  
  def set_data(data)
    @reader.each do |r|
      r.set_data(data)
    end
  end
  
  def clear_data
    @reader.each do |r|
      r.clear_data
    end
  end
  
  def read
    json = nil
    # read 初期化
    read_init
    # read 処理実行
    catch :loop do
      RETRY_COUNT_READ.times do
        @reader.each do |r|
          json = r.read
          throw :loop if !json.nil?
        end
        sleep(1)
      end
    end
    # read 後処理
    read_finish
    # read 結果
    if json.nil?
      puts 'ERROR: Read失敗'.encode('cp932')
      return ""
    end
    return json
  end
  
  def read_init
    @reader.each do |r|
      r.read_init
    end
  end
  
  def read_finish
    @reader.each do |r|
      r.read_finish
    end
  end
  
  def write(body)
    # dummy...
    sleep(5)
    return 
  end
  
end
