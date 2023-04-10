extends YerpcBaseTransport

# Our WebSocketClient instance
var socket := WebSocketPeer.new()

func _ready():
	socket.connect_to_url("ws://127.0.0.1:20808/rpc")


func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet =  socket.get_packet()
			#print("Packet: ", packet)
			super.on_message(packet.get_string_from_utf8())
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.
		# todo try reconnecting (backoff algorithm


func send_message(data: Dictionary):
	var json = JSON.stringify(data)
	#print("-> ", json)
	socket.send_text(json)
