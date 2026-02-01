class_name DialogueGuyScene extends Node3D


@onready var mask_guy: MaskGuy = %MaskGuy


func set_mask_parts(mask_parts: MaskParts) -> void:
	mask_guy.load_parts(mask_parts)


func setup_as_boss() -> void:
	mask_guy.set_boss_mode(true)


func animate_unhappy() -> void:
	await mask_guy.animate_boss(false)


func animate_happy() -> void:
	await mask_guy.animate_boss(true)


func reset() -> void:
	set_mask_parts(MaskParts.new())
	mask_guy.set_boss_mode(false)
