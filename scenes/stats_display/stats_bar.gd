@tool
class_name StatsBar extends Control


const MIN_VALUE := -4.0
const MAX_VALUE := 4.0


var bg_panel: StyleBox
var fill_panel: StyleBox
var fill_negative_panel: StyleBox
var placeholder_panel: StyleBox
var placeholder_negative_panel: StyleBox


@export var fill: float:
	set(value):
		fill = value
		queue_redraw()
@export var placeholder_fill: float:
	set(value):
		placeholder_fill = value
		queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		bg_panel = get_theme_stylebox(&"panel", &"StatsBar")
		fill_panel = get_theme_stylebox(&"fill", &"StatsBar")
		placeholder_panel = get_theme_stylebox(&"placeholder_fill", &"StatsBar")
		fill_negative_panel = get_theme_stylebox(&"negative_fill", &"StatsBar")
		placeholder_negative_panel = get_theme_stylebox(&"negative_placeholder_fill", &"StatsBar")


func _draw() -> void:
	var item := get_canvas_item()
	bg_panel.draw(item, Rect2(Vector2.ZERO, size))
	_draw_bar(placeholder_panel, placeholder_negative_panel, placeholder_fill)
	_draw_bar(fill_panel, fill_negative_panel, fill)


func _draw_bar(pos_sb: StyleBox, neg_sb: StyleBox, fill_amount: float) -> void:
	if is_zero_approx(fill_amount):
		return
	var half_size := size * 0.5
	(
		pos_sb if fill_amount > 0.0 else neg_sb
	).draw(
		get_canvas_item(),
		Rect2(Vector2(half_size.x, 0.0), Vector2(remap(fill_amount, MIN_VALUE, MAX_VALUE, -1.0, 1.0) * half_size.x, size.y)).abs(),
	)


func _get_minimum_size() -> Vector2:
	return Vector2(0, 24)
