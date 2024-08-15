extends Node3D

@export var title_stage = 0

var timer:int = 0
const READING_CARD_WAIT = 2.5


var file_data = {}
var fade_color = 0

var selected_file = 0
var cont_option = true
var recording_files = DirAccess.get_files_at("user://recordings/")
var allowed_recordings = []

@onready var start_button = $PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/press_start
@onready var logo = $title_root/title_mesh_root/title_mesh
@onready var file_select = $PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select
func _ready():
	bg_music.stop()
	get_tree().paused = false
	Global.game_paused = false
	Global.can_pause = true
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/buttons_group/GoBack.play()
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/buttons_group/SelectFile.play()
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/buttons_group2/Finish.play()
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/buttons_group2/Select.play()
	if Global.room_name=="garalina":
		$song.play()
		Global.room_name=="title"
	for file in recording_files:
		if (JSON.parse_string((FileAccess.open(("user://recordings/"+file),FileAccess.READ)).get_as_text()))["recording_info"]["rotation"]:
			allowed_recordings.append(file)
	#$demo_timer.wait_time = randi_range(60,10800)
	$demo_timer.start()
		
func _physics_process(_delta):
	
	timer += 1
	if timer == 30:
		timer = 0
	start_button.visible = bool(int(timer < 24) * int(title_stage==0))
	
	if Input.is_action_just_pressed("pressed_start") && title_stage==0:
		$pressed_start.play()
		selected_file=0
		start_button.frame_coords.y = 1
		$reading_card_timer.wait_time = READING_CARD_WAIT+randf_range(0.0,2.0)
		$reading_card_timer.start()
		check_files()
		await $reading_card_timer.timeout
		create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/Copyright,"position:x",-224.0,1.0).set_trans(Tween.TRANS_BACK)
		create_tween().tween_property(start_button,"position:x",-224.0,1.0).set_trans(Tween.TRANS_BACK)
		create_tween().tween_property($title_root,"position:x",3.5,1.0).set_trans(Tween.TRANS_BACK)
		var scale_logo = create_tween().set_parallel()
		scale_logo.tween_property(logo,"scale:y",0.75,0.5).set_trans(Tween.TRANS_SINE)
		scale_logo.tween_property(logo,"scale:x",1.25,0.5).set_trans(Tween.TRANS_SINE)
		await scale_logo.finished
		var scale_logo_2 = create_tween().set_parallel()
		scale_logo_2.tween_property(logo,"scale:y",1.5,0.25).set_trans(Tween.TRANS_SINE)
		scale_logo_2.tween_property(logo,"scale:x",0.25,0.25).set_trans(Tween.TRANS_SINE)
		$whistle.play()
		create_tween().tween_property(file_select,"position:x",0.0,1.0).set_trans(Tween.TRANS_BACK)
		await scale_logo_2.finished
		title_stage=1

		
	if title_stage==1:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/file_select.modulate = Color(1.0,1.0,1.0)
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/file_select.modulate = Color(1.0,1.0,1.0)
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/file_select.modulate = Color(1.0,1.0,1.0)
		if Input.is_action_just_pressed("pressed_down") && $move_permission.time_left==0:
			selected_file+=1
			$move_permission.set_wait_time(0.25)
			$move_permission.start()
			if selected_file<=2:
				bounce_file_up()
				$file.play()
			
		if Input.is_action_just_pressed("pressed_up") && $move_permission.time_left==0:
			selected_file-=1
			$move_permission.set_wait_time(0.25)
			$move_permission.start()
			if selected_file>=0:
				bounce_file_up(true)
				$file.play()
		
		if Input.is_action_just_pressed("pressed_action") && file_select.position.x==0.0:
			if FileAccess.file_exists("user://savedata/saveslot"+str(selected_file)+".save"):
				title_stage=2
				create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/continue_menu,"position:y",0.0,0.5)
				var overlay_move = create_tween()
				overlay_move.tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/overlay,"color:a",0.5,0.5)
				await overlay_move.finished
				title_stage = 3
			else:
				title_stage=4
				Global.create_keyboard(3,false,false)
				$selected.play()
				create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0,"position:x",-240.0,0.45).set_trans(Tween.TRANS_SINE)
				create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1,"position:x",306.0,0.45).set_trans(Tween.TRANS_SINE)
				create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2,"position:x",-240.0,0.45).set_trans(Tween.TRANS_SINE)
				create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/buttons_group,"position:y",50.0,0.45).set_trans(Tween.TRANS_SINE)
				create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/buttons_group2,"position:y",0.0,0.45).set_trans(Tween.TRANS_SINE)
		selected_file = clamp(selected_file,0,2)
		
		if Input.is_action_just_pressed("pressed_triangle"):
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/Copyright,"position:x",96.0,1.0).set_trans(Tween.TRANS_BACK)
			create_tween().tween_property(start_button,"position:x",0.0,1.0).set_trans(Tween.TRANS_BACK)
			var move_files = create_tween()
			move_files.tween_property(file_select,"position:x",320.0,1.0).set_trans(Tween.TRANS_BACK)
			start_button.frame_coords.y = 0
			create_tween().tween_property($title_root,"position:x",3.924,1.0).set_trans(Tween.TRANS_BACK)
			var scale_logo = create_tween().set_parallel()
			scale_logo.tween_property(logo,"scale:x",1.0,0.5).set_trans(Tween.TRANS_BACK)
			await scale_logo.finished
			var scale_logo_2 = create_tween().set_parallel()
			scale_logo_2.tween_property(logo,"scale:y",1.0,1.0).set_trans(Tween.TRANS_BACK)
			await scale_logo_2.finished
			title_stage=0
	
	if title_stage==3:
		if Input.is_action_just_pressed("pressed_triangle"):
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/overlay,"color:a",0.0,0.5)
			title_stage=1
			var go_back = create_tween()
			go_back.tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/continue_menu,"position:y",-240.0,0.5)
			await go_back.finished
			cont_option = true
			
		if Input.is_action_just_pressed("pressed_up"):
			cont_option = true
			
		if Input.is_action_just_pressed("pressed_down"):
			cont_option = false

		if Input.is_action_just_pressed("pressed_action"):
			if cont_option:
				title_stage=-1
				$pressed_start.play()
				Global.save_slot = selected_file
				print(Global.save_slot)
				Global.load_game(selected_file)
			else:
				DirAccess.remove_absolute("user://savedata/saveslot"+str(selected_file)+".save")	
				create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/overlay,"color:a",0.0,0.5)
				title_stage=1
				var go_back = create_tween()
				go_back.tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/continue_menu,"position:y",-240.0,0.5)
				await go_back.finished
				cont_option = true
				check_files()
		if cont_option:
			$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/continue_menu/cursor.position=Vector2(234,92)
		else:
			$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/continue_menu/cursor.position=Vector2(215,132)
	
	if title_stage==4:
		if Global.keyboard_RAM!="":
			Global.save_name = Global.keyboard_RAM
			write_blank_save(selected_file)
			check_files()
			Global.keyboard_RAM=""
			title_stage=1
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/buttons_group,"position:y",0.0,0.5).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/buttons_group2,"position:y",50.0,0.5).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0,"position:x",0.0,0.5).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1,"position:x",66.0,0.5).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2,"position:x",0.0,0.5).set_trans(Tween.TRANS_SINE)
		if Input.is_action_pressed("pressed_triangle"):
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/buttons_group,"position:y",0.0,0.5).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/buttons_group2,"position:y",50.0,0.5).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0,"position:x",0.0,0.5).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1,"position:x",66.0,0.5).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2,"position:x",0.0,0.5).set_trans(Tween.TRANS_SINE)
	if title_stage>3:
		if (int(timer)/3)%2:
			if selected_file==0:
				$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/file_select.modulate = Color(1.0,1.0,1.0)
			if selected_file==1:
				$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/file_select.modulate = Color(1.0,1.0,1.0)
			if selected_file==2:
				$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/file_select.modulate = Color(1.0,1.0,1.0)
		else:
			if selected_file==0:
				$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/file_select.modulate = Color(1.0,0.5,1.0)
			if selected_file==1:
				$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/file_select.modulate = Color(1.0,0.5,1.0)
			if selected_file==2:
				$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/file_select.modulate = Color(1.0,0.5,1.0)
	
	if selected_file==0:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/cursor.visible=true
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/cursor.visible=false
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/cursor.visible=false
	if selected_file==1:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/cursor.visible=false
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/cursor.visible=true
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/cursor.visible=false
	if selected_file==2:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/cursor.visible=false
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/cursor.visible=false
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/cursor.visible=true
	
	#if get_tree().get_first_node_in_group("loading_overlay").get_child(1).get_texture!=null:
		#$song.stop()
	
