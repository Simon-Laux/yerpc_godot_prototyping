class_name YerpcBaseTransport
extends Node

class CallbackObject extends Object:
	signal trigger(return_value)

var invocation_id_counter = 0

var callbacks = {}

func send_message(data: Dictionary):
	print("not implemented")

func on_message(string: String):
	#print("<- ", string)
	# parse json
	var json_object = JSON.new()
	var error = json_object.parse(string)
	if error == OK:
		var data_received = json_object.data
		if typeof(data_received) == TYPE_DICTIONARY:
			# get invocation id
			if data_received.has("id"):
				# call callback with return value
				var callback = callbacks[str(data_received.id)]
				if callbacks:
					if data_received.has("error"):
						callback.emit(Result.Err.new(data_received.error))
					else:
						callback.emit(Result.Ok.new(data_received.result))
				else:
					printerr("error: callback for invocation id", data_received.id, "is not set")
			else:
				print("no invocation id: ",data_received)
			
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json_object.get_error_message(), " in ", string, " at line ", json_object.get_error_line())

	
func invoke_api(method: String, parameters) -> Result:
	invocation_id_counter = invocation_id_counter + 1
	var id = invocation_id_counter
	# compose json
	var request: Dictionary = {"jsonrpc": "2.0", "method": method, "params": parameters, "id": id}
	# register callback
	var callback = Signal(CallbackObject.new(), "trigger")
	callbacks[str(id)] = callback
	# send
	send_message(request)
	# await callback
	var result = await callback
	# cleanup
	callbacks.erase(id)
	return result

func notify(method: String, parameters):
	send_message({"jsonrpc": "2.0", "method": method, "params": parameters})


# todo error handling? what to do about errors?
