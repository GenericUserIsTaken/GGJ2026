class_name MaskGuy extends Node3D


@onready var part_sprites: Dictionary[MaskPart.Type, Sprite3D] = {
	MaskPart.Type.MASK: %MaskSprite,
	MaskPart.Type.FOREHEAD: %ForeheadSprite,
	MaskPart.Type.EYE: %EyeSprite,
	MaskPart.Type.MOUTH: %MouthSprite,
	MaskPart.Type.DECORATION: %DecorationSprite,
}
@onready var boss_mask_container: Node3D = %BossMaskContainer
@onready var sphere: MeshInstance3D = %Sphere
@onready var cube: MeshInstance3D = %Cube


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
	self.change_texture_color(MaskManager.get_texture_color_for_type(type))
	if(MaskManager.get_mask_for_type(type) == null):
		push_warning("NO MASK FOR TYPE ", type, " IS SET, MAKE SURE TO SET IT IN DIALOGUE")
		return
	self.load_parts(MaskManager.get_mask_for_type(type))
	

func change_texture_color(color : Color) -> void:
	for obj: MeshInstance3D in [sphere, cube]:
		if obj.material_override == null:
			obj.material_override = obj.mesh["surface_0/material"].duplicate()
		(obj.material_override as StandardMaterial3D).albedo_color = color

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
