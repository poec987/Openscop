extends Node2D

var started = true
var timer = 0.0

func _ready():
	if Global.gen>3 && Global.gen<12:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1.texture =  load("res://graphics/sprites/ui/garalina/gen"+str(Global.gen)+".png")
	if Global.gen>11:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1.texture =  load("res://graphics/sprites/ui/garalina/gen"+str(Global.gen-8)+".png")
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1.flip_h = true
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1.flip_v = true
		
	if Global.gen<4:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1.texture =  load("res://graphics/sprites/ui/garalina/gen"+str(Global.gen+8)+".png")
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1.flip_h = true
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1.flip_v = true
		
		
	if Global.gen>3 && Global.gen<12:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_2.frame = Global.gen-4
	
	if Global.gen>11:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_2.frame = Global.gen-12
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_2.flip_h = true
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_2.flip_v = true
		
	if Global.gen<4:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_2.frame =  Global.gen+4
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_2.flip_h = true
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_2.flip_v = true
func _process(delta):
	if started:
		timer += delta*25
	
	if timer>153 && get_node_or_null("PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1")!=null:	
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1.queue_free()
	if timer<151:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_1.frame = int(timer)
	
	if timer>176 && !$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_2.visible:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/logo_anim_2.visible = true
