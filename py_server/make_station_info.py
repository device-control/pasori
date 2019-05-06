# -*- coding: utf-8 -*-
# coding: utf-8
import sys
import os
# import struct
# import csv
import binascii
# import time
import json
import yaml
import re
import codecs
# import pprint
import pdb

if __name__ == "__main__":
  # company = "テスト（デバッグ）"
  # m = re.match(r"(.+?)（.+?）", company)
  # pdb.set_trace()

  # rail_data = yaml.load(codecs.open('rail_data.yml', 'r', 'utf-8'))
  # rail_data = yaml.load(open('rail_data.yml'))
  # rail_data2 = codecs.open('rail_data2.yml', 'r', 'utf-8').read()
  # rail_data = open('rail_data2.yml').read()
  # pdb.set_trace()
  # rail_data = rail_data.encode('utf-8')
  # rail_data = yaml.load(rail_data)
  rail_data = yaml.load(codecs.open('rail_data.yml', 'r', 'utf-8'))
  station_positions = rail_data[':contents']
  # - :lin: 東海道線
  #   :opc: 東日本旅客鉄道（旧国鉄）
  #   :loc:
  #     :lat: '35.68173200'
  #     :lng: '139.76538400'
  #   :stn: 東京
  locations = {}
  for station_position in station_positions:
    company = station_position[":opc"].encode('utf-8')
    station_name = station_position[":stn"].encode('utf-8')
    location = {
      ":lat": station_position[":loc"][":lat"],
      ":lng": station_position[":loc"][":lng"]
    }
    # （）を削除しておく
    m = re.match(r"(.+?)（.+?）", company)
    if m:
      company = m.group(1)
    name = company + '_' + station_name
    locations[name] = location
    # print name

  # print(json.dump(locations))
  # exit
  
  # 000-001-001:
  #   :company: "東日本旅客鉄道"
  #   :line_name: "東海道本"
  #   :station_name: "東京"
  #   :note: ''
  station_code = yaml.load(codecs.open('station_code.yml', 'r', 'utf-8'))
  stations = station_code[':contents'][':data']
  # 位置不明な場合は、東京駅にしておく
  default_location = {
    ":lat": '35.68173200',
    ":lng": '139.76538400'
  }
  station_infos = {}
  for station_key, station_value in stations.items():
    name = station_value[":company"] + "_" + station_value[":station_name"]
    name = name.encode('utf-8')
    station_value[":location"] = default_location
    # station_value[":name"] = name
    if name in locations:
      print name
      station_value[":location"] = locations[name]
    # pdb.set_trace()
    station_info = {
      "company": station_value[":company"].encode('utf-8'),
      "line_name": station_value[":line_name"].encode('utf-8'),
      "station_name": station_value[":station_name"].encode('utf-8'),
      "location": {
        "lat": station_value[":location"][":lat"],
        "lng": station_value[":location"][":lng"]
      }
    }
    station_infos[station_key] = station_info
    
  # f = codecs.open("test.yml", "w", 'utf-8')
  # f.write( yaml.dump(station_infos, encoding='utf-8') ) # , allow_unicode=True)))
  # f.close()
  f = codecs.open("test.yml", "w")
  for station_key, station_value in station_infos.items():
    f.write( station_key + ":" + '\n')
    f.write( "  company: " + station_value["company"] + "\n")
    f.write( "  line_name: " + station_value["line_name"] + '\n')
    f.write( "  station_name: " + station_value["station_name"] + '\n')
    f.write( "  location:\n")
    f.write( "    lat: " + station_value["location"]["lat"] + '\n')
    f.write( "    lng: " + station_value["location"]["lng"] + '\n')
  f.close()

  # csv_reader = csv.reader(open("StationCode.csv", 'rU'), delimiter=',', dialect=csv.excel_tab)
  # station_code = [row for row in csv_reader]
  # print(station_code[0])

  
