# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'yaml'

class ConvertPoint
  attr_accessor :contents
  
  def initialize
    @contents = Hash.new
    @id = nil
    @data = nil
    @last_tag = nil
  end
  
  def tag_start(name, attrs)
    case name
    when 'gml:Point'
      @data = Hash.new
      @id = attrs['gml:id'].to_sym
    end
    @last_tag = name
  end
  
  def text(text)
    case @last_tag
    when 'gml:pos'
      @data = get_pos(text)
    end
  end
  
  def tag_end(name)
    case name
    when 'gml:Point'
      puts @id
      @contents[@id] = @data if @id
      @id =nil
      @data = nil
    end
    @last_tag = nil
  end
  
  def get_pos(text)
    if text.match(/(\d+.\d+) +(\d+.\d+)/)
      pos = Hash.new
      pos[:lat] = $1
      pos[:lng] = $2
      return pos
    end
    return nil
  end
  
  def get_data(id)
    return @contents[id]
  end
  
  def save
    savedata = Hash.new
    savedata[:content_type] = 'rail_data'
    savedata[:content_version] = '0.1'
    savedata[:contents] = @contents
    File.binwrite("points.yml",savedata.to_yaml)
  end
  
end
