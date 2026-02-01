extends Node


var mask_1: MaskParts
var mask_2: MaskParts


func get_mask_for_type(type: HitTime.HitType) -> MaskParts:
	match type:
		HitTime.HitType.BEATF:
			return mask_1
		HitTime.HitType.BEATJ:
			return mask_2
	assert(false, "Unreachable")
	return null
