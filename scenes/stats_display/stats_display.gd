@tool
class_name StatsDisplay extends GridContainer

@onready var loyalty: StatsBar = %Loyalty
@onready var mental: StatsBar = %Mental
@onready var emotional: StatsBar = %Emotional
@onready var physical: StatsBar = %Physical

@export var show_labels: bool = true:
	set(value):
		show_labels = value
		columns = 2 if show_labels else 1
		for child: Label in find_children("*", "Label", false):
			child.visible = show_labels


var stats_tween: Tween = null
var placeholder_stats_tween: Tween = null
var vis_tween: Tween = null


func show_stats(stats: MaskStats) -> void:
	if stats_tween:
		stats_tween.kill()
	stats_tween = create_tween()
	stats_tween.set_parallel()
	for stat in MaskStats.stats():
		stats_tween.tween_property(self[stat], "fill", stats[stat] if stats else 0.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func show_placeholder_stats(placeholder_stats: MaskStats) -> void:
	if placeholder_stats_tween:
		placeholder_stats_tween.kill()
	placeholder_stats_tween = create_tween()
	placeholder_stats_tween.set_parallel()
	for stat in MaskStats.stats():
		placeholder_stats_tween.tween_property(self[stat], "placeholder_fill", placeholder_stats[stat] if placeholder_stats else 0.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func animate_show() -> void:
	if vis_tween:
		vis_tween.kill()
	vis_tween = create_tween()
	show()
	stats_tween.tween_property(self, "modulate:a", 1.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func animate_hide() -> void:
	if vis_tween:
		vis_tween.kill()
	vis_tween = create_tween()
	vis_tween.tween_property(self, "modulate:a", 1.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	vis_tween.tween_callback(hide)
