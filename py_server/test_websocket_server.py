# coding: utf-8
from websocket_server import WebsocketServer
import time

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
    # time.sleep(5)
    # 送信してきたクライアントにメッセージ送信
    server.send_message(client, "message received!!")

PORT=9001
server = WebsocketServer(PORT)
server.set_fn_new_client(new_client)
server.set_fn_client_left(client_left)
server.set_fn_message_received(message_received)
server.run_forever()
