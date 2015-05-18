# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'rexml/parsers/streamparser'
require 'rexml/parsers/baseparser'
require 'rexml/streamlistener' 
require 'rubygems'
require 'yaml'
# require 'convert_station'
# require 'convert_railroadsection'
# require 'convert_curve'
require 'convert_point'
require 'convert_station2'
require 'pry'

class MyListener
  include REXML::StreamListener
  
  def initialize
    super
    # @curve = ConvertCurve.new
    # @section = ConvertRailroadSection.new
    # @station = ConvertStation.new
    @point = ConvertPoint.new
    @station2 = ConvertStation2.new
    @converter = nil
    @last_tag = nil
  end
  
  def tag_start(name, attrs)
    # @rail_data は RailLoadSection か RailStation
    case name
    # when 'gml:Curve'
    #   @converter = @curve if @converter.nil?
    # when 'ksj:RailroadSection'
    #   @converter = @section if @converter.nil?
    # when 'ksj:Station'
    #   @converter = @station if @converter.nil?
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
    # when 'gml:Curve'
    #   @converter = nil if @converter.class == ConvertCurve
    # when 'ksj:RailroadSection'
    #   @converter = nil if @converter.class == ConvertRailroadSection
    # when 'ksj:Station'
    #   @converter = nil if @converter.class == ConvertStation
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
    contents = Hash.new
    # contents[:curve] = @curve.contents
    # contents[:section] = @section.contents
    # contents[:station] = @station.contents
    contents[:point] = @point.contents
    contents[:station2] = @station2.contents
    savedata[:contents] = contents
    File.binwrite("rail_data.yml",savedata.to_yaml)
    
    # @curve.save
    # @section.save
    # @station.save
  end
  
end

def convert(file_name)
  listener = MyListener.new
  open(file_name) do |file|
    REXML::Parsers::StreamParser.new(file, listener).parse
  end
  listener.save
end

unless ARGV.size == 1
  puts 'Usage: ./convert.rb <xml_file_name>'
  exit
end

convert(ARGV[0])
