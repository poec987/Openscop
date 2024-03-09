extends Node3D
var title_stage = 0
var timer:int = 0
const READING_CARD_WAIT = 5.0
func _ready():
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/file_select/buttons_group/GoBack.play()
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/file_select/buttons_group/SelectFile.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	timer += 1
	if timer == 30:
		timer = 0
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/press_start.visible = bool(int(timer < 24) * int(title_stage==0))
	
	if Input.is_action_just_pressed("pressed_start") && title_stage==0:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/press_start.frame_coords.y = 1
		$reading_card_timer.wait_time = READING_CARD_WAIT+randf_range(0.0,2.0)
		$reading_card_timer.start()
		await $reading_card_timer.timeout
		create_tween().tween_property($Copyright,"position:x",-224.0,1.0).set_trans(Tween.TRANS_BACK)
		create_tween().tween_property($title_root,"position:x",3.5,1.0).set_trans(Tween.TRANS_BACK)
		var scale_logo = create_tween().set_parallel()
		scale_logo.tween_property($title_root/title_mesh_root/title_mesh,"scale:y",0.75,0.5).set_trans(Tween.TRANS_SINE)
		scale_logo.tween_property($title_root/title_mesh_root/title_mesh,"scale:x",1.25,0.5).set_trans(Tween.TRANS_SINE)
		await scale_logo.finished
		var scale_logo_2 = create_tween().set_parallel()
		scale_logo_2.tween_property($title_root/title_mesh_root/title_mesh,"scale:y",1.5,0.25).set_trans(Tween.TRANS_SINE)
		scale_logo_2.tween_property($title_root/title_mesh_root/title_mesh,"scale:x",0.25,0.25).set_trans(Tween.TRANS_SINE)
		create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/file_select,"position:x",0.0,1.0).set_trans(Tween.TRANS_BACK)
		await scale_logo_2.finished
		title_stage=1
		
	if Input.is_action_just_pressed("pressed_triangle") && title_stage==1:
		create_tween().tween_property($Copyright,"position:x",96.0,1.0).set_trans(Tween.TRANS_BACK)
		create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/file_select,"position:x",320.0,1.0).set_trans(Tween.TRANS_BACK)
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/press_start.frame_coords.y = 0
		create_tween().tween_property($title_root,"position:x",3.924,1.0).set_trans(Tween.TRANS_BACK)
		var scale_logo = create_tween().set_parallel()
		scale_logo.tween_property($title_root/title_mesh_root/title_mesh,"scale:x",1.0,0.5).set_trans(Tween.TRANS_BACK)
		await scale_logo.finished
		var scale_logo_2 = create_tween().set_parallel()
		scale_logo_2.tween_property($title_root/title_mesh_root/title_mesh,"scale:y",1.0,1.0).set_trans(Tween.TRANS_BACK)
		await scale_logo_2.finished
		title_stage=0
