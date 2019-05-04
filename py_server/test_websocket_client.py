# coding: utf-8
from websocket import create_connection
# ws = create_connection("ws://192.168.2.103:9001/")
ws = create_connection("ws://localhost:9001/")
print("Sending 'Hello, World'...")
ws.send("Hello, World1")
# ws.send("Hello, World2")
print("Sent")
print("Receiving...")
result =  ws.recv()
print("Received '%s'" % result)
ws.close()
