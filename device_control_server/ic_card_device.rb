# coding: utf-8
require 'pasori_reader'
require 'dropfile_reader'

class ICCardDevice
  
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
    60.times do
      @reader.each do |r|
        json = r.read
        unless json.nil?
          return json
        end
      end
      sleep(1)
    end
    puts 'ERROR: Read失敗'.encode('cp932')
    return "" # json形式の空データを返す？
  end
  
  def write(body)
    # dummy...
    sleep(5)
    return 
  end
  
end
