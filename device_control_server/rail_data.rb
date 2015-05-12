# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'pry'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class RailData
  # 対象ファイルの定義
  CONTENT_TYPE    = "rail_data"
  CONTENT_VERSION = "0.1"
  
  def initialize
    @rail_data = nil
    @points = nil
    @stations = nil
    
    load_yaml
    make_tables
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
        contents = yaml[:contents]
        if contents
          @points = contents[:point]
          @stations = contents[:station2]
        end
      else
        puts "ERROR: rail_data.ymlが対象のファイルではありません".encode('cp932')
      end
    end
  end
  
  def make_tables
    @companys = Array.new
    @linenames = Array.new
    @stations.each do |key,val|
      # 会社名テーブル
      if opc = val['ksj:opc']
        if !@companys.include?(opc)
          @companys.push opc
        end
      end
      # 路線名テーブル
      if lin = val['ksj:lin']
        if !@linenames.include?(lin)
          @linenames.push lin
        end
      end
    end
    # puts @companys
    # puts @linenames
  end
  
  def get_location(company, line_name, station_name)
    location = Hash.new
    location[:lat] = nil
    location[:lng] = nil
    # 駅名が一致するデータを取得する
    station = search_station(company, line_name, station_name)
    if station
      location[:lat] = @points[station['ksj:loc']]['gml:pos'][:lat]
      location[:lng] = @points[station['ksj:loc']]['gml:pos'][:lng]
    end
    return location
  end
  
  def search_station(company, line_name, station_name)
    # 駅名が一致する駅データを取得
    selects = @stations.select { |k, v| station_name == v['ksj:stn'] }
    # 会社名、路線名をあいまいに検索
    # 最初に一致したデータを取得する
    selects.each do | key, val|
      if !fuzzy_search(company, val['ksj:opc'])
        next
      end
      if !fuzzy_search(line_name, val['ksj:lin'])
        next
      end
      puts "key=#{key} station_name=#{station_name}"
      return val
    end
    return nil
  end
  
  # あいまい検索
  # 文字数の６割が一致いたらtrueとする
  def fuzzy_search(key, src)
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

