extends Node

var replay = false
var replay_setup = false
var recording = false
var recording_setup = false
var recording_finished = false
var menu_loading = false
var title_loading = false

var recording_timer = 0
var recording_reader_p1 = 0
var recording_reader_p2 = 0
var recording_data = {}

var temporary_data = {}




var input_sim_r1 = null
var input_sim_r2 = null
var input_sim_l1 = null
var input_sim_l2 = null
var input_sim_up = null
var input_sim_down = null
var input_sim_left = null
var input_sim_right = null
var input_sim_action = null
var input_sim_triangle = null
var input_sim_circle = null
var input_sim_square = null
var input_sim_select = null
var input_sim_start = null


var parsed_input_left = false

func current_data():
	var data = {
		"room": {
			"room_name":Global.room_name,
			"loading_preset":Global.loading_preset,
			"current_room": get_tree().get_current_scene().scene_file_path
		},
		"game": {
			"pets": Global.pets.duplicate(),
			"retrace_steps":Global.retrace_steps,
			"save_name": Global.save_name,
			"corrupted":Global.corrupt,
			"piece_log":Global.piece_log.duplicate()
		},
		"player": {
			"coords":[get_tree().get_first_node_in_group("Player").position.x,get_tree().get_first_node_in_group("Player").position.y,get_tree().get_first_node_in_group("Player").position.z,get_tree().get_first_node_in_group("Player").animation_direction],
			"pieces":Global.pieces_amount.duplicate(),
			"character":Global.current_character,
			"control_mode":Global.control_mode,
			"key":Global.key
		}
	}
	return data

func start_recording():
	setup_file()
	recording_setup = true
	recording = true
	Console.console_log("[color=blue]Recording Started.[/color]")
	
func stop_recording():
	if recording_data!={} && recording:
		var save_recording = FileAccess.open(("user://recordings/auto-"+Global.make_random()+".rec"),FileAccess.WRITE)
		var json_data = JSON.stringify(recording_data)
		save_recording.store_line(json_data)
	recording = false
	recording_timer = 0
	recording_setup=false
	Console.console_log("[color=blue]Recording Stopped.[/color]")
	
func number_parser(number):
	if number==1:
		return true
	if number==2:
		return false
		
func check_pressed():
	if Input.is_action_just_pressed("pressed_l1") || Input.is_action_just_pressed("pressed_l2")  || Input.is_action_just_pressed("pressed_r1")  || Input.is_action_just_pressed("pressed_r2")  || Input.is_action_just_pressed("pressed_action") || Input.is_action_just_pressed("pressed_triangle") || Input.is_action_just_pressed("pressed_square") || Input.is_action_just_pressed("pressed_circle") || Input.is_action_just_pressed("pressed_start")|| Input.is_action_just_pressed("pressed_left") || Input.is_action_just_pressed("pressed_right") || Input.is_action_just_pressed("pressed_up") || Input.is_action_just_pressed("pressed_down"):
		return true
	else:
		return false

func check_input():
	if Input.is_action_just_pressed("pressed_l1") || Input.is_action_just_pressed("pressed_l2")  || Input.is_action_just_pressed("pressed_r1")  || Input.is_action_just_pressed("pressed_r2")  || Input.is_action_just_pressed("pressed_action") || Input.is_action_just_pressed("pressed_triangle") || Input.is_action_just_pressed("pressed_square") || Input.is_action_just_pressed("pressed_circle") || Input.is_action_just_pressed("pressed_select") || Input.is_action_just_pressed("pressed_start") || Input.is_action_just_pressed("pressed_left") || Input.is_action_just_pressed("pressed_right") || Input.is_action_just_pressed("pressed_up") || Input.is_action_just_pressed("pressed_down") || Input.is_action_just_released("pressed_l1") || Input.is_action_just_released("pressed_l2")  || Input.is_action_just_released("pressed_r1")  || Input.is_action_just_released("pressed_r2")  || Input.is_action_just_released("pressed_action") || Input.is_action_just_released("pressed_triangle") || Input.is_action_just_released("pressed_square") || Input.is_action_just_released("pressed_circle") || Input.is_action_just_released("pressed_select") || Input.is_action_just_released("pressed_start")|| Input.is_action_just_released("change_mode") || Input.is_action_just_released("pressed_left") || Input.is_action_just_released("pressed_right") || Input.is_action_just_released("pressed_up") || Input.is_action_just_released("pressed_down"):
		return true
	else:
		return false

