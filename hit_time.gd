class_name HitTime extends Resource


enum HitType {
	BEATF,
	BEATJ
}#hold a,etc

@export var measure: int
@export var subbeat: int
@export var song_time: float
@export var hit_type : HitType
@export var spawned : bool = false
@export var id : int

func _init(measure = null, subbeat = null, hit_type = null, id = -1, song_time = null):
	self.measure = measure
	self.subbeat = subbeat
	self.hit_type = hit_type
	self.id = id
	if song_time != null:
		self.song_time = song_time
	else:
		self.song_time = RhythmNode.calc_songtime(measure,subbeat)
	
func equals(other: HitTime) -> bool:
	return self.measure == other.measure and self.subbeat == other.subbeat and self.HitType == other.HitType  

func _to_short_string():	
	return "ID {4} M {1}, S {2} HIT {0} T {3}".format([self.hit_type,self.measure,self.subbeat,self.song_time,self.id])

func _to_string():
		return "ID {4} Hit type {0}, at measure {1}, subbeat {2}, recorded song time {3}".format([self.hit_type,self.measure,self.subbeat,self.song_time,self.id])
