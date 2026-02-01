extends Dialogue


func dialogue_setup() -> void:
	guy.setup_as_boss()


func dialogue() -> Array[DialogueOption]:
	guy.animate_midhappy()
	await show("[Boss] Hello citizen. I have summoned you here")
	return [
		DialogueOption.new("Hello Great Boss!", _dialogue_2),
		DialogueOption.new("I didn't do anything...", _dialogue_2),
		DialogueOption.new("What's happening?", _dialogue_2),
	]


func _dialogue_2() -> Array[DialogueOption]:
	guy.animate_unhappy()
	await show("Our great utopia is under an ancient threat. One has identified a resurfacing of flaw that has spread to many of your fellow citizens.")
	guy.animate_happy()
	await show("Flaw shows the veins of its infection through the compromise of a citizen’s perspective.")
	guy.animate_midhappy()
	await show("These citizens are no longer able to thrive in our great utopia; this crisis must be confronted at once.")
	return [
		DialogueOption.new("What is my purpose?", _dialogue_3),
		DialogueOption.new("Why are you talking to me?", _dialogue_3),
	]


var dialogue_3_ops: Dictionary[StringName, DialogueOption] = {
	"how": DialogueOption.new("How do I cure them?", _dialogue_4.bind("how")),
	"will": DialogueOption.new("Will I know what to cure?", _dialogue_4.bind("will")),
}


func _dialogue_3() -> Array[DialogueOption]:
	guy.animate_happy()
	await show("You have been selected for your lack of compromised traits. In other words,")
	guy.animate_midhappy()
	await show("You are [emph]perfect[/emph]")
	guy.animate_unhappy()
	await show("One cannot risk oneself contacting the disease that blights this society. Thus, one must task you with an essential mission:")
	await pause(2.0)
	await show("Talk to one of these citizens.")
	guy.animate_happy()
	await show("Understand their flaw.")
	guy.animate_unhappy()
	await show("Cure the many who are like them.")
	guy.animate_midhappy()
	return dialogue_3_ops.values()


func _dialogue_4(id: StringName) -> Array[DialogueOption]:
	if id in dialogue_3_ops:
		dialogue_3_ops[id].disable()
	match id:
		"how":
			guy.animate_happy()
			await show("Using the remains of a divine instrument that freed us from the pre-utopian era, one has forged many elements of ascendance.")
			await show("These elements can be bound together to form a kind of mask once known as an [emph]ascension[/emph].")
			guy.animate_unhappy()
			await show("An ascension binds to the body, and draws flaw away from the soul.")
			return [
				DialogueOption.new("How do I bind them?", _dialogue_how_subdialogue, false),
			]
		"will":	
			guy.animate_unhappy()
			await show("Flaw shows itself in the things a citizen speaks and the way a citizen thinks.")
			guy.animate_happy()
			await show("Do not forget, your judgement is perfect. There is no room for doubt in this task.")
	var to_final_dialogue: Array[DialogueOption] = [DialogueOption.new("...", _final_dialogue)]
	return dialogue_3_ops.values() if Util.any_options_enabled_d(dialogue_3_ops) else to_final_dialogue


func _dialogue_how_subdialogue() -> Array[DialogueOption]:
	guy.animate_happy()
	await show("To bring a soul back to equilibrium, an ascension’s features must jointly embody the flaw they draw out.")
	guy.animate_unhappy()
	await show("Some will need a trait reinforced. Some will need it alleviated.")
	guy.animate_midhappy()
	await show("To do so, you must choose from the forged elements to form a fitting mask.")
	return dialogue_3_ops.values()


func _final_dialogue() -> Array[DialogueOption]:
	guy.animate_unhappy()
	await show("Enough said. A specimen of flaw will be brought before you, understand them thoroughly, then build an ascension.")
	guy.animate_happy()
	await show("A flood of similar flaw must be addressed soon after, one cannot hold them back forever.")
	guy.animate_midhappy()
	await show("[emph]May our utopia stay equalized.[/emph]")
	return []
