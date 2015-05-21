# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class DropFileReader
  CONTENT_TYPE    = 'pasori_history'
  CONTENT_VERSION = 0.1
  
  def initialize
    @data = nil
  end
  
  def set_data(data)
    unless @data.nil?
      puts 'ERROR: 既にデータが存在しています'.encode('cp932')
      return
    end
    
    unless target_data?(data)
      puts 'ERROR: 対象ファイルではありません'.encode('cp932')
      return
    end
    
    @data = data.clone
  end
  
  def clear_data
    @data = nil
  end
  
  def read
    if @data.nil?
      puts 'ERROR: ファイルをドロップしてください'.encode('cp932')
      return nil
    end
    
    # 履歴データに文字列データを追加する
    add_history_string_data
    
    return @data.to_json
  end
  
  def read_init
    clear_data
  end
  
  def read_finish
    # 特になにもしない
  end
  
  def write(body)
    # dummy...
    sleep(5)
    return 
  end
  
  def add_history_string_data
    histories = @data[:contents][:pasori_data][:histories]
    histories.each_with_index do |h, index|
      history = PasoriHistory.new
      history.set_data(h)
      history.add_string_data!
      histories[index] = history.get_data
    end
  rescue
    puts 'ERROR: add_history_string_data'.encode('cp932')
  end
  
  def target_data?(data)
    if data[:content_type] != CONTENT_TYPE
      puts 'ERROR: content_type'.encode('cp932')
      return false
    end
    
    if data[:content_version] != CONTENT_VERSION
      puts 'ERROR: content_version'.encode('cp932')
      return false
    end
    
    return true
  end
  
end
