extends AudioStreamPlayer
var tracks = [
	"",
	"res://music/level2.mp3"
]


func set_track(track_id):
	if track_id!=0:
		if stream!=null:
			if str(stream.get_path())!=tracks[track_id]:
				stream = load(tracks[track_id])
		else:
			stream = load(tracks[track_id])
	else:
		stop()
	
func play_track(track_id):
	if track_id!=0:
		if stream!=null:
			if str(stream.get_path())!=tracks[track_id]:
				stream = load(tracks[track_id])
				play()
		else:
			stream = load(tracks[track_id])
			play()
	else:
		stop()
		
func decrease_volume():
	create_tween().tween_property(self,"volume_db",-20.0,1.0)

func increase_volume():
	create_tween().tween_property(self,"volume_db",0.0,1.0)
