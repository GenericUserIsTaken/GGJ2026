extends Label3D

var hitnum = 0
var missnum = 0

func _on_rythm_node_hit(timing: Variant) -> void:
	hitnum += 1
	change_text()

func change_text():
	self.text = "HIT {0} MISSED {1}".format([hitnum,missnum])

func reset():
	hitnum = 0
	missnum = 0
	change_text()

func _on_rythm_node_miss(_node) -> void:
	missnum += 1
	change_text()


func _on_rythm_node_reset() -> void:
	reset()
