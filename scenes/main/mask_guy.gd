class_name MaskGuy extends Node3D


@export var part_sprites: Dictionary[MaskPart.Type, Sprite3D]


func load_parts(parts: MaskParts) -> void:
	for part in parts.parts:
		var texture := parts.parts[part].texture
		part_sprites[part].texture = texture
