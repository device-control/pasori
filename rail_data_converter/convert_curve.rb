# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'yaml'

class ConvertCurve
  attr_accessor :contents
  
  def initialize
    @contents = Hash.new
    @id = nil
    @curve = nil
    @last_tag = nil
  end
  
  def tag_start(name, attrs)
    case name
    when 'gml:Curve'
      @curve = Hash.new
      @id = attrs['gml:id']
    end
    @last_tag = name
  end
  
  def text(text)
    case @last_tag
    when 'gml:posList'
      @curve[@last_tag] = get_poslist(text)
    end
  end
  
  def tag_end(name)
    case name
    when 'gml:Curve'
      puts @id
      @contents[@id] = @curve if @id
      @id =nil
      @curve = nil
    end
    @last_tag = nil
  end
  
  def get_poslist(text)
    list = Array.new
    text.each_line do |line|
      if line.match(/(\d+.\d+) +(\d+.\d+)/)
        pos = Hash.new
        pos[:lat] = $1
        pos[:lng] = $2
        list.push pos
      end
    end
    return list
  end
  
  def save
    savedata = Hash.new
    savedata[:content_type] = 'rail_data'
    savedata[:content_version] = '0.1'
    savedata[:contents] = @contents
    File.binwrite("curves.yml",savedata.to_yaml)
  end
  
end
