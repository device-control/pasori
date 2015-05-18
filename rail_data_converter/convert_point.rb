# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'yaml'

class ConvertPoint
  attr_accessor :contents
  
  def initialize
    @contents = Hash.new
    @id = nil
    @point = nil
    @last_tag = nil
  end
  
  def tag_start(name, attrs)
    case name
    when 'gml:Point'
      @point = Hash.new
      @id = attrs['gml:id']
    end
    @last_tag = name
  end
  
  def text(text)
    case @last_tag
    when 'gml:pos'
      @point[@last_tag] = get_pos(text)
    end
  end
  
  def tag_end(name)
    case name
    when 'gml:Point'
      puts @id
      @contents[@id] = @point if @id
      @id =nil
      @point = nil
    end
    @last_tag = nil
  end
  
  def get_pos(text)
    pos = Hash.new
    pos[:lat] = nil
    pos[:lng] = nil
    if text.match(/(\d+.\d+) +(\d+.\d+)/)
      pos[:lat] = $1
      pos[:lng] = $2
    end
    return pos
  end
  
  def save
    savedata = Hash.new
    savedata[:content_type] = 'rail_data'
    savedata[:content_version] = '0.1'
    savedata[:contents] = @contents
    File.binwrite("points.yml",savedata.to_yaml)
  end
  
end
