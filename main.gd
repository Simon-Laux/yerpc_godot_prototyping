extends Control

var transport = load("res://scripts/WebsocketTransport.gd").new()
var rpc_remote: RPCRemote = load("res://scripts/rpc.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(transport)
	rpc_remote.transport = transport
	await transport.connected
	load_messages()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var text = $HBoxContainer/msginput.text
	var user = RPCRemote.User.new(
		$Panel/color.text , $Panel/name.text
	)
	var msg = RPCRemote.ChatMessage.new(
		text, user
	)
	$HBoxContainer/msginput.clear()
	var result = await rpc_remote.send(msg)
	if result.is_ok:
		print("Got back: ", rpc_remote.type_result.send(result))
	else:
		printerr("Got error back: ", result)
	
	load_messages()
	pass

func load_messages():
	var result = await rpc_remote.list()
	if result.is_ok:
		var list := rpc_remote.type_result.list(result)
		var new_text = ""
		for msg in list:
			new_text += "[" + msg.user.name + "]: " + msg.content + "\n"
		$RichTextLabel.text = new_text
		$RichTextLabel.scroll_following = true
	else:
		printerr("Got error back: ", result)
	
