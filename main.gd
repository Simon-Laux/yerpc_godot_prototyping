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
	if result.is_ok:
		print("Got back: ", (result as Result.Ok).result as int)
	else:
		printerr("Got error back: ", (result as Result.Err).message)
	
	var result2 = await rpc_remote.list()
	if result2.is_ok:
		print("Msg List: ", (result2 as Result.Ok).result as Array[RPCRemote.ChatMessage])
	else:
		printerr("Got error back: ", (result2 as Result.Err).message)
	
	pass
