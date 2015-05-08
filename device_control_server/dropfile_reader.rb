# coding: utf-8

class DropFileReader
  # 対象ファイルの定義
  CONTENT_TYPE    = "pasori_history"
  CONTENT_VERSION = 0.1
  
  def initialize
    # ここで本当のデバイスの初期化や接続処理を行う
    @data = nil
  end
  
  def set_data(data)
    if @data
      puts "ERROR: 既にデータが存在しています".encode('cp932')
      return
    end
    if !target_data?(data)
      puts "ERROR: 対象ファイルではありません".encode('cp932')
      return
    end
    @data = data.to_json
  end
  
  def clear_data
    @data = nil
  end
  
  def read
    if @data.nil?
      puts "ERROR: ファイルをドロップしてください".encode('cp932')
    end
    return @data
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
  
  def target_data?(data)
    if data['content-type'] != CONTENT_TYPE
      puts "ERROR: content-type".encode('cp932')
      return false
    end
    if data['content-version'] != CONTENT_VERSION
      puts "ERROR: content-version".encode('cp932')
      return false
    end
    return true
  end
  
end
