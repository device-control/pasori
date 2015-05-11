# coding: utf-8
require 'fiddle/import'
require 'fiddle/types'

module PasoriAPI
  extend Fiddle::Importer
  dlload 'felicalib.dll'
  include Fiddle::BasicTypes
  include Fiddle::Win32Types
  
  MAX_SYSTEM_CODE = 8
  MAX_AREA_CODE = 16
  MAX_SERVICE_CODE = 256
  POLLING_ANY = 0xffff
  POLLING_EDY = 0xfe00
  POLLING_SUICA = 0x0003
  
  typealias 'pasori', 'void'
  typealias 'felica', 'void'
  typealias 'uint16', 'unsigned short'
  typealias 'uint8', 'unsigned char'
  
  typealias 'MAX_SERVICE_CODE', MAX_SERVICE_CODE
  
  Felica = struct( [
      "pasori *p", # PaSoRi ハンドル
      "uint16 systemcode", # システムコード
      "uint8 IDm[8]", # IDm
      "uint8 PMm[8]", # PMm
      # systemcode
      "uint8 num_system_code", # 列挙システムコード数
      "uint16 system_code[8]", # 列挙システムコード
      # area/service codes
      "uint8 num_area_code", # エリアコード数
      "uint16 area_code[16]", # エリアコード
      "uint16 end_service_code[16]", # エンドサービスコード
      "uint8 num_service_code", # サービスコード数
      "uint16 service_code[256]", # サービスコード
    ])
  
  extern 'pasori* pasori_open(char *)' # PaSoRi をオープンする 
  extern 'void pasori_close(pasori *)' # PaSoRi ハンドルをクローズする
  extern 'int pasori_init(pasori *)' # PaSoRi を初期化する
  extern 'felica* felica_polling(pasori *, uint16, uint8, uint8)' # FeliCa をポーリングする
  extern 'void felica_free(felica *)' # felica ハンドル解放
  extern 'void felica_getidm(felica *, uint8 *)' # IDm 取得
  extern 'void felica_getpmm(felica *, uint8 *)' # PMm 取得
  extern 'int felica_read_without_encryption02(felica *, int, int, uint8, uint8 *)' # 暗号化されていないブロックを読み込む
  # extern 'int felica_write_without_encryption(felica *, int, uint8, uint8 *)' # 暗号化されていないブロックを書き込む
  extern 'felica* felica_enum_systemcode(pasori *)' # システムコードの列挙
  extern 'felica* felica_enum_service(pasori *, uint16)' # サービス/エリアコードの列挙
  
  def self.n2hs(value)
    ( ((value & 0xff) << 8) | ((value & 0xff00) >> 8) )
  end
  
  def self.get2byte(da,offset)
    return (da[offset] << 8) | da[offset+1]
  end
  
  def self.get4byte(da,offset)
    return (da[offset] << 24) |(da[offset+1] << 16) |(da[offset+2] << 8) | da[offset+3]
  end
  
  def self.get_console_type(ctype)
    case ctype
    when 0x03; "清算機"
    when 0x05; "車載端末"
    when 0x08; "券売機"
    when 0x12; "券売機"
    when 0x16; "改札機"
    when 0x17; "簡易改札機"
    when 0x18; "窓口端末"
    when 0x1a; "改札端末"
    when 0x1b; "携帯電話"
    when 0x1c; "乗継清算機"
    when 0x1d; "連絡改札機"
    when 0xc7; "物販"
    when 0xc8; "自販機"
    else "???"
    end
  end
  
  def self.get_proc_type(proc)
    case proc
    when 0x01; "運賃支払"
    when 0x02; "チャージ"
    when 0x03; "券購"
    when 0x04; "清算"
    when 0x07; "新規"
    when 0x0d; "バス"
    when 0x0f; "バス"
    when 0x14; "オートチャージ"
    when 0x46; "物販"
    when 0x49; "入金"
    when 0xc6; "物販(現金併用)"
    else "???"
    end
  end
  
  def self.get_areacode(linecode, region)
    # 線区が 0x7f 以下のとり : 0 (JR線)
    return 0 if linecode < 0x7F
    # 線区が 0x80 以上でリージョンが 0 のとき : 1 (関東公営・私鉄)
    return 1 if region == 0
    # 線区が 0x80 以上でリージョンが 1 のとき : 2 (関西公営・私鉄)
    return 2
  end
  
end
