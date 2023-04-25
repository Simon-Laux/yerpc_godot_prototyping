class_name Result
extends Object


var is_ok: bool
var is_err: bool
	
func _init(is_success):
	self.is_ok = is_success
	self.is_err = not is_success

class Err extends Result:
	var message
	func _init(msg: String):
		message = msg
		super(false)

class Ok extends Result:
	var result
	func _init(result):
		self.result = result
		super(true)