func bounce_file_up(yes: bool = false):
	var bounce = create_tween()
	if yes:
		bounce.tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files.get_child(selected_file),"position:y",-10.0,0.2).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		bounce.tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files.get_child(selected_file),"position:y",10.0,0.2).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)	
	if yes:
		bounce.tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files.get_child(selected_file),"position:y",10.0,0.2).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	else:
		bounce.tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files.get_child(selected_file),"position:y",-10.0,0.2).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func check_files():
	if FileAccess.file_exists("user://savedata/saveslot0.save"):
		file_data = JSON.parse_string((FileAccess.open("user://savedata/saveslot0.save",FileAccess.READ)).get_as_text())
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/file_name.text = file_data["game"]["save_name"]
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/corrupt.visible = file_data["game"]["corrupted"]
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/counter.text = str(file_data["player"]["pieces"][0]).pad_zeros(5)
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/piece.visible = true
	else:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/file_name.text = "Empty Game"
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/corrupt.visible = false
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/counter.text = ""
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file0/piece.visible = false
	if FileAccess.file_exists("user://savedata/saveslot1.save"):
		file_data = JSON.parse_string((FileAccess.open("user://savedata/saveslot1.save",FileAccess.READ)).get_as_text())
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/file_name.text = file_data["game"]["save_name"]
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/corrupt.visible = file_data["game"]["corrupted"]
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/counter.text = str(file_data["player"]["pieces"][0]).pad_zeros(5)
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/piece.visible = true
	else:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/file_name.text = "Empty Game"
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/corrupt.visible = false
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/counter.text = ""
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file1/piece.visible = false
	if FileAccess.file_exists("user://savedata/saveslot2.save"):
		file_data = JSON.parse_string((FileAccess.open("user://savedata/saveslot2.save",FileAccess.READ)).get_as_text())
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/file_name.text = file_data["game"]["save_name"]
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/corrupt.visible = file_data["game"]["corrupted"]
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/counter.text = str(file_data["player"]["pieces"][0]).pad_zeros(5)
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/piece.visible = true
	else:
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/file_name.text = "Empty Game"
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/corrupt.visible = false
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/counter.text = ""
		$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/files/file2/piece.visible = false
		
