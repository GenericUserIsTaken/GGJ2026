class_name ContinueIndicator extends TextureRect

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

var tween: Tween = null

func _ready() -> void:
	modulate.a = 0.0

func animate_in() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	modulate.a = 0.0
	position.x = -20.0
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 1.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:x", 0.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.chain().tween_callback(animation_player.play.bind("bob_indicator"))

func animate_out() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel()
	tween.tween_callback(animation_player.stop)
	tween.tween_property(self, "modulate:a", 0.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:x", 20.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
