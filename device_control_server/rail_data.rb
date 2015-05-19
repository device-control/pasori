# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'singleton'
require 'yaml'
require 'pry'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class RailData
  include Singleton
  
  # 対象ファイルの定義
  CONTENT_TYPE    = "rail_data"
  CONTENT_VERSION = "0.1"
  
  def initialize
    @rail_data = nil
    @contents = nil
    
    load_yaml
  end
  
  def load_yaml
    # 鉄道データファイル読込
    filepath = File.expand_path(File.dirname(__FILE__)+"/../rail_data_converter/rail_data.yml")
    if !File.exist?(filepath)
      puts "ERROR: rail_data.ymlがありません".encode('cp932')
      return
    end
    File.open(filepath) do |file|
      yaml = YAML.load(file.read)
      if target_data?(yaml)
        @rail_data = yaml
        @contents = yaml[:contents]
      else
        puts "ERROR: rail_data.ymlが対象のファイルではありません".encode('cp932')
      end
    end
  end
  
  def get_location(company, line_name, station_name)
    # 駅名が一致するデータを取得する
    station = search_station(company, line_name, station_name)
    if !station.nil?
      return station[:loc]
    end
    return nil
  end
  
  def search_station(company, line_name, station_name)
    # 駅名が一致する駅データを取得
    selects = @contents.select { |v| station_name == v[:stn] }
    # 会社名、路線名をあいまいに検索
    # 最初に一致したデータを取得する
    selects.each do |val|
      # データが１つの場合は確定
      if selects.length == 1
        return val
      end
      # 会社名を検索
      if !fuzzy_search(company, val[:opc])
        next
      end
      # 路線名を検索
      if !fuzzy_search(line_name, val[:lin])
        next
      end
      # puts "key=#{key} station_name=#{station_name}"
      return val
    end
    return nil
  end
  
  # あいまい検索
  # 文字数の６割が一致したらtrueとする
  def fuzzy_search(key, src)
    return false if key.nil?
    return false if src.nil?
    
    index = 0
    key.each_char do |ch|
      if src.length < index
        break
      end
      if ch != src[index]
        break
      end
      index += 1
    end
    
    # puts "key=#{key} src=#{src} index=#{index}"
    return true if index > (key.length*0.6)
    return false
  end
  
  def target_data?(data)
    if data[:content_type] != CONTENT_TYPE
      puts "ERROR: content_type".encode('cp932')
      return false
    end
    if data[:content_version] != CONTENT_VERSION
      puts "ERROR: content_version".encode('cp932')
      return false
    end
    return true
  end
  
end

