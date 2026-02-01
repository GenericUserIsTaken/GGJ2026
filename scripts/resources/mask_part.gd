class_name MaskPart extends Resource


enum Type {
	FOREHEAD,
	EYE,
	MOUTH,
	DECAL,
	DECORATION,
}


@export var type: Type
@export var icon: Texture2D
@export var mesh: Mesh
@export var stats: MaskStats
@export var name: String
@export var id: String
