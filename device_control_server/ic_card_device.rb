# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'state_machine'
require 'pasori_reader'
require 'dropfile_reader'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class ICCardDevice
  RETRY_COUNT_READ = 60
  
  state_machine :state, :initial => :idle do
    
    after_failure :on => :read_start, :do => :failure
    after_failure :on => :read_end, :do => :failure
    
    event :read_start do
      transition :idle => :reading
    end
    
    event :read_end do
      transition :reading => :idle
    end
    
    state :idle do
      def read
        self.read_start
        res = execute_read
        self.read_end
        return res
      end
    end
    
    state :reading do
      def read
        puts 'ERROR: ic_card_device 読み込み中'.encode('cp932')
        return ''
      end
    end
    
  end
  
  def initialize
    # 使用するReaderを生成
    @pasori_reader = PasoriReader.new
    @dropfile_reader = DropFileReader.new
    super()
  end
  
  def set_data(data)
    @pasori_reader.set_data(data)
    @dropfile_reader.set_data(data)
  end
  
  def clear_data
    @pasori_reader.clear_data
    @dropfile_reader.clear_data
  end
  
  def execute_read
    # read 初期化
    json = nil
    @pasori_reader.read_init
    @dropfile_reader.read_init
    
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
    @pasori_reader.read_finish
    @dropfile_reader.read_finish
    
    # read 結果
    json = '' if json.nil?
    return json
  end
  
  def failure
    puts 'ERROR: 状態遷移失敗'.encode('cp932')
  end
  
end
