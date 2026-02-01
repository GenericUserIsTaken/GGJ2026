class_name DialogueGuyScene extends Node3D

@onready var mask_guy: MaskGuy = %MaskGuy

func set_mask_parts(mask_parts: MaskParts) -> void:
	mask_guy.load_parts(mask_parts)
