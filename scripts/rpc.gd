# this file should represent the goal of what we want to generate
class_name RPCRemote
extends Object

@export var transport:YerpcBaseTransport;

class User:
	var color: String
	var name: String
	
	func _init(newColor:String, newName: String):
		color = newColor
		name = newName
	
	func to_dict():
		return {"color": color, "name": name}
		
	func _to_string():
		return "User<"+ str(name) + ", " + str(color) + "" + ">"
	
	static func from_dict(input: Dictionary):
		return User.new(input.color, input.name)
	
	static func array_from_generic_array(input: Array)-> Array[User]:
		var output: Array[User] = []
		for item in input:
			output.push_back(User.from_dict(item))
		return output

class ChatMessage:
	var content: String 
	var user: User
	
	func _init(newContent: String, newUser: User):
		content = newContent
		user = newUser
	
	func to_dict():
		return {"content": content, "user": user.to_dict()}
	
	func _to_string():
		return "ChatMessage<" + str(user) + ", " + str(content) + ">"
	
	static func from_dict(input: Dictionary):
		return ChatMessage.new(input.content, User.from_dict(input.user))
	
	static func array_from_generic_array(input: Array)-> Array[ChatMessage]:
		var output: Array[ChatMessage] = []
		for item in input:
			output.push_back(ChatMessage.from_dict(item))
		return output



##  Send a chat message.\n\n Pass the message to send.
func send(message: ChatMessage) -> Result:
	return await transport.invoke_api("send", [message.to_dict()])

## List chat messages.
func list() -> Result:
	var raw_result: Result = await transport.invoke_api("list", [])
	if raw_result.is_ok:
		return Result.Ok.new(ChatMessage.array_from_generic_array((raw_result as Result.Ok).result))
	else:
		return raw_result
	




# limitations: because of https://github.com/godotengine/godot-proposals/issues/56 we need to convert from dict to our classes


class type_result:
	static func send(result):
		var typed_result := (result as Result.Ok).result as int
		assert(typed_result != null)
		return typed_result
	
	static func list(result: Result)->Array[RPCRemote.ChatMessage]:
		var typed_result := (result as Result.Ok).result as Array[RPCRemote.ChatMessage]
		assert(typed_result != null)
		return typed_result
		

