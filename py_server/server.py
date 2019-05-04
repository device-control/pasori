# coding: utf-8
import sys
import os
import struct
import csv
import binascii
import time
import nfc
import json
from websocket_server import WebsocketServer

num_blocks = 20
service_code = 0x090f
ic_card_buffer = {}


class StationRecord(object):
  db = None
 
  def __init__(self, row):
    self.area_key = int(row[0], 10)
    self.line_key = int(row[1], 10)
    self.station_key = int(row[2], 10)
    self.company_value = row[3]
    self.line_value = row[4]
    self.station_value = row[5]
 
  @classmethod
  def get_none(cls):
    # 駅データが見つからないときに使う
    return cls(["0", "0", "0", "None", "None", "None"])
  @classmethod
  def get_db(cls, filename):
    # 駅データのcsvを読み込んでキャッシュする
    if cls.db == None:
      cls.db = []
      for row in csv.reader(open(filename, 'rU'), delimiter=',', dialect=csv.excel_tab):
        cls.db.append(cls(row))
    return cls.db
  @classmethod
  def get_station(cls, line_key, station_key):
    # 線区コードと駅コードに対応するStationRecordを検索する
    for station in cls.get_db("StationCode.csv"):
      if station.line_key == line_key and station.station_key == station_key:
        return station
    return cls.get_none()
 
class HistoryRecord(object):
  def __init__(self, data):
    # ビッグエンディアンでバイト列を解釈する
    row_be = struct.unpack('>2B2H4BH4B', data)
    # リトルエンディアンでバイト列を解釈する
    row_le = struct.unpack('<2B2H4BH4B', data)
 
    self.db = None
    self.console = self.get_console(row_be[0])
    self.process = self.get_process(row_be[1])
    self.year = self.get_year(row_be[3])
    self.month = self.get_month(row_be[3])
    self.day = self.get_day(row_be[3])
    self.balance = row_le[8]
 
    self.in_station = StationRecord.get_station(row_be[4], row_be[5])
    self.out_station = StationRecord.get_station(row_be[6], row_be[7])
 
  @classmethod
  def get_console(cls, key):
    # よく使われそうなもののみ対応
    return {
      0x03: "精算機",
      0x04: "携帯型端末",
      0x05: "車載端末",
      0x12: "券売機",
      0x16: "改札機",
      0x1c: "乗継精算機",
      0xc8: "自販機",
    }.get(key)
  @classmethod
  def get_process(cls, key):
    # よく使われそうなもののみ対応
    return {
      0x01: "運賃支払",
      0x02: "チャージ",
      0x0f: "バス",
      0x46: "物販",
    }.get(key)
  @classmethod
  def get_year(cls, date):
    return (date >> 9) & 0x7f
  @classmethod
  def get_month(cls, date):
    return (date >> 5) & 0x0f
  @classmethod
  def get_day(cls, date):
    return (date >> 0) & 0x1f
 
def connected(tag):
  print tag
  
  if isinstance(tag, nfc.tag.tt3.Type3Tag):
    try:
      _ic_card_buffer = {
        "content_type": "pasori_history",
        "content_version": 1.0,
        "contents": {
          "description": "ic card",
          "read_status": 0,
          "pasori_data": {
            "idm": '',
            "pmm": '',
            "histories":[ ]
          }
        }
      }
      global ic_card_buffer
      ic_card_buffer = _ic_card_buffer.copy()
      sc = nfc.tag.tt3.ServiceCode(service_code >> 6 ,service_code & 0x3f)
      pasori_data = ic_card_buffer["contents"]["pasori_data"]
      histories = pasori_data["histories"]
      for i in range(num_blocks):
        bc = nfc.tag.tt3.BlockCode(i,service=0)
        data = tag.read_without_encryption([sc],[bc])
        history = HistoryRecord(bytes(data))
        print "=== %02d ===" % i
        print "端末種: %s" % history.console
        print "処理: %s" % history.process
        print "日付: %02d-%02d-%02d" % (history.year, history.month, history.day)
        print "入線区: %s-%s" % (history.in_station.company_value, history.in_station.line_value)
        print "入駅順: %s" % history.in_station.station_value
        print "出線区: %s-%s" % (history.out_station.company_value, history.out_station.line_value)
        print "出駅順: %s" % history.out_station.station_value
        print "残高: %d" % history.balance
        print "BIN: " 
        print "" . join(['%02x ' % s for s in data])
        history_dict = {
          "ctype_name": history.console,
          "proc_name": history.process,
          "date_string": "20%d/%02d/%02d" % (history.year, history.month, history.day),
          "balance_string": "%d" % history.balance,
          "in_station_info": {
            "company": "西日本旅客鉄道",
            "line_name": "東海道本",
            "station_name": "大阪"
          },
          "in_station_location": {
            "lat": 34.70232500,
            "lng": 135.49509500
          },
          "out_station_info": {
            "company_name": "西日本旅客鉄道",
            "line_name": "東海道本",
            "station_name": "新大阪"
          },
          "out_station_location": {
            "lat": 34.73404100,
            "lng": 135.50198900
          }
        }
        histories.append(history_dict)
        print("--- _json ---¥n%s" % json.dumps(ic_card_buffer))
    except Exception as e:
      print "error: %s" % e
    else:
      print "error: tag isn't Type3Tag"
    

# 接続
# Called for every client connecting (after handshake)
def new_client(client, server):
    print("New client connected and was given id %d" % client['id'])
    # クライアント全員にメッセージ送信
    # server.send_message_to_all("Hey all, a new client has joined us")

# 切断
# Called for every client disconnecting
def client_left(client, server):
    print("Client(%d) disconnected" % client['id'])

# 受信
# Called when a client sends a message
def message_received(client, server, message):
    # if len(message) > 200:
    # message = message[:200]+'..'
    print("Client(%d) message: %s" % (client['id'], message))
    
    clf = nfc.ContactlessFrontend('usb')
    clf.connect(rdwr={'on-connect': connected})
  
    # time.sleep(5)
    # 送信してきたクライアントにメッセージ送信
    print("--- json ---¥n%s" % json.dumps(ic_card_buffer))
    server.send_message(client, json.dumps(ic_card_buffer))


if __name__ == "__main__":
  PORT=9001
  server = WebsocketServer(PORT)
  server.set_fn_new_client(new_client)
  server.set_fn_client_left(client_left)
  server.set_fn_message_received(message_received)
  server.run_forever()


