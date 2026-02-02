extends Dialogue


func dialogue_setup() -> void:
	guy.setup_as_boss()


func dialogue() -> Array[DialogueOption]:
	await guy.animate_midhappy()
	await show("That is all, citizen.")
	await guy.animate_unhappy()
	await show("Unfortunately, one has identified that your extended contact with flaw has compromised you.")
	return [
		DialogueOption.new("I am not flawed!", _dialogue_configure),
		DialogueOption.new("Great Boss, you cannot do this to me!", _dialogue_configure),
		DialogueOption.new("I am honored to serve.", _dialogue_configure),
	]


func _dialogue_configure() -> Array[DialogueOption]:
	await show("Hold still, it is time for your own [emph]ascension.[/emph]")
	await dialogue_window.animate_overlay()
	dialogue_window.get_tree().quit(0xdead)
	return []
