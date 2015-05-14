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
  
  class << self
    def n2hs(value)
      ( ((value & 0xff) << 8) | ((value & 0xff00) >> 8) )
    end
    
    def get2byte(da,offset)
      return (da[offset] << 8) | da[offset+1]
    end
    
    def get3byte(da,offset)
      return (da[offset] << 16) |(da[offset+1] << 8) | da[offset+2]
    end
    
    def get4byte(da,offset)
      return (da[offset] << 24) |(da[offset+1] << 16) |(da[offset+2] << 8) | da[offset+3]
    end
    
    def get_console_type(ctype)
      case ctype
      when 3; "精算機"
      when 4; "携帯型端末"
      when 5; "車載端末"
      when 7; "券売機"
      when 8; "券売機"
      when 9; "入金機"
      when 18; "券売機"
      when 20; "券売機等"
      when 21; "券売機等"
      when 22; "改札機"
      when 23; "簡易改札機"
      when 24; "窓口端末"
      when 24; "窓口端末"
      when 26; "改札端末"
      when 27; "携帯電話"
      when 28; "乗継精算機"
      when 29; "連絡改札機"
      when 31; "簡易入金機"
      when 70; "VIEW ALTTE"
      when 72; "VIEW ALTTE"
      when 199; "物販端末"
      when 200; "自販機"
      else "???"
      end
    end
    
    def get_proc_type(proc)
      case proc
      when 1; "運賃支払(改札出場)"
      when 2; "チャージ"
      when 3; "券購(磁気券購入)"
      when 4; "精算"
      when 5; "精算 (入場精算)"
      when 6; "窓出 (改札窓口処理)"
      when 7; "新規 (新規発行)"
      when 8; "控除 (窓口控除)"
      when 13; "バス (PiTaPa系)"
      when 15; "バス (IruCa系)"
      when 17; "再発 (再発行処理)"
      when 19; "支払 (新幹線利用)"
      when 20; "入A (入場時オートチャージ)"
      when 21; "出A (出場時オートチャージ)"
      when 31; "入金 (バスチャージ)"
      when 35; "券購 (バス路面電車企画券購入)"
      when 70; "物販"
      when 72; "特典 (特典チャージ)"
      when 73; "入金 (レジ入金)"
      when 74; "物販取消"
      when 75; "入物 (入場物販)"
      when 198; "物現 (現金併用物販)"
      when 203; "入物 (入場現金併用物販)"
      when 132; "精算 (他社精算)"
      when 133; "精算 (他社入場精算)"
      else "???"
      end
    end
    
    def get_areacode(linecode, region)
      # 線区が 0x7f 以下のとり : 0 (JR線)
      return 0 if linecode < 0x7F
      # 線区が 0x80 以上でリージョンが 0 のとき : 1 (関東公営・私鉄)
      return 1 if region == 0
      # 線区が 0x80 以上でリージョンが 1 のとき : 2 (関西公営・私鉄)
      return 2
    end
    
  end
  
end
