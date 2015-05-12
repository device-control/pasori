# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'yaml'

class ConvertRailroadSection
  attr_accessor :contents
  
  def initialize
    @contents = Hash.new
    @id = nil
    @section = nil
    @last_tag = nil
  end
  
  def tag_start(name, attrs)
    case name
    when 'ksj:RailroadSection'
      @section = Hash.new
      @id = attrs['gml:id']
    when 'ksj:location'
      if xlink = attrs['xlink:href']
        @section[name] = xlink.gsub(/^#/,'')
      end
    end
    @last_tag = name
  end
  
  def text(text)
    case @last_tag
    when 'ksj:railwayType'
      @section[@last_tag] = text
    when 'ksj:serviceProviderType'
      @section[@last_tag] = text
    when 'ksj:railwayLineName'
      @section[@last_tag] = text
    when 'ksj:operationCompany'
      @section[@last_tag] = text
    end
  end
  
  def tag_end(name)
    case name
    when 'ksj:RailroadSection'
      puts @id
      @contents[@id] = @section if @id
      @id =nil
      @section = nil
    end
    @last_tag = nil
  end
  
  def save
    savedata = Hash.new
    savedata[:content_type] = 'rail_data'
    savedata[:content_version] = '0.1'
    savedata[:contents] = @contents
    File.binwrite("railroad_sections.yml",savedata.to_yaml)
  end
  
end
