# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'yaml'

class ConvertStation2
  attr_accessor :contents
  
  def initialize
    @contents = Hash.new
    @id = nil
    @station = nil
    @last_tag = nil
  end
  
  def tag_start(name, attrs)
    case name
    when 'ksj:Station2'
      @station = Hash.new
      @id = attrs['gml:id']
    when 'ksj:loc'
      if xlink = attrs['xlink:href']
        @station[name] = xlink.gsub(/^#/,'')
      end
    end
    @last_tag = name
  end
  
  def text(text)
    case @last_tag
    when 'ksj:lin'
      @station[@last_tag] = text
    when 'ksj:opc'
      @station[@last_tag] = text
    when 'ksj:stn'
      @station[@last_tag] = text
    end
  end
  
  def tag_end(name)
    case name
    when 'ksj:Station2'
      puts @id
      @contents[@id] = @station if @id
      @id =nil
      @station = nil
    end
    @last_tag = nil
  end
  
  def save
    savedata = Hash.new
    savedata[:content_type] = 'rail_data'
    savedata[:content_version] = '0.1'
    savedata[:contents] = @contents
    File.binwrite("stations2.yml",savedata.to_yaml)
  end
  
end
