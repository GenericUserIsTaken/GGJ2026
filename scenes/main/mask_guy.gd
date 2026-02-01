class_name MaskGuy extends Node3D


@onready var part_sprites: Dictionary[MaskPart.Type, Sprite3D] = {
	MaskPart.Type.MASK: %MaskSprite,
	MaskPart.Type.FOREHEAD: %ForeheadSprite,
	MaskPart.Type.EYE: %EyeSprite,
	MaskPart.Type.MOUTH: %MouthSprite,
	MaskPart.Type.DECORATION: %DecorationSprite,
}
@onready var boss_mask_container: Node3D = %BossMaskContainer


func load_parts(parts: MaskParts) -> void:
	for part in part_sprites:
		if part in parts.parts:
			part_sprites[part].texture = parts.parts[part].texture
		else:
			part_sprites[part].texture = null

func change_mask_vis(to : bool) -> void:
	%MaskSprite.visible = to
	%ForeheadSprite.visible = to
	%EyeSprite.visible = to
	%MouthSprite.visible = to
	%DecorationSprite.visible = to

func load_visuals_from_hit_type(type : HitTime.HitType) -> void:
	pass

func set_boss_mode(is_boss: bool) -> void:
	boss_mask_container.visible = is_boss
	boss_mask_container.rotation.y = 0.0

var _tween: Tween = null

func animate_boss(is_happy: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(boss_mask_container, "rotation_degrees:y", is_happy * -65.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await _tween.finished
