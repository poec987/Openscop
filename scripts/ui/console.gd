extends Window

# TODO: fix tooltips
@export_category("Console")
## The [LineEdit] to be parsed.
@export var console_input : LineEdit
## The [RichTextLabel] to display Console output.
@export var console_output : RichTextLabel

func _ready():
	visible = false
	
func _parse_command(input : Array):
	match input[0]:
		"!nifty":
			Global.nifty()
			console_log("[color=blue]The Nifty Menu has been opened.[/color]")
		"!save_game_0":
			Global.save_game(0)
			console_log("[color=blue]Game Data Saved to Slot 1[/color]")
		"!save_game_1":
			Global.save_game(1)
			console_log("[color=blue]Game Data Saved to Slot 2[/color]")
		"!save_game_2":
			Global.save_game(2)
			console_log("[color=blue]Game Data Saved to Slot 3[/color]")
		"!load_game_0":
			Global.load_game(0)
			console_log("[color=blue]Slot 1 Game Data Loaded[/color]")
		"!load_game_1":
			Global.load_game(1)
			console_log("[color=blue]Slot 2 Game Data Loaded[/color]")
		"!load_game_2":
			Global.load_game(2)
			console_log("[color=blue]Slot 3 Game Data Loaded[/color]")
		"!caught":
			Global.caught()
			console_log("[color=blue]CAUGHT![/color]")
		"!toggle_debug":
			Global.debug = !Global.debug
			console_log("[color=blue]DEBUG Toggled[/color]")
		"!shutup":
			Global.bg_music.stop()
			console_log("[color=blue]Music is now mute[/color]")
		"!set_gen_1":
			Global.gen = 1
			console_log("[color=blue]Gen set to 1[/color]")
		"!set_gen_2":
			Global.gen = 2
			console_log("[color=blue]Gen set to 2[/color]")
		"!set_gen_3":
			Global.gen = 3
			console_log("[color=blue]Gen set to 3[/color]")
		"!set_gen_4":
			Global.gen = 4
			console_log("[color=blue]Gen set to 4[/color]")
		"!set_gen_5":
			Global.gen = 5
			console_log("[color=blue]Gen set to 5[/color]")
		"!set_gen_6":
			Global.gen = 6
			console_log("[color=blue]Gen set to 6[/color]")
		"!set_gen_7":
			Global.gen = 7
			console_log("[color=blue]Gen set to 7[/color]")
		"!set_gen_8":
			Global.gen = 8
			console_log("[color=blue]Gen set to 8[/color]")
		"!set_gen_9":
			Global.gen = 9
			console_log("[color=blue]Gen set to 9[/color]")
		"!set_gen_10":
			Global.gen = 10
			console_log("[color=blue]Gen set to 10[/color]")
		"!set_gen_11":
			Global.gen = 11
			console_log("[color=blue]Gen set to 11[/color]")
		"!set_gen_12":
			Global.gen = 12
			console_log("[color=blue]Gen set to 12[/color]")
		"!set_gen_13":
			Global.gen = 13
			console_log("[color=blue]Gen set to 13[/color]")
		"!set_gen_14":
			Global.gen = 14
			console_log("[color=blue]Gen set to 14[/color]")
		"!set_gen_15":
			Global.gen = 15
			console_log("[color=blue]Gen set to 15[/color]")
		_:
			console_log("[color=red]Invalid Command[/color]")
			
func console_log(input):
	console_output.append_text(input)
	console_output.newline()
	console_input.clear()

func _close_requested():
	visible = false

func _on_input_text_submitted(new_text):
	pass
	# Create a command array using the input text 
	#var command_array = new_text.split(" ")
	#_parse_command(command_array)
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") && console_input.text!="":
		var command_array = console_input.text.split(" ")
		console_input.text = ""
		_parse_command(command_array)