func check_input_type(key):
	if Input.is_action_just_pressed(key):
		return 1
	if Input.is_action_just_released(key):
		return 2
	if !Input.is_action_just_pressed(key) && !Input.is_action_just_released(key):
		return 0

func setup_file():
	recording_data["recording_info"] = {
		"gen": Global.gen,
		"memcard": true,
		"rotation": true,
	}
	recording_data["save_data"] = {
		"room": {
			"room_name":Global.room_name,
			"loading_preset":Global.loading_preset,
			"current_room": get_tree().get_current_scene().scene_file_path
		},
		"game": {
			"pets": Global.pets.duplicate(),
			"retrace_steps":Global.retrace_steps,
			"corrupted":Global.corrupt,
			"piece_log":Global.piece_log.duplicate()
		},
		"player": {
			"coords":[get_tree().get_first_node_in_group("Player").position.x,get_tree().get_first_node_in_group("Player").position.y,get_tree().get_first_node_in_group("Player").position.z,get_tree().get_first_node_in_group("Player").animation_direction].duplicate(),
			"pieces":Global.pieces_amount.duplicate(),
			"character":Global.current_character,
			"control_mode":Global.control_mode,
			"key":Global.key
		}
	}
	recording_data["p1_data"] = []
	recording_data["p2_data"] = []

