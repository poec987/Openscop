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
		_:
			console_log("Invalid Command")
		
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
