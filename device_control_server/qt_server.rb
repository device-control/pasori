# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'em-websocket'
require 'Qt4'
require 'server_widget'
require 'ic_card_device'

require 'pry'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

KEEP_ALIVE_TIMEOUT = 10*60 # 10 minutes (この時間無応答ならコネクションを切断する)


# ICカードデバイス制御
ic_card_device = ICCardDevice.new

app = Qt::Application.new(ARGV)
widget = ServerWidget.new
widget.ic_card_device = ic_card_device
widget.show
# app.exec
widget.ui['label_user_msg'].text = '起動完了っす！'

# メインスレッド
EM.run do
  # app.exec
  EM.add_periodic_timer(0.01) do
    app.process_events
    # qt 終了イベントを受信して、EM::stop とかやらんとスレッド残る。ゾンビ化する。。。きっと
    # これどうしよう。。。
  end
  
  
  connections = Hash.new # 接続情報保持用
  # EM::WebSocket.start(host: "127.0.0.1", port: widget.parameter['contents']['port']) do |ws_conn|
  EM::WebSocket.start(host: widget.parameter['contents']['ip'], port: widget.parameter['contents']['port']) do |ws_conn|
    
    # IC カード読み込み
    ic_card_read = proc do
      # 別スレッドで実行される
      ic_card_device.read
    end
    
    # IC カード読み込み完了
    ic_card_read_callback = proc do |res|
      # メインスレッドで実行される
      puts res
      ws_conn.send(res)
      
      if res == ''
        text = '読み込み失敗！'
      else
        text = '読み込み完了！'
      end
      widget.ui['label_user_msg'].text = text
    end
    
    # 接続受信
    ws_conn.onopen do
      puts "event[onopen] : open #{ws_conn.signature}"
      params = Hash.new
      params[:ws_conn] = ws_conn # コネクション情報は全部保持
      params[:alive_timer] = set_alive_timer(ws_conn) # n分間接続なければ切断
      connections[ws_conn.signature] = params
    end
    
    # メッセージ受信
    ws_conn.onmessage do |message|
      params = connections[ws_conn.signature]
      params[:alive_timer].cancel # alive_timer クリア
      # params[:ws_conn].send("カード情報はあほあほです") # 接続してきたやつに応答を返す。
      # 
      # TODO: デバイスが空いてたらばICカード読み込みか書き込み(factory+state_machineでやりたいね。。。)
      widget.ui['label_user_msg'].text = 'カードかざしてくれ！'
      widget.wlog(message)
      EM.defer(ic_card_read, ic_card_read_callback)
      params[:alive_timer] = set_alive_timer(ws_conn)
    end
    
    # 切断受信
    ws_conn.onclose do
      puts "event[onclose] : socket close signature[#{ws_conn.signature}]"
      # ws_conn.close
    end
    
  end
  
  # 生存タイマを張る
  def set_alive_timer(ws_conn)
    p = EM::Timer.new(KEEP_ALIVE_TIMEOUT) do
      puts "timeout : socket close signature[#{ws_conn.signature}]"
      ws_conn.close
    end
    return p
  end

end
