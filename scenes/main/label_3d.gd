extends Label3D

var hitnum = 0
var missnum = 0
var lasthit = -1

func _on_rythm_node_end(subbeat: Variant) -> void:
	if lasthit != subbeat:
		missnum += 1
		change_text()

func _on_rythm_node_hit(timing: Variant, subbeat: Variant) -> void:
	hitnum += 1
	lasthit = subbeat
	change_text()

func change_text():
	self.text = "HIT {0} MISSED {1}".format([hitnum,missnum])

func reset():
	hitnum = 0
	missnum = 0
	lasthit = -1
	change_text()

func _on_rythm_node_miss() -> void:
	missnum += 1
	change_text()


func _on_rythm_node_reset() -> void:
	reset()
