extends Window

# TODO: fix tooltips
@export_category("Console")
## The [LineEdit] to be parsed.
@export var console_input : LineEdit
## The [RichTextLabel] to display Console output.
@export var console_output : RichTextLabel

func _close_requested():
	visible = false

func _on_input_text_submitted(new_text):
	var command_array = new_text.split(" ")
	_parse_command(command_array)
	
func _parse_command(input : Array):
	match input[0]:
		"Test":
			_log("test")
		"_":
			print("INVALID COMMAND!")
			
func _log(input):
	console_output.append_text(input)
	console_input.clear()
