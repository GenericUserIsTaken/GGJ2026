extends Dialogue


var tl_options: Array[DialogueOption] = [
	DialogueOption.new("Option 0", _option_n.bind(0)),
	DialogueOption.new("Option 1", _option_n.bind(1)),
	#DialogueOption.new("Option 2", _option_n.bind(2)),
	#DialogueOption.new("Option 3", _option_n.bind(3)),
]


func dialogue() -> Array[DialogueOption]:
	#await show("[lb]Boss[rb] This flaw shows the veins of its infection through the compromise of a citizen’s perspective. They are no longer able to thrive in our great utopia; this crisis must be confronted at once.")
	await show("I am in a bit of a pickle")
	#await _dialogue_window.
	#await show("I am in a bit of a pickle")
	#await show("I am in a bit of a pickle")
	#await show("I am in a bit of a pickle")
	#return tl_options
	return [
		#DialogueOption.new("...", dialogue_2)
	]


func dialogue_2() -> Array[DialogueOption]:
	await show("The next line in the series")
	return tl_options


func _option_n(n: int) -> Array[DialogueOption]:
	tl_options[n].disable()
	await show("You picked %s" % n)
	return [DialogueOption.new("Go back", dialogue)]


func dialogue_end() -> void:
	var stats := MaskStats.new()
	stats.emotional = 2.0
	stats.loyalty = -2.0
	stats.mental = -2.0
	stats.physical = 2.0
	await _dialogue_window.show_mask_config(stats)
