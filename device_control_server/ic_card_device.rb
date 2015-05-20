# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'pasori_reader'
require 'dropfile_reader'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class ICCardDevice
  RETRY_COUNT_READ = 60
  
  attr_accessor :ws_conn
  attr_accessor :connect_signature
  
  def initialize
    @connect_signature = nil
    # 使用するReaderを生成
    @pasori_reader = PasoriReader.new
    @dropfile_reader = DropFileReader.new
  end
  
  def set_data(data)
    @pasori_reader.set_data(data)
    @dropfile_reader.set_data(data)
  end
  
  def clear_data
    @pasori_reader.clear_data
    @dropfile_reader.clear_data
  end
  
  def read
    json = nil
    # read 初期化
    read_init
    # read 処理実行
    catch :loop do
      RETRY_COUNT_READ.times do
        json = @pasori_reader.read
        throw :loop unless json.nil?
        
        json = @dropfile_reader.read
        throw :loop unless json.nil?
        
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
    @pasori_reader.read_init
    @dropfile_reader.read_init
  end
  
  def read_finish
    @pasori_reader.read_finish
    @dropfile_reader.read_finish
  end
  
  def write(body)
    # @pasori_reader.write(body)
    # @dropfile_reader.write(body)
  end
  
end
