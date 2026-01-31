extends Dialogue

func dialogue() -> Array[DialogueOption]:
	await show("hi")
	await show("hi")
	await show("hi")
	await show("hi")
	await show("hi")
	await show("hi")
	await show("hi")
	await show("hi")
	return [
		DialogueOption.new("Option 1", _option_1),
	]


func _option_1() -> Array[DialogueOption]:
	await show("HELLO")
	return []
