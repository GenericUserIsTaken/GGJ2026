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


@export var editor_display_stats: MaskStats
@export var editor_display_placeholder_stats: MaskStats
@export_tool_button("Animate stats", "Tween") var editor_display_stats_callback := func(): show_stats(editor_display_stats, editor_display_placeholder_stats)


var tween: Tween = null


func show_stats(stats: MaskStats, placeholder_stats: MaskStats = null) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	show()
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 1.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	for stat in MaskStats.stats():
		tween.tween_property(self[stat], "fill", stats[stat], 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(self[stat], "placeholder_fill", placeholder_stats[stat] if placeholder_stats else 0.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func animate_hide() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(hide)
