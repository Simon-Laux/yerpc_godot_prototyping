# Open questions

## How to do error handling in Godot?

jsonrpc apis can have errors, how should we design the api?

- Godot does not have exceptions, so no throw try catch (which is not the nicest pattern anyway)
- Godot does not have Generics in types as far as I can tell, so rust's Result route would break the return types of our api.

#### Solution ideas

##### using Result classes:

on the backend it could look like this:

```gdscript
func list() -> Result:
	var raw_result: Result = await transport.invoke_api("list", [])
	if raw_result.is_ok:
		return Result.Ok.new(ChatMessage.array_from_generic_array((raw_result as Result.Ok).result))
	else:
		return raw_result
```

and when using it it would look like this:

```gdscript
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
```

Not very pretty and we loose return type but it works. Look at the `result_type` branch for the rest of the code.


##### using Result classes with more helper functions:
We can make the code a bit easier to write:
- adding a `_to_string()` function to the error so it can be logged without casting
- generate a helper function for each api funtion that casts to its return type

With that tweaking, we could get it down to:
```
var result = await rpc_remote.send(msg)
if result.is_ok:
	print("Got back: ", type_result.send(result))
else:
	printerr("Got error back: ", result)

var result2 = await rpc_remote.list()
if result2.is_ok:
	print("Msg List: ", type_result.list(result2))
else:
	printerr("Got error back: ", result2)
```

Look at the `result_type_tweaked` branch for an example of this.
I would call it rather usable.


### How to represent Rust Enums (with data)

probably a base class (with the shared fields?) that is implemented by multiple other classes and check with `is` operator before using it.

We can use the `as` operator for casting, docs says that it returns `null` when it fails.

> If the value is not a subtype, the casting operation will result in a null value.
