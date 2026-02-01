extends Dialogue


const MASK_BUILD_1_STATS = preload("uid://c1amdablx2rgi")


func dialogue_setup() -> void:
	guy.reset()


func dialogue() -> Array[DialogueOption]:
	await show("Hello, the Great 30th Overseer sent me here. What is happening?")
	return [
		DialogueOption.new("Hello, first provide your information.", _dialogue_1),
		DialogueOption.new("Tell me your name.", _dialogue_1),
	]


func _dialogue_1() -> Array[DialogueOption]:
	await show("My name is Wisam. I am from the 30th district.")
	await show("Is this a new format of enrichment activity?")
	return [
		DialogueOption.new("I can help you, Wisam.", _dialogue_2.bind("You are here because you must have flaw.")),
		DialogueOption.new("We must free you from flaw.", _dialogue_2.bind("Answer my questions so you may return to equilibrium.")),
	]


var dialogue_ops: Array[DialogueOption] = [
	DialogueOption.new("(Loyalty) Has your faith in our utopia faltered?", _dialogue_reveal.bind(0)),
	DialogueOption.new("(Mental) Has your persistence waivered?", _dialogue_reveal.bind(1)),
	DialogueOption.new("(Emotional) Have your senses warped?", _dialogue_reveal.bind(2)),
	DialogueOption.new("(Physical) Let me analyze your profile.", _dialogue_reveal.bind(3)),
]


func _dialogue_2(starting_text: String) -> Array[DialogueOption]:
	await show_from_player(starting_text)
	await show_from_player("The Great Boss has granted me the means to [emph]cure[/emph] it.")
	await show("I am...")
	await show("[emph]flawed?[/emph]")
	await show("I have not committed any sin! Please believe me!")
	await show_from_player("Have faith. Answer my questions so that we may discover the root of this.")
	return dialogue_ops


func _dialogue_reveal(id: int) -> Array[DialogueOption]:
	dialogue_ops[id].disable()
	match id:
		0:
			pass
		1:
			pass
		2:
			pass
		3:
			pass
	if not Util.any_options_enabled(dialogue_ops):
		await show_from_player("Pick elements from the left so that their combination satisfies Wisam's ascension requirements.")
	return dialogue_ops


func dialogue_end() -> void:
	var config := await dialogue_window.show_mask_config(MASK_BUILD_1_STATS)
	MaskManager.mask_1 = config
