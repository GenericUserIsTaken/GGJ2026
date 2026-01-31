class_name DialogueOption


var option_title: String
var option_callback: Callable


func _init(
	_option_title: String,
	_option_callback: Callable,
) -> void:
	option_title = _option_title
	option_callback = _option_callback
