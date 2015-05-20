# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'pasori_api'
require 'station_info'
require 'rail_data'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class PasoriHistory
  include PasoriAPI
  
  def initialize
    @station_info = StationInfo.instance
    @rail_data = RailData.instance
    @data = nil
  end
  
  def set_data(data)
    @data = data.clone
  end
  
  def get_data
    return @data.clone
  end
  
  def set_binarydata(data)
    if data.nil? || data.length < 16
      puts 'ERROR: 履歴データが不正です'.encode('cp932')
      return
    end
    
    @data = Hash.new
    # バイナリデータ
    data[:binary] = data.collect{|d| '%02X' % d}.join
    # 0: 端末種
    @data[:ctype] = data[0]
    # 1: 処理
    @data[:proc] = data[1]
    # 2-3: ??
    @data[:dummy] = get2byte(data, 2)
    # 4-5: 日付
    @data[:date] = get2byte(data, 4)
    
    # 6-9: 処理別データ
    case @data[:proc]
    when 70,73,74,75,198,203 # 物販
      # 6-7: 時刻
      @data[:time] = get2byte(data, 6)
      # 8: 出線区
      @data[:out_line] = data[8]
      # 9: 出駅順
      @data[:out_sta] = data[9]
    when 13,15,31,35 # バス
      # 6-7: 出線区
      @data[:out_line] = get2byte(data, 6)
      # 8-9: 出駅順
      @data[:out_sta] = get2byte(data, 8)
    else
      # 6: 入線区
      @data[:in_line] = data[6]
      # 7: 入駅順
      @data[:in_sta] = data[7]
      # 8: 出線区
      @data[:out_line] = data[8]
      # 9: 出駅順
      @data[:out_sta] = data[9]
    end
    
    # 10-11: 残高 (little endian)
    @data[:balance] = n2hs(get2byte(data, 10))
    # 12-14: 連番
    @data[:seq] = get3byte(data, 12)
    # 15: リージョン
    @data[:region] = data[15]
  end
  
  # 履歴に文字列情報を追加する
  # 既に文字列データがある場合は追加しない
  def add_string_data!
    # 端末名
    unless @data[:ctype].nil?
      @data[:ctype_name] = get_console_type(@data[:ctype]) if @data[:ctype_name].nil?
    end
    
    # 処理名
    unless @data[:proc].nil?
      @data[:proc_name] = get_proc_type(@data[:proc]) if @data[:proc_name].nil?
    end
    
    # 日付 (先頭から7ビットが年、４ビットが月、残り５ビットが日)
    unless @data[:date].nil?
      @data[:date_string] = get_date_string(@data[:date]) if @data[:date_string].nil?
    end
    
    # 入場駅関連
    unless @data[:in_line].nil? || @data[:in_sta].nil?
      @data[:in_station_info] = get_station_info(@data[:in_line], @data[:in_sta], @data[:region]) if @data[:in_station_info].nil?
    end
    
    # 入場駅の位置
    unless @data[:in_station_info].nil?
      @data[:in_station_location] = get_station_location(@data[:in_station_info]) if @data[:in_station_location].nil?
    end
    
    # 出場駅関連
    unless @data[:out_line].nil? || @data[:out_sta].nil?
      @data[:out_station_info] = get_station_info(@data[:out_line], @data[:out_sta], @data[:region]) if @data[:out_station_info].nil?
    end
    
    # 出場駅の位置
    unless @data[:out_station_info].nil?
      @data[:out_station_location] = get_station_location(@data[:out_station_info]) if @data[:out_station_location].nil?
    end
    
    # 残高
    unless @data[:balance].nil?
      @data[:balance_string] = get_balance_string(@data[:balance]) if @data[:balance_string].nil?
    end
    
    # 時刻
    unless @data[:time].nil?
      @data[:time_string] = get_time_string(@data[:time]) if @data[:time_string].nil?
    end
    
    return self
  end
  
  # 駅情報取得
  def get_station_info(line, station, region)
    areacode = get_areacode(line, region)
    return @station_info.code_to_info(areacode, line, station)
  end
  
  # 駅位置取得
  def get_station_location(info)
    return @rail_data.get_location(info[:company], info[:line_name], info[:station_name])
  end
  
  # 端末名
  def get_console_type(ctype)
    case ctype
    when 3; '精算機'
    when 4; '携帯型端末'
    when 5; '車載端末'
    when 7; '券売機'
    when 8; '券売機'
    when 9; '入金機'
    when 18; '券売機'
    when 20; '券売機等'
    when 21; '券売機等'
    when 22; '改札機'
    when 23; '簡易改札機'
    when 24; '窓口端末'
    when 25; '窓口端末'
    when 26; '改札端末'
    when 27; '携帯電話'
    when 28; '乗継精算機'
    when 29; '連絡改札機'
    when 31; '簡易入金機'
    when 70; 'VIEW ALTTE'
    when 72; 'VIEW ALTTE'
    when 199; '物販端末'
    when 200; '自販機'
    else '???'
    end
  end
  
  # 処理名
  def get_proc_type(proc)
    case proc
    when 1; '運賃支払(改札出場)'
    when 2; 'チャージ'
    when 3; '券購(磁気券購入)'
    when 4; '精算'
    when 5; '精算 (入場精算)'
    when 6; '窓出 (改札窓口処理)'
    when 7; '新規 (新規発行)'
    when 8; '控除 (窓口控除)'
    when 13; 'バス (PiTaPa系)'
    when 15; 'バス (IruCa系)'
    when 17; '再発 (再発行処理)'
    when 19; '支払 (新幹線利用)'
    when 20; '入A (入場時オートチャージ)'
    when 21; '出A (出場時オートチャージ)'
    when 31; '入金 (バスチャージ)'
    when 35; '券購 (バス路面電車企画券購入)'
    when 70; '物販'
    when 72; '特典 (特典チャージ)'
    when 73; '入金 (レジ入金)'
    when 74; '物販取消'
    when 75; '入物 (入場物販)'
    when 198; '物現 (現金併用物販)'
    when 203; '入物 (入場現金併用物販)'
    when 132; '精算 (他社精算)'
    when 133; '精算 (他社入場精算)'
    else '???'
    end
  end
  
  # 日付文字列 (先頭から7ビットが年、４ビットが月、残り５ビットが日)
  # YYYY:MM:DD フォーマットとする
  def get_date_string(date)
    # 年は20XXに補正する
    year = (date >> 9) + 2000
    month = (date >> 5) & 0xf
    day = (date & 0x1f)
    return sprintf('%04d/%02d/%02d', year, month, day )
  end
  
  # 時刻文字列 (先頭から5ビットが時、6ビットが分、残り５ビットが秒？)
  # hh:mm フォーマットとする
  def get_time_string(time)
    hour = (time >> 11)
    minute = (time >> 5) & 0x3f
    seconds = (time & 0x1f)
    return sprintf('%02d:%02d', hour, minute)
  end
  
  # 残高文字列
  # カンマ区切りで単位を'円'にする
  def get_balance_string(balance)
    return balance.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,') + '円'
  end
  
  # エリアコード取得
  def get_areacode(linecode, region)
    # 線区が 0x7f 以下のとり : 0 (JR線)
    return 0 if linecode < 0x7F
    # 線区が 0x80 以上でリージョンが 0 のとき : 1 (関東公営・私鉄)
    return 1 if region == 0
    # 線区が 0x80 以上でリージョンが 1 のとき : 2 (関西公営・私鉄)
    return 2
  end
  
end
