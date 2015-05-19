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
  
end