func _process(_delta):
	#R1,R2,L1,L2,UP,DOWN,LEFT,RIGHT,Crs,Tri,Cir,Squ,Sel,Sta
	if recording:
		recording_timer+=1
		if check_input() && Global.control_mode!=1 || Input.is_action_just_pressed("pressed_select") || Input.is_action_just_released("pressed_select"):
				recording_data["p1_data"].push_back(str(recording_timer)+"_"+str(check_input_type("pressed_l1"))+"_"+str(check_input_type("pressed_l2"))+"_"+str(check_input_type("pressed_r1"))+"_"+str(check_input_type("pressed_r2"))+"_"+str(check_input_type("pressed_up"))+"_"+str(check_input_type("pressed_down"))+"_"+str(check_input_type("pressed_left"))+"_"+str(check_input_type("pressed_right"))+"_"+str(check_input_type("pressed_action"))+"_"+str(check_input_type("pressed_triangle"))+"_"+str(check_input_type("pressed_circle"))+"_"+str(check_input_type("pressed_square"))+"_"+str(check_input_type("pressed_select"))+"_"+str(check_input_type("pressed_start")))
		if check_pressed() && Global.control_mode==1:
				recording_data["p2_data"].push_back(str(recording_timer)+"_"+get_tree().get_first_node_in_group("Player").word+"_"+get_tree().get_first_node_in_group("p2_word").text)

	if replay:
		if !replay_setup:
			stop_recording()
			recording_finished = false
			recording = false
			recording_timer = 0
			Console.console_log("[color=green]Loading Recording Data...[/color]")
			input_sim_l1 = InputEventAction.new()
			InputMap.action_erase_events("pressed_l1")
			input_sim_l1.set_action("pressed_l1")
			input_sim_l2 = InputEventAction.new()
			InputMap.action_erase_events("pressed_l2")
			input_sim_l2.set_action("pressed_l2")
			input_sim_up = InputEventAction.new()
			input_sim_r1 = InputEventAction.new()
			InputMap.action_erase_events("pressed_r1")
			input_sim_r1.set_action("pressed_r1")
			input_sim_r2 = InputEventAction.new()
			InputMap.action_erase_events("pressed_r2")
			input_sim_r2.set_action("pressed_r2")
			InputMap.action_erase_events("pressed_up")
			input_sim_up.set_action("pressed_up")
			input_sim_down = InputEventAction.new()
			InputMap.action_erase_events("pressed_down")
			input_sim_down.set_action("pressed_down")
			input_sim_left = InputEventAction.new()
			InputMap.action_erase_events("pressed_left")
			input_sim_left.set_action("pressed_left")
			input_sim_right = InputEventAction.new()
			InputMap.action_erase_events("pressed_right")
			input_sim_right.set_action("pressed_right")
			input_sim_action = InputEventAction.new()
			InputMap.action_erase_events("pressed_action")
			input_sim_action.set_action("pressed_action")
			input_sim_triangle = InputEventAction.new()
			InputMap.action_erase_events("pressed_triangle")
			input_sim_triangle.set_action("pressed_triangle")
			input_sim_circle = InputEventAction.new()
			InputMap.action_erase_events("pressed_circle")
			input_sim_circle.set_action("pressed_circle")
			input_sim_square = InputEventAction.new()
			InputMap.action_erase_events("pressed_square")
			input_sim_square.set_action("pressed_square")
			input_sim_select = InputEventAction.new()
			InputMap.action_erase_events("pressed_select")
			input_sim_select.set_action("pressed_select")
			input_sim_start = InputEventAction.new()
			InputMap.action_erase_events("pressed_start")
			input_sim_start.set_action("pressed_start")
			replay_setup = true
		if replay_setup:
			recording_timer+=1
		
	#R1,R2,L1,L2,UP,DOWN,LEFT,RIGHT,Crs,Tri,Cir,Squ,Sel,Sta
		if recording_reader_p1<=recording_data["p1_data"].size()-1:
			if recording_timer==int((recording_data["p1_data"][recording_reader_p1].split("_"))[0]):
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[1])!=0:
					input_sim_l1.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[3])))
					Input.parse_input_event(input_sim_l1)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[2])!=0:
					input_sim_l2.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[4])))
					Input.parse_input_event(input_sim_l2)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[3])!=0:
					input_sim_r1.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[1])))
					Input.parse_input_event(input_sim_r1)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[4])!=0:
					input_sim_r2.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[2])))
					Input.parse_input_event(input_sim_r2)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[5])!=0:
					input_sim_up.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[5])))
					Input.parse_input_event(input_sim_up)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[6])!=0:
					input_sim_down.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[6])))
					Input.parse_input_event(input_sim_down)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[7])!=0:
					input_sim_left.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[7])))
					Input.parse_input_event(input_sim_left)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[8])!=0:	
					input_sim_right.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[8])))
					Input.parse_input_event(input_sim_right)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[9])!=0:	
					input_sim_action.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[9])))
					Input.parse_input_event(input_sim_action)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[10])!=0:	
					input_sim_triangle.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[10])))
					Input.parse_input_event(input_sim_triangle)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[11])!=0:	
					input_sim_circle.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[11])))
					Input.parse_input_event(input_sim_circle)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[12])!=0:
					input_sim_square.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[12])))	
					Input.parse_input_event(input_sim_square)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[13])!=0:	
					input_sim_select.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[13])))
					Input.parse_input_event(input_sim_select)
				if int((recording_data["p1_data"][recording_reader_p1].split("_"))[14])!=0:	
					input_sim_start.set_pressed(number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[14])))
					Input.parse_input_event(input_sim_start)
				if Console.recording_parse:
					Console.console_log("[color=green]PLAYER 1[/color][color=yellow]Frame: "+str(recording_timer)+" Data:"+recording_data["p1_data"][recording_reader_p1]+" Index: "+str(recording_reader_p1)+"[/color]")
				recording_reader_p1+=1
			else:
				if Console.recording_parse:
					Console.console_log("[color=green]PLAYER 1[/color][color=yellow]Frame: "+str(recording_timer)+" Data: [/color][color=red]NONE[/color]")
		
		if recording_reader_p2<=recording_data["p2_data"].size()-1:
			if recording_timer==int((recording_data["p2_data"][recording_reader_p2].split("_"))[0]):
				get_tree().get_first_node_in_group("Player").word = (recording_data["p2_data"][recording_reader_p2].split("_"))[1]
				get_tree().get_first_node_in_group("p2_word").text = (recording_data["p2_data"][recording_reader_p2].split("_"))[2]
				if Console.recording_parse:
					Console.console_log("[color=green]PLAYER 2[/color][color=yellow]Frame: "+str(recording_timer)+" Data:"+recording_data["p2_data"][recording_reader_p2]+" Index: "+str(recording_reader_p2)+"[/color]")
				recording_reader_p2+=1
			else:
				if Console.recording_parse:
					Console.console_log("[color=green]PLAYER 2[/color][color=yellow]Frame: "+str(recording_timer)+" Data: [/color][color=red]NONE[/color]")
		if recording_reader_p1>recording_data["p1_data"].size()-1 && recording_reader_p2>recording_data["p2_data"].size()-1:
			Console.console_log("[color=red]RECORDING IS OVER[/color]")
			InputMap.load_from_project_settings()
			replay = false
			replay_setup = false
			recording_timer = 0
			recording_reader_p1 = 0
			Global.load_global()
			#if menu_loading:
				#Global.pets = temporary_data["game"]["pets"]
				#Global.retrace_steps = temporary_data["game"]["retrace_steps"]
				#Global.corrupt = temporary_data["game"]["corrupted"]
				#Global.player_array = Vector4(temporary_data["player"]["coords"][0],temporary_data["player"]["coords"][1],temporary_data["player"]["coords"][2],temporary_data["player"]["coords"][3])
				#Global.pieces_amount = temporary_data["player"]["pieces"]
				#Global.control_mode = temporary_data["player"]["control_mode"]
				#Global.key = temporary_data["player"]["key"]
				#current_character = save_game["player"]["character"]
				#Global.save_name = temporary_data["game"]["save_name"]
				#Global.piece_log = temporary_data["game"]["piece_log"]
				#warp_to(temporary_data["room"]["current_room"],temporary_data["room"]["loading_preset"])
				#Console.console_log("[color=blue]Loaded Temporary Game Data sucessfully![/color]")
			recording_finished = true
			if title_loading:
				Global.warp_to("res://scenes/rooms/title/title.tscn","evencare")
			menu_loading = false
			title_loading = false
			temporary_data = {}
			recording_data = {}
	
	
	
