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