func _on_select_animation_looped():
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/file_select/buttons_group2/GoBack.play()

func write_blank_save(slot):
	var save_data = {
		"room": {
			"room_name":"giftplane",
			"loading_preset":"giftplane",
			"current_room": "_PLACEHOLDER_"
		},
		"game": {
			"pets": [false,false,false,false,false,false,false,false,false,false],
			"retrace_steps":false,
			"save_name": Global.save_name,
			"corrupted": false
		},
		"player": {
			"coords":[0.0,0.0,0.0,1],
			"pieces":[0,Global.pieces_amount[1],Global.pieces_amount[2],Global.pieces_amount[3],Global.pieces_amount[4]],
			"character":0,
			"control_mode":0,
			"key":false
		}
	}
	Console.console_log("[color=green]Creating blank game data to slot "+str(slot)+"...[/color]")
	var save_game = FileAccess.open("user://savedata/saveslot"+str(slot)+".save",FileAccess.WRITE)
	var json_data = JSON.stringify(save_data)
	save_game.store_line(json_data)
	Console.console_log("[color=blue]Created blank data to slot "+str(slot)+" sucessfully![/color]")


func _on_demo_timer_timeout():
	if allowed_recordings!=[]:
		var picked_recording = allowed_recordings.pick_random()
		Global.demo = true
		Record.load_recording(picked_recording.trim_suffix(".rec"),JSON.parse_string(FileAccess.open(("user://recordings/"+picked_recording),FileAccess.READ).get_as_text())["recording_info"]["gen"],false,true)
