# coding: cp932
require "em-websocket"
require "pry"
connections = []
EM::WebSocket.start(host: "172.17.10.58", port: 3001) do |ws_conn|
  ws_conn.onopen do
    # �ڑ����Ă����R�l�N�V�������i�[
    connections << ws_conn
    # binding.pry
  end
  
  ws_conn.onmessage do |message|
    # �S�ẴR�l�N�V�����ɑ΂��ă��b�Z�[�W�𑗐M
    connections.each{|conn| conn.send(message) }
  end
  puts "EM::WebSocket loop."
end

puts "end"
