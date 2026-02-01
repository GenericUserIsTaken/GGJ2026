class_name MaskParts extends Resource


var parts: Dictionary[MaskPart.Type, MaskPart]


func is_valid() -> bool:
	return parts.size() == MaskPart.Type.size()


func add_part(part: MaskPart) -> void:
	parts[part.type] = part


func remove_part(part_type: MaskPart.Type) -> void:
	parts.erase(part_type)


func get_cumulative_stats() -> MaskStats:
	var stats := MaskStats.new()
	for part_type in parts:
		var part := parts[part_type]
		for stat in MaskStats.stats():
			stats[stat] += part.stats[stat]
	return stats
