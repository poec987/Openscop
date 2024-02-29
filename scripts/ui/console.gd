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
			$ConsoleContainer/Input.clear()
		"!save_game_0":
			Global.save_game(0)
			$ConsoleContainer/Input.clear()
		"!save_game_1":
			Global.save_game(1)
			$ConsoleContainer/Input.clear()
		"!save_game_2":
			Global.save_game(1)
			$ConsoleContainer/Input.clear()
		"!load_game_0":
			Global.load_game(0)
			$ConsoleContainer/Input.clear()
		"!load_game_1":
			Global.load_game(1)
			$ConsoleContainer/Input.clear()
		"!load_game_2":
			Global.load_game(2)
			$ConsoleContainer/Input.clear()
		_:
			console_log("[color=red]Invalid Command[/color]")
		
func console_log(input):
	console_output.append_text(input)
	console_output.newline()
	console_input.clear()

func _close_requested():
	visible = false

func _on_input_text_submitted(new_text):
	# Create a command array using the input text 
	var command_array = new_text.split(" ")
	_parse_command(command_array)
