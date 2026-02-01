## One option the player can take once dialogue has been shown.
## This is how the branching structure is created: each [DialogueOption] holds a [member option_callback],
## which points to the next dialogue function to call.
class_name DialogueOption


var option_title: String
## [code]func(): Array[DialogueOption][/code]
var option_callback: Callable
var disabled: bool = false
var hide_if_last_option: bool = true


func _init(
	_option_title: String,
	_option_callback: Callable,
	_hide_if_last_option: bool = true,
) -> void:
	option_title = _option_title
	option_callback = _option_callback
	hide_if_last_option = _hide_if_last_option


func disable() -> void:
	disabled = true
