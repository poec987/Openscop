extends Node2D

var started = true
var timer = 0.0


@onready var logo = $PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1
@onready var logo2 = $PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_2

func _ready():
	if Record.replay:
		Record.replay = false
	if Record.recording:
		Record.stop_recording()
	Global.room_name="garalina"
	create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/fade_in,"color:a",0.0,1.75)
	if Global.gen>3 && Global.gen<12:
		logo.texture =  load("res://graphics/sprites/ui/garalina/gen"+str(Global.gen)+".png")
	if Global.gen>11:
		logo.texture =  load("res://graphics/sprites/ui/garalina/gen"+str(Global.gen-8)+".png")
		logo.flip_h = true
		logo.flip_v = true
		
	if Global.gen<4:
		logo.texture =  load("res://graphics/sprites/ui/garalina/gen"+str(Global.gen+8)+".png")
		logo.flip_h = true
		logo.flip_v = true
		
		
	if Global.gen>3 && Global.gen<12:
		logo2.frame = Global.gen-4
	
	if Global.gen>11:
		logo2.frame = Global.gen-12
		logo2.flip_h = true
		logo2.flip_v = true
		
	if Global.gen<4:
		logo2.frame =  Global.gen+4
		logo2.flip_h = true
		logo2.flip_v = true
func _process(delta):
	if started:
		timer += delta*25
	
	if timer>241:
		var fade_out = create_tween()
		fade_out.tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/fade_out,"color:a",1.0,1.5)
	
	if timer>310:
		get_tree().change_scene_to_file("res://scenes/rooms/title/title.tscn")
	
	if timer>153 && get_node_or_null("PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1")!=null:	
		logo.queue_free()
	if timer<151:
		logo.frame = int(timer)
	
	if timer>176 && !logo2.visible:
		logo2.visible = true
