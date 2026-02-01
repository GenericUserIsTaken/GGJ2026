@tool
class_name MaskPartGrid extends VBoxContainer


signal part_hovered(part: MaskPart)
signal submitted


@onready var hover_stats_display: StatsDisplay = %HoverStatsDisplay
@onready var submit_button: Button = %SubmitButton
@onready var part_type_container: VBoxContainer = %PartTypeContainer


func _ready() -> void:
	var parts := scan_for_parts()
	var part_containers: Dictionary[MaskPart.Type, PartContainer]
	for part in parts:
		if part.type not in part_containers:
			part_containers[part.type] = PartContainer.new()
			part_containers[part.type].container = HFlowContainer.new()
			part_containers[part.type].button_group = ButtonGroup.new()
			part_containers[part.type].button_group.allow_unpress = true
			part_type_container.add_child(part_containers[part.type].container)
		var part_container := part_containers[part.type]
		var tile := Button.new()
		tile.icon = part.texture
		tile.mouse_entered.connect(part_hovered.emit.bind(part))
		tile.button_group = part_container.button_group
		tile.toggle_mode = true
		part_container.container.add_child(tile)
	part_hovered.connect(func(part: MaskPart): hover_stats_display.show_stats(part.stats))
	submit_button.pressed.connect(submitted.emit)


func scan_for_parts(base_dir: String = "res://resources/parts/") -> Array[MaskPart]:
	var array: Array[MaskPart]
	for entry in ResourceLoader.list_directory(base_dir):
		if entry.ends_with("/"):
			array.append_array(scan_for_parts(base_dir.path_join(entry)))
		else:
			var resource := load(base_dir.path_join(entry)) as MaskPart
			if resource:
				array.append(resource)
	return array


class PartContainer:
	var container: HFlowContainer
	var button_group: ButtonGroup
