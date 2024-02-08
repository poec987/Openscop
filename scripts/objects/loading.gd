extends Node2D

func _ready():
	var fade_out=create_tween()
	fade_out.tween_property($fade_in,"color:a",0.0,0.5)
	await fade_out.finished
	Global.can_pause=true
