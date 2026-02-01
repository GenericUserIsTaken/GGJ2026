class_name MaskGuy extends Node3D


@onready var part_sprites: Dictionary[MaskPart.Type, Sprite3D] = {
	MaskPart.Type.MASK: %MaskSprite,
	MaskPart.Type.FOREHEAD: %ForeheadSprite,
	MaskPart.Type.EYE: %EyeSprite,
	MaskPart.Type.MOUTH: %MouthSprite,
	MaskPart.Type.DECORATION: %DecorationSprite,
}


func load_parts(parts: MaskParts) -> void:
	for part in part_sprites:
		if part in parts.parts:
			part_sprites[part].texture = parts.parts[part].texture
		else:
			part_sprites[part].texture = null
