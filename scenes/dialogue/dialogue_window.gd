extends Control


signal dialogue_started
signal dialogue_advanced
signal dialogue_ended

signal selected_option_changed(new_selected_option: int)


@onready var options_container: Container = %OptionsGrid
@onready var transcript: VBoxContainer = %Transcript
@onready var transcript_scroll_container: ScrollContainer = %TranscriptScrollContainer


var selected_option: int:
	set(value):
		selected_option = value
		selected_option_changed.emit(value)
var displayed_options: Array[DialogueOption]
var option_widgets: Array[DialogueOptionWidget]
var active_dialog: Dialogue = null

var active_tween: Tween = null


func _fix_tree_order() -> void:
	get_parent().move_child(self, get_parent().get_child_count() - 1)


func _ready() -> void:
	hide()
	selected_option_changed.connect(
		func(selected: int):
			var i := 0
			for option in option_widgets:
				option.set_selected(selected == i)
				i += 1
	)
	await get_parent().ready
	_fix_tree_order()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_down") and event.is_pressed() and selected_option < displayed_options.size() - 1:
		selected_option += 1
	elif event.is_action("ui_up") and event.is_pressed() and selected_option > 0:
		selected_option -= 1
	elif event.is_action("ui_accept") and event.is_pressed():
		if displayed_options.is_empty():
			dialogue_ended.emit()
			active_dialog = null
			_animate_out()
		else:
			dialogue_advanced.emit()
			_show_dialogue_func(displayed_options[selected_option].option_callback)


func show_dialogue(dialogue: Dialogue) -> void:
	dialogue._dialogue_window = self
	active_dialog = dialogue
	_animate_in()
	dialogue_started.emit()
	_show_dialogue_func(dialogue.dialogue)


func clear_transcript() -> void:
	for child in transcript.get_children():
		child.queue_free()


func _animate_in() -> void:
	if active_tween:
		active_tween.kill()
	active_tween = create_tween()
	show()
	modulate.a = 0.0
	active_tween.tween_property(self, "modulate:a", 1.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _animate_out() -> void:
	if active_tween:
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(self, "modulate:a", 0.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	active_tween.tween_callback(hide)


func _show_dialogue_func(dialogue: Callable) -> void:
	for child in options_container.get_children():
		child.queue_free()
	option_widgets.clear()
	selected_option = 0

	var options: Array[DialogueOption] = await dialogue.call()
	displayed_options = options

	var i := 0
	for option in options:
		var widget := DialogueOptionWidget.new(option.option_title)
		options_container.add_child(widget)
		widget.hovered.connect(func(): selected_option = i)
		widget.clicked.connect(_show_dialogue_func.bind(option.option_callback))
		option_widgets.append(widget)
		i += 1
	selected_option = 0


var active_scroll_tween: Tween = null


func show_text(text: String) -> void:
	var dialogue := DialogueTranscript.new()
	dialogue.label.append_text(text)
	dialogue.label.fit_content = true
	dialogue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	transcript.add_child(dialogue)
	#transcript.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	#transcript.append_text(text)
	#transcript.pop()
	#transcript.scroll_to_line(transcript.get_line_count() - 1)
	get_tree().process_frame.connect(
		func():
			if active_scroll_tween:
				active_scroll_tween.kill()
			active_scroll_tween = create_tween()
			active_scroll_tween.tween_property(transcript_scroll_container, "scroll_vertical", transcript.size.y - transcript_scroll_container.size.y, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO),
		CONNECT_ONE_SHOT
	)
	await get_tree().create_timer(1.0).timeout


func make_dialogue_object(dialogue: GDScript) -> Dialogue:
	var obj: Dialogue = dialogue.new()
	obj._dialogue_window = self
	add_child(obj)
	return obj


class DialogueOptionWidget extends HBoxContainer:
	signal hovered
	signal clicked

	const ICON = preload("uid://isbqsoevkfnm")

	var text: String
	var icon := TextureRect.new()

	func _init(_text: String) -> void:
		text = _text

	func _ready() -> void:
		#var icon_wrapper := Control.new()
		icon.texture = ICON
		#icon_wrapper.custom_minimum_size = Vector2(26, 26)
		#icon_wrapper.add_child(icon)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		add_child(icon)
		var label := Label.new()
		label.text = text
		add_child(label)

		mouse_entered.connect(hovered.emit)
		set_selected(false)

	func _gui_input(event: InputEvent) -> void:
		var mb := event as InputEventMouseButton
		if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()

	func set_selected(selected: bool) -> void:
		icon.visible = selected


class DialogueTranscript extends Container:
	var label := RichTextLabel.new()
	var x_offset: float:
		set(value):
			x_offset = value
			queue_sort()

	func _init() -> void:
		label.minimum_size_changed.connect(update_minimum_size)
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(label)

	func _ready() -> void:
		modulate.a = 0.0
		x_offset = 0.0
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "modulate:a", 1.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "x_offset", 10.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

	func _get_minimum_size() -> Vector2:
		return label.get_combined_minimum_size()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_SORT_CHILDREN:
			fit_child_in_rect(label, Rect2(Vector2(x_offset, 0.0), size))
