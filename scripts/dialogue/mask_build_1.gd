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
	return _get_dialoge_ops()


func _dialogue_reveal(id: int) -> Array[DialogueOption]:
	dialogue_ops[id].disable()
	match id:
		0:
			await show("I would never!")
			await show("…But, there was this one time where I did not attend my enrichment activity of the day.")
			await show("That doesn’t mean I have lost faith!")
			return [DialogueOption.new("Why did you not attend the enrichment?", _dialogue_reveal_0_1), DialogueOption.new("Avoiding equilibrium exercises…", _dialogue_reveal_0_1)]
		1:
			await show("My spirits are as normal as the others. I have no strains or need for rest.")
		2:
			await show("My spirits are as normal as the others. I have no strains or need for rest.")
		3:
			await show("My body remains at equilibrium, as it ever has.")
	await tutorial()
	return _get_dialoge_ops()


func _dialogue_reveal_0_1() -> Array[DialogueOption]:
	await show("Wait, I can explain!")
	await show("I was in the 31st district, but unable to return to the 30th in time.")
	await show("…")
	await show("It was for a meeting with another that I seeked discussion with.")
	await show_from_player("+ Uncovered flaw: (Loyalty) Disobedience of an Overseer")
	return [
		DialogueOption.new("Have your senses warped?", _dialogue_reveal_0_2),
		DialogueOption.new("You went to see another.", _dialogue_reveal_0_2),
	]


func _dialogue_reveal_0_2() -> Array[DialogueOption]:
	await show("[Wisam] Yes… I admit that I have met in secret with them for a long time.")
	await show("[Wisam] Please! Hear my admission in the light of equilibrium!")
	await show("[Wisam] I feel so drawn to them, I cannot explain it. When they are around, my equilibrium is beyond perfect!")
	await show_from_player("+ Uncovered flaw: (Emotional) Unpermitted relationship")
	await tutorial()
	return _get_dialoge_ops()


func _get_dialoge_ops() -> Array[DialogueOption]:
	var aaaa: Array[DialogueOption] = [
		DialogueOption.new("Pick elements", _dialogue_configure),
	]
	return dialogue_ops if Util.any_options_enabled(dialogue_ops) else aaaa


func _dialogue_configure() -> Array[DialogueOption]:
	var config := await dialogue_window.show_mask_config(MASK_BUILD_1_STATS)
	MaskManager.mask_1 = config
	guy.setup_as_boss()
	guy.animate_happy()
	await dialogue_window._animate(DialogueWindow.OptionsState.OPTIONS_HIDDEN)
	await show("[Boss] Well done citizen. There are many like this one.")
	guy.animate_unhappy()
	await show("As one said, one cannot hold them back forever.")
	guy.animate_midhappy()
	await show("These citizens will be released in a line to each receive a mask. You must assign them each a mask, before their [emph]flaw[/emph] flares into an uncontrollable state.")
	guy.animate_unhappy()
	await pause(1.0)
	await show("Should you fail to judge them as they pass through, they will be disposed of.")
	guy.animate_happy()
	await show("May your judgement be accurate and precise.")
	guy.animate_midhappy()
	await show("[emph]May our utopia stay equalized.[/emph]")
	return []


func tutorial() -> void:
	if not Util.any_options_enabled(dialogue_ops):
		await show("...")
		await show("Will I be alright? I possess only small flaw, correct?")
		await pause(1.0)
		await show_from_player("Pick elements from the left so that their combination satisfies Wisam's ascension requirements.")
