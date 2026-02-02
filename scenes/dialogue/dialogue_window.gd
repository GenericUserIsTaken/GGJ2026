@tool
extends Control


enum OptionsState {
	HIDDEN,
	OPTIONS_HIDDEN,
	OPTIONS_SHOWN,
	MASK,
}


signal dialogue_started
signal dialogue_options_shown
signal dialogue_advanced(option_picked: DialogueOption)
signal dialogue_ended

signal selected_option_changed(new_selected_option: int)


@onready var _options_outer_container: PanelContainer = %OptionsOuterContainer
@onready var _options_container: PanelContainer = %OptionsContainer
@onready var _options_vbox: Container = %OptionsGrid
@onready var _transcript: VBoxContainer = %Transcript
@onready var _transcript_scroll_container: ScrollContainer = %TranscriptScrollContainer
@onready var _left_side_container: VBoxContainer = %LeftSideContainer
@onready var _center_spacer_control: Control = %CenterSpacerControl
@onready var _left_top_spacer_control: Control = %LeftTopSpacerControl
@onready var _transcript_container: PanelContainer = %TranscriptContainer
@onready var _continue_indicator: ContinueIndicator = %ContinueIndicator
@onready var _mask_vbox: VBoxContainer = %MaskGrid
@onready var _stats_display_container: Control = %StatsDisplayContainer
@onready var _mask_grid: MaskPartGrid = %MaskGrid
@onready var _guy_container: SubViewportContainer = %GuyContainer
@onready var dialogue_mask_guy: DialogueGuyScene = $GuyContainer/SubViewport/DialogueMaskGuy
@onready var overlay: ColorRect = %Overlay


@export_tool_button("Animate to hidden", "Tween") var animate_to_state_hidden := _animate.bind(OptionsState.HIDDEN)
@export_tool_button("Animate to options hidden", "Tween") var animate_to_state_options_hidden := _animate.bind(OptionsState.OPTIONS_HIDDEN)
@export_tool_button("Animate to dialogue options", "Tween") var animate_to_state_dialogue_options := _animate.bind(OptionsState.OPTIONS_SHOWN)
@export_tool_button("Animate to mask config", "Tween") var animate_to_state_mask := _animate.bind(OptionsState.MASK)


@export var transition_type: Tween.TransitionType
@export var soft_transition_type: Tween.TransitionType
@export var easing_type: Tween.EaseType


var selected_option: int:
	set(value):
		selected_option = value
		selected_option_changed.emit(value)
var displayed_options: Array[DialogueOption]
var active_dialog: Dialogue = null
var _option_widgets: Array[DialogueOptionWidget]

var _text_timer: SceneTreeTimer = null
var _dialogue_skipped: bool = false

## Whether new dialogue is actively being shown.
var is_dialogue_running: bool = false


func _fix_tree_order() -> void:
	get_parent().move_child(self, get_parent().get_child_count() - 1)


func _ready() -> void:
	if Engine.is_editor_hint() and get_parent() == get_tree().root:
		hide()
	selected_option_changed.connect(
		func(selected: int):
			var i := 0
			for option in _option_widgets:
				option.set_selected(selected == i)
				i += 1
	)
	if not Engine.is_editor_hint():
		custom_minimum_size = Vector2(1280, 720)
		_animate(OptionsState.HIDDEN, 0.0)
		hide()
		_continue_indicator.animate_out()
		await get_parent().ready
		_fix_tree_order()
	_left_top_spacer_control.resized.connect(func(): if not _tween or not _tween.is_running(): _interpolate_guy())
	_center_spacer_control.resized.connect(func(): if not _tween or not _tween.is_running(): _interpolate_guy())


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	var next_selectable_option := _can_advance_selected_option(1)
	var prev_selectable_option := _can_advance_selected_option(-1)
	if is_dialogue_running:
		pass
	elif event.is_action_pressed("ui_down", true) and next_selectable_option != selected_option:
		get_viewport().set_input_as_handled()
		selected_option = next_selectable_option
	elif event.is_action_pressed("ui_up", true) and prev_selectable_option != selected_option:
		get_viewport().set_input_as_handled()
		selected_option = prev_selectable_option
	if event.is_action_pressed("ui_accept", true):
		if _text_timer:
			_dialogue_skipped = true
			_text_timer.time_left = 0.0
			get_viewport().set_input_as_handled()
		elif is_dialogue_running:
			pass
		elif _is_any_option_available() == -1 and active_dialog != null:
			get_viewport().set_input_as_handled()
			_continue_indicator.animate_out()
			await active_dialog.dialogue_end()
			dialogue_ended.emit()
			_animate(OptionsState.HIDDEN)
		elif active_dialog != null:
			get_viewport().set_input_as_handled()
			_select_option(selected_option)

