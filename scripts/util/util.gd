class_name Util


static func unused(..._v) -> void: pass


static func any_options_enabled(options: Array) -> bool:
	return options.any(func(it: DialogueOption): return not it.disabled)


static func any_options_enabled_d(options: Dictionary) -> bool:
	return options.values().any(func(it: DialogueOption): return not it.disabled)
