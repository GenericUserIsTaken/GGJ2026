@tool
class_name MaskPartGrid extends VBoxContainer


signal part_hovered(part: MaskPart)
signal part_hover_exited
signal submitted(parts: MaskParts)
signal mask_parts_changed(new_parts: MaskParts)


@onready var hover_stats_display: StatsDisplay = %HoverStatsDisplay
@onready var submit_button: Button = %SubmitButton
@onready var part_type_container: VBoxContainer = %PartTypeContainer
@onready var part_title_label: Label = %PartTitleLabel
@onready var part_hover_container: VBoxContainer = %PartHoverContainer


var parts := scan_for_parts()
var current_parts: MaskParts
var target_stats: MaskStats


@export var total_stats_display: StatsDisplay


func _ready() -> void:
	part_hovered.connect(func(part: MaskPart):
		part_title_label.text = part.name
		animate_part_stats_display_in()
		hover_stats_display.show_stats(part.stats)
	)
	part_hover_container.modulate.a = 0.0
	part_hover_exited.connect(animate_part_stats_display_out)
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


func reset() -> void:
	current_parts = MaskParts.new()
	make_parts()
	total_stats_display.show_placeholder_stats(target_stats)


func make_parts() -> void:
	for child in part_type_container.get_children():
		child.queue_free()
	var part_containers: Dictionary[MaskPart.Type, PartContainer]
	for part in parts:
		if not part.enabled:
			continue
		if part.type not in part_containers:
			part_containers[part.type] = PartContainer.new()
			part_containers[part.type].container = HFlowContainer.new()
			part_containers[part.type].button_group = ButtonGroup.new()
			part_containers[part.type].button_group.allow_unpress = true
			part_type_container.add_child(part_containers[part.type].container)
			var separator := HSeparator.new()
			separator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			part_type_container.add_child(separator)
		var part_container := part_containers[part.type]
		var tile := Button.new()
		var img := part.texture.get_image()
		img.decompress()
		img.resize(img.get_width() / 2, img.get_height() / 2, Image.INTERPOLATE_CUBIC)
		img.resize(img.get_width() * 2, img.get_height() * 2, Image.INTERPOLATE_NEAREST)
		tile.icon = ImageTexture.create_from_image(img)
		tile.mouse_entered.connect(part_hovered.emit.bind(part))
		tile.mouse_exited.connect(part_hover_exited.emit)
		tile.button_group = part_container.button_group
		tile.toggle_mode = true
		tile.toggled.connect(func(on: bool):
			if on:
				current_parts.add_part(part)
			else:
				current_parts.remove_part(part.type)
			mask_parts_changed.emit(current_parts)
			total_stats_display.show_stats(current_parts.get_cumulative_stats())
			check_valid()
		)
		part_container.container.add_child(tile)
	#var last_child := part_type_container.get_child(-1) as HSeparator
	#if last_child:
		#last_child.queue_free()


func check_valid() -> void:
	submit_button.disabled = not current_parts.is_valid()


var stats_tween: Tween


func animate_part_stats_display_in() -> void:
	if stats_tween:
		stats_tween.kill()
	stats_tween = create_tween()
	stats_tween.tween_property(part_hover_container, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func animate_part_stats_display_out() -> void:
	if stats_tween:
		stats_tween.kill()
	stats_tween = create_tween()
	stats_tween.tween_interval(0.5)
	stats_tween.tween_property(part_hover_container, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


class PartContainer:
	var container: HFlowContainer
	var button_group: ButtonGroup