## Show a [Dialogue] option.
## [br]
## This handles animating the visibility of the dialogue overlay, then starts at [param dialogue]'s [method Dialogue.dialogue] entry point.
## A set of options is then shown to the user once it finishes, allowing the user to choose between which of the next dialogues to show.
func show_dialogue(dialogue: Dialogue) -> void:
	if _tween.is_running():
		await _tween.finished
	dialogue.dialogue_window = self
	dialogue.dialogue_setup()
	active_dialog = dialogue
	_animate(OptionsState.OPTIONS_HIDDEN)
	dialogue_started.emit()
	_show_dialogue_func(dialogue.dialogue)

## Clear the _transcript view.
## This doesn't do any sort of animation.
func clear_transcript() -> void:
	for child in _transcript.get_children():
		child.queue_free()


var _tween: Tween = null
var _last_guy_progress: float = 0.0


func _animate(state: OptionsState, time: float = 0.75) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel()
	match state:
		OptionsState.HIDDEN:
			_tween.tween_property(_center_spacer_control, "size_flags_stretch_ratio", 0.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_left_top_spacer_control, "size_flags_stretch_ratio", 1.5, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_outer_container, "size_flags_stretch_ratio", 0.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_left_side_container, "size_flags_stretch_ratio", 1.5, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_vbox, "scale", Vector2.ZERO, time * 0.5).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_mask_vbox, "scale", Vector2.ZERO, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_container, "modulate:a", 0.0, time * 0.5).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_transcript_container, "size_flags_stretch_ratio", 0.5, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_transcript_container, "modulate:a", 0.0, time * 0.5).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_stats_display_container, "scale", Vector2.ZERO, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_stats_display_container, "modulate:a", 0.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_guy_container, "modulate:a", 0.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_method(_interpolate_guy, _last_guy_progress, 0.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.chain().tween_callback(hide)
		OptionsState.OPTIONS_HIDDEN:
			_tween.tween_callback(show)
			_tween.tween_property(_center_spacer_control, "size_flags_stretch_ratio", 0.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_left_top_spacer_control, "size_flags_stretch_ratio", 1.5, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_outer_container, "size_flags_stretch_ratio", 0.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_left_side_container, "size_flags_stretch_ratio", 1.5, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_vbox, "scale", Vector2.ZERO, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_mask_vbox, "scale", Vector2.ZERO, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_container, "modulate:a", 0.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_transcript_container, "size_flags_stretch_ratio", 1.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_transcript_container, "modulate:a", 1.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_stats_display_container, "scale", Vector2.ZERO, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_stats_display_container, "modulate:a", 0.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_guy_container, "modulate:a", 1.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_method(_interpolate_guy, _last_guy_progress, 0.0, time).set_ease(easing_type).set_trans(transition_type)
		OptionsState.OPTIONS_SHOWN:
			_tween.tween_callback(show)
			_tween.tween_property(_center_spacer_control, "size_flags_stretch_ratio", 0.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_left_top_spacer_control, "size_flags_stretch_ratio", 1.5, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_outer_container, "size_flags_stretch_ratio", 1.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_left_side_container, "size_flags_stretch_ratio", 1.5, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_vbox, "scale", Vector2.ONE, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_mask_vbox, "scale", Vector2.ZERO, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_container, "modulate:a", 1.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_transcript_container, "modulate:a", 1.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_transcript_container, "size_flags_stretch_ratio", 1.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_stats_display_container, "scale", Vector2.ZERO, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_stats_display_container, "modulate:a", 0.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_guy_container, "modulate:a", 1.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_method(_interpolate_guy, _last_guy_progress, 0.0, time).set_ease(easing_type).set_trans(transition_type)
		OptionsState.MASK:
			_tween.tween_callback(show)
			_tween.tween_property(_center_spacer_control, "size_flags_stretch_ratio", 2.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_left_top_spacer_control, "size_flags_stretch_ratio", 0.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_outer_container, "size_flags_stretch_ratio", 1.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_left_side_container, "size_flags_stretch_ratio", 1.5, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_vbox, "scale", Vector2.ZERO, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_mask_vbox, "scale", Vector2.ONE, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_options_container, "modulate:a", 1.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_transcript_container, "modulate:a", 1.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_transcript_container, "size_flags_stretch_ratio", 1.0, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_stats_display_container, "scale", Vector2.ONE, time).set_ease(easing_type).set_trans(transition_type)
			_tween.tween_property(_stats_display_container, "modulate:a", 1.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_property(_guy_container, "modulate:a", 1.0, time).set_ease(easing_type).set_trans(soft_transition_type)
			_tween.tween_method(_interpolate_guy, _last_guy_progress, 1.0, time).set_ease(easing_type).set_trans(transition_type)
	await _tween.finished
	scroll_transcript_to_bottom()


func _show_dialogue_func(dialogue: Callable) -> void:
	for child in _options_vbox.get_children():
		child.queue_free()
	_option_widgets.clear()
	displayed_options.clear()
	selected_option = 0

	is_dialogue_running = true
	_dialogue_skipped = false
	var options: Array[DialogueOption]
	var untyped_options: Array = await dialogue.call()
	options.assign(untyped_options)
	is_dialogue_running = false
	displayed_options = options.duplicate()
	var i := 0
	for option in options:
		var widget := DialogueOptionWidget.new(option.option_title)
		widget.disabled = option.disabled
		_options_vbox.add_child(widget)
		widget.hovered.connect(func(): selected_option = i)
		widget.clicked.connect(func(): _select_option(i))
		_option_widgets.append(widget)
		i += 1
	selected_option = _is_any_option_available()
	dialogue_options_shown.emit()
	if selected_option == -1 or (displayed_options.size() == 1 and displayed_options[0].hide_if_last_option):
		_continue_indicator.animate_in()
	else:
		await _animate(OptionsState.OPTIONS_SHOWN)


var _scroll_tween: Tween = null

## Show a piece of text in the transcript.
## This does animate the text and scroll.
func show_text(text: String) -> void:
	var dialogue := DialogueTranscript.new()
	dialogue.label.append_text("[dialogue_text start_time=\"%s\"]%s[/dialogue_text]" % [Time.get_ticks_msec(), text])
	dialogue.label.fit_content = true
	dialogue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_transcript.add_child(dialogue)
	scroll_transcript_to_bottom()
	if not _dialogue_skipped:
		_text_timer = get_tree().create_timer(maxf(1.0, text.length() / 100.0))
		await _text_timer.timeout
		_text_timer = null


func scroll_transcript_to_bottom() -> void:
	get_tree().process_frame.connect(
		func():
			if _scroll_tween:
				_scroll_tween.kill()
			_scroll_tween = create_tween()
			_scroll_tween.tween_property(_transcript_scroll_container, "scroll_vertical", _transcript.size.y - _transcript_scroll_container.size.y, 0.75).set_ease(easing_type).set_trans(transition_type),
		CONNECT_ONE_SHOT
	)


func show_player_dialogue(text: String) -> void:
	await show_text("[dialogue_response]%s[/dialogue_response]" % text)


func show_mask_config(target_stats: MaskStats) -> MaskParts:
	_mask_grid.target_stats = target_stats
	_mask_grid.reset()
	await _animate(OptionsState.MASK)
	return await _mask_grid.submitted


func _can_advance_selected_option(direction: int) -> int:
	if displayed_options.is_empty() or displayed_options.all(func(it: DialogueOption): return it.disabled):
		return 0
	var i := selected_option + direction
	if i < 0 or i >= displayed_options.size():
		return selected_option
	while displayed_options[i].disabled:
		i += direction
		if i < 0 or i >= displayed_options.size():
			i = selected_option
			break
	return i


func _interpolate_guy(progress: float = _last_guy_progress) -> void:
	_guy_container.position = _left_top_spacer_control.position.lerp(_center_spacer_control.position, progress)
	_guy_container.size = _left_top_spacer_control.size.lerp(_center_spacer_control.size, progress)
	_last_guy_progress = progress


func _on_mask_grid_part_hovered(part: MaskPart) -> void:
	Util.unused(part)


func _on_mask_grid_mask_parts_changed(new_parts: MaskParts) -> void:
	#var stats := new_parts.get_cumulative_stats()
	dialogue_mask_guy.set_mask_parts(new_parts)


func _is_any_option_available(options: Array[DialogueOption] = displayed_options) -> int:
	return options.find_custom(func(it: DialogueOption): return not it.disabled)


func _select_option(index: int) -> void:
	_continue_indicator.animate_out()
	is_dialogue_running = true
	var option := displayed_options[index]
	dialogue_advanced.emit(option)
	show_text("[dialogue_response]%s[/dialogue_response]" % option.option_title)
	await _animate(OptionsState.OPTIONS_HIDDEN)
	_show_dialogue_func(option.option_callback)


func animate_overlay() -> void:
	var tween := create_tween()
	overlay.show()
	overlay.modulate.a = 0.0
	tween.set_parallel()
	tween.tween_property(overlay, "modulate:a", 1.0, 3.0)
	var last_shake_time: PackedInt64Array = [Time.get_ticks_msec()]
	tween.tween_method(func(value: float):
		if Time.get_ticks_msec() - last_shake_time[0] > 20:
			last_shake_time[0] = Time.get_ticks_msec()
			position = Vector2(randf_range(-value, value), randf_range(-value, value))
	, 0.0, 20.0, 3.0)
	await tween.finished


class DialogueOptionWidget extends HBoxContainer:
	signal hovered
	signal clicked

	const ICON = preload("uid://b3cn87iakmv1m")

	var text: String
	var icon := TextureRect.new()
	var label := Label.new()
	var disabled := false

	func _init(_text: String) -> void:
		text = _text

	func _ready() -> void:
		icon.texture = ICON
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		add_child(icon)
		label.text = text
		add_child(label)

		if disabled:
			var strikethrough := ColorRect.new()
			strikethrough.custom_minimum_size.y = 3
			strikethrough.set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
			strikethrough.modulate.a = 0.5
			label.modulate.a = 0.5
			label.add_child(strikethrough)

		if not disabled:
			mouse_entered.connect(hovered.emit)
		set_selected(false)

	func _gui_input(event: InputEvent) -> void:
		var mb := event as InputEventMouseButton
		if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()

	func set_selected(selected: bool) -> void:
		if disabled:
			icon.modulate.a = 0.0
		else:
			icon.modulate.a = 1.0 if selected else 0.0
			label.theme_type_variation = "BoldLabel" if selected else ""


class DialogueTranscript extends Container:
	var label := RichTextLabel.new()
	var x_offset: float:
		set(value):
			x_offset = value
			queue_sort()

	func _init() -> void:
		label.install_effect(preload("dialogue_response_rich_text_effect.gd").new())
		label.install_effect(preload("dialogue_text_rich_text_effect.gd").new())
		label.install_effect(preload("emph_rich_text_effect.gd").new())
		label.minimum_size_changed.connect(update_minimum_size)
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(label)

	func _get_minimum_size() -> Vector2:
		return label.get_combined_minimum_size()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_SORT_CHILDREN:
			fit_child_in_rect(label, Rect2(Vector2(x_offset, 0.0), size))
