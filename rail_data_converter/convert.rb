# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'rexml/parsers/streamparser'
require 'rexml/parsers/baseparser'
require 'rexml/streamlistener' 
require 'rubygems'
require 'yaml'
require 'convert_point'
require 'convert_station2'
require 'pry'

class MyListener
  include REXML::StreamListener
  
  def initialize
    super
    @point = ConvertPoint.new
    @station2 = ConvertStation2.new
    @converter = nil
    @last_tag = nil
  end
  
  def tag_start(name, attrs)
    case name
    when 'ksj:Station2'
      @converter = @station2 if @converter.nil?
    when 'gml:Point'
      @converter = @point if @converter.nil?
    end
    @converter.tag_start(name, attrs) if @converter
    @last_tag = name
  end
  
  def text(text)
    @converter.text(text) if @converter
  end
  
  def tag_end(name)
    @converter.tag_end(name) if @converter
    @last_tag = nil
    case name
    when 'ksj:Station2'
      @converter = nil if @converter.class == ConvertStation2
    when 'gml:Point'
      @converter = nil if @converter.class == ConvertPoint
    end
  end
  
  def save
    savedata = Hash.new
    savedata[:content_type] = 'rail_data'
    savedata[:content_version] = '0.1'
    
    contents = Array.new
    @station2.contents.each do | key, val |
      val[:loc] = @point.get_data( val[:loc].to_sym )
      contents << val
    end
    savedata[:contents] = contents
    File.binwrite("rail_data.yml",savedata.to_yaml)
  end
  
end

def convert(file_name)
  listener = MyListener.new
  open(file_name) do |file|
    REXML::Parsers::StreamParser.new(file, listener).parse
  end
  listener.save
end

convert('N05-13.xml')