func replay_inputs():
	recording_timer = 0
	replay = true
	
func load_recording(file, gen: int = 8, menu: bool = false, title: bool = false):
	recording_timer = 0
	menu_loading = menu
	title_loading = title
	#if menu_loading:
		#temporary_data = current_data()
		#Console.console_log("[color=blue]Saved Temporary Game Data sucessfully![/color]")
	recording_data = JSON.parse_string((FileAccess.open("user://recordings/"+file+".rec",FileAccess.READ)).get_as_text())
	Console.console_log("[color=green]Loading Game Data from Recording...[/color]")
	Global.pets = recording_data["save_data"]["game"]["pets"]
	Global.retrace_steps = recording_data["save_data"]["game"]["retrace_steps"]
	Global.corrupt = recording_data["save_data"]["game"]["corrupted"]
	Global.player_array = Vector4(recording_data["save_data"]["player"]["coords"][0],recording_data["save_data"]["player"]["coords"][1],recording_data["save_data"]["player"]["coords"][2],recording_data["save_data"]["player"]["coords"][3])
	Global.control_mode = recording_data["save_data"]["player"]["control_mode"]
	Global.key = recording_data["save_data"]["player"]["key"]
	Global.current_character = recording_data["save_data"]["player"]["character"]
	Global.piece_log = recording_data["save_data"]["game"]["piece_log"]
	Global.warp_to(recording_data["save_data"]["room"]["current_room"],recording_data["save_data"]["room"]["loading_preset"])
	Console.console_log("[color=blue]Loaded Game Data from Recording sucessfully! Replaying inputs...[/color]")
	Global.pieces_amount = recording_data["save_data"]["player"]["pieces"]
	await get_tree().get_first_node_in_group("loading_overlay").get_child(2).timeout
	replay=true
