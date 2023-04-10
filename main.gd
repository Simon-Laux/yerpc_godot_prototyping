extends Control

var transport = load("res://scripts/WebsocketTransport.gd").new()
var rpc_remote: RPCRemote = load("res://scripts/rpc.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(transport)
	rpc_remote.transport = transport


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
	print("Got back: ", result)
	
	print(await rpc_remote.list())
	pass
