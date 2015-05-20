# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'singleton'
require 'yaml'
require 'pry'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StationInfo
  include Singleton
  
  # 対象ファイルの定義
  CONTENT_TYPE    = 'station_code'
  CONTENT_VERSION = '0.1'
  
  def initialize
    @station_info = nil
    @data = nil
    
    load_yaml
  end
  
  def load_yaml  
    # 駅コードファイルの読込
    filepath = File.expand_path(File.dirname(__FILE__)+'/../get_station_code/station_code.yml')
    unless File.exist?(filepath)
      puts 'ERROR: station_code.ymlがありません'.encode('cp932')
      return
    end
    File.open(filepath) do |file|
      yaml = YAML.load(file.read)
      if target_data?(yaml)
        @station_info = yaml
        contents = yaml[:contents]
        if contents
          @data = contents[:data]
        end
      else
        puts 'ERROR: station_code.ymlが対象のファイルではありません'.encode('cp932')
      end
    end
  end
  
  def code_to_info(area, line, sta)
    code = sprintf('%03d-%03d-%03d', area, line, sta)
    @data[code]
  rescue
    return nil
  end
  
  def target_data?(data)
    if data[:content_type] != CONTENT_TYPE
      puts 'ERROR: content-type'.encode('cp932')
      return false
    end
    
    if data[:content_version] != CONTENT_VERSION
      puts 'ERROR: content-version'.encode('cp932')
      return false
    end
    return true
  end
  
end

