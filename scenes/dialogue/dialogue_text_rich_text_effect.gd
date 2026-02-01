extends RichTextEffect


var bbcode = "dialogue_text"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var start_time_msec := int(char_fx.env.start_time)
	var alpha := ease(clampf((Time.get_ticks_msec() - start_time_msec) / 1000.0 - char_fx.relative_index * 0.01, 0.0, 1.0), 0.2)
	char_fx.color.a *= alpha
	char_fx.transform = char_fx.transform.translated(Vector2(
		ease(clampf((Time.get_ticks_msec() - start_time_msec) / 1000.0 - char_fx.relative_index * 0.01, 0.0, 1.0), 0.2) * 10.0,
		0.0,
	))

	return true
