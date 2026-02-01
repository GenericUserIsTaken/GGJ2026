extends Dialogue


var tl_options: Array[DialogueOption] = [
	DialogueOption.new("Option 0", _option_n.bind(0)),
	DialogueOption.new("Option 1", _option_n.bind(1)),
	DialogueOption.new("Option 2", _option_n.bind(2)),
	DialogueOption.new("Option 3", _option_n.bind(3)),
]


func dialogue() -> Array[DialogueOption]:
	await show("I am in a bit of a pickle")
	await show("I am in a bit of a pickle")
	await show("I am in a bit of a pickle")
	await show("I am in a bit of a pickle")
	await show("I am in a bit of a pickle")
	return tl_options


func _option_n(n: int) -> Array[DialogueOption]:
	tl_options[n].disable()
	await show("You picked %s" % n)
	return [DialogueOption.new("Go back", dialogue)]
