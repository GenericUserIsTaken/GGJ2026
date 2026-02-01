extends RichTextEffect


var bbcode := "dialogue_response"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color.a *= 0.5
	var y := _get_y(fmod(char_fx.elapsed_time - char_fx.relative_index * 0.1, 1.0))
	char_fx.transform = Transform2D(0.0, Vector2.ONE, 0.2, Vector2(10.0, y * -5.0)) * char_fx.transform
	return true


func _get_y(time: float) -> float:
	var a := -4.0 * (time - 0.5) ** 2 + 1
	#var b := -4.0 * (time - sqrt(1/8.0) - 1.0) ** 2 + 0.5
	#var c := -4.0 * (time - sqrt(1/16.0) - sqrt(0.5) - 0.5) ** 2 + 0.25
	#return maxf(maxf(maxf(a, b), c), 0.0)
	return maxf(a, 0.0)
