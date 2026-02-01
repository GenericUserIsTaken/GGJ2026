@tool
class_name MaskPart extends Resource


enum Type {
	MASK,
	FOREHEAD,
	EYE,
	MOUTH,
	DECORATION,
}


@export var type: Type
@export var texture: Texture2D
@export var stats: MaskStats
@export var name: String
@export var id: String


@export_tool_button("Autofill") var autofill_values := func():
	type = MaskPart.Type[texture.resource_path.get_base_dir().get_file().to_upper()]
	stats = MaskStats.new()
	for stat in MaskStats.stats():
		stats[stat] = roundf(randf_range(-4.0, 4.0))
	name = texture.resource_path.get_file().get_slice(".", 0).to_snake_case().replace("_", " ")
	name = name[0].capitalize() + name.substr(1)
	id = property_get_revert(&"id")


func _init() -> void:
	if id.is_empty() and Engine.is_editor_hint():
		id = property_get_revert(&"id")


func _property_can_revert(property: StringName) -> bool:
	if property == "id":
		return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property == "id":
		return resource_path.trim_prefix("res://resources/parts/").trim_suffix(".tres")
	return null
