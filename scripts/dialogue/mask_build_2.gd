extends Dialogue


const MASK_BUILD_2_STATS = preload("uid://b6myfxduwxlpb")


func dialogue_setup() -> void:
	guy.setup_as_boss()


func dialogue() -> Array[DialogueOption]:
	await guy.animate_midhappy()
	await show("[Boss] I have brought you a new specimen of flaw recently identified. Please understand how it harms these citizens.")
	await pause(2.0)
	guy.reset()
	await show("[Citizen] Hello.")
	await show("Because of time restraints, you suddenly know I have mental and physical flaw.")
	return [
		DialogueOption.new("Okay", _dialogue_configure),
	]


func _dialogue_configure() -> Array[DialogueOption]:
	var config := await dialogue_window.show_mask_config(MASK_BUILD_2_STATS)
	MaskManager.mask_2 = config
	guy.setup_as_boss()
	await dialogue_window._animate(DialogueWindow.OptionsState.OPTIONS_HIDDEN)
	guy.animate_midhappy()
	await show("Good work, citizen. There are many of both types of flaw you have uncovered that must be dealt with, urgently. Prepare yourself.")
	guy.animate_unhappy()
	await show("Should you fail to judge them as they pass through, they will be disposed of.")
	guy.animate_happy()
	await show("May your judgement be accurate and precise.")
	guy.animate_midhappy()
	await show("[emph]May our utopia stay equalized.[/emph]")
	return []
