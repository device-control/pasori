# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'yaml'

class ConvertStation2
  attr_accessor :contents
  
  def initialize
    @contents = Hash.new
    @id = nil
    @data = nil
    @last_tag = nil
  end
  
  def tag_start(name, attrs)
    case name
    when 'ksj:Station2'
      @data = Hash.new
      @id = attrs['gml:id'].to_sym
    when 'ksj:loc'
      if xlink = attrs['xlink:href']
        @data[:loc] = xlink.gsub(/^#/,'')
      end
    end
    @last_tag = name
  end
  
  def text(text)
    case @last_tag
    when 'ksj:lin'
      @data[:lin] = text
    when 'ksj:opc'
      @data[:opc] = text
    when 'ksj:stn'
      @data[:stn] = text
    end
  end
  
  def tag_end(name)
    case name
    when 'ksj:Station2'
      puts @id
      @contents[@id] = @data if @id
      @id =nil
      @data = nil
    end
    @last_tag = nil
  end
  
  def get_data(id)
    return @contents[id]
  end
  
  def save
    savedata = Hash.new
    savedata[:content_type] = 'rail_data'
    savedata[:content_version] = '0.1'
    savedata[:contents] = @contents
    File.binwrite("stations2.yml",savedata.to_yaml)
  end
  
end
