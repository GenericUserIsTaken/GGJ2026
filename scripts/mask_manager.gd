class_name MaskManager


static var mask_1: MaskParts
static var mask_2: MaskParts


static func get_mask_for_type(type: HitTime.HitType) -> MaskParts:
	match type:
		HitTime.HitType.BEATF:
			return mask_1
		HitTime.HitType.BEATJ:
			return mask_2
	assert(false, "Unreachable")
	return null

static func get_texture_color_for_type(type: HitTime.HitType) -> Color:
	match type:
		HitTime.HitType.BEATF:
			return Color.RED
		HitTime.HitType.BEATJ:
			return Color.BLUE
	assert(false, "Unreachable")
	return Color.BLACK
