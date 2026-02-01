class_name HitTime extends Resource


enum HitType {
	BEATA,
	BEATB
}#hold a,etc

@export var measure: int
@export var subbeat: int
@export var song_time: float
@export var hit_type : HitType

func _init(song_time = null, measure = null, subbeat = null, hit_type = null):
	self.song_time = song_time
	self.measure = measure
	self.subbeat = subbeat
	self.hit_type = hit_type

func _to_string():
		return "Hit type {0}, at measure {1}, subbeat {2}, recorded song time {3}".format([self.hit_type,self.measure,self.subbeat,self.song_time])
