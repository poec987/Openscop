extends Window

# TODO: fix tooltips
@export_category("Console")
## The [LineEdit] to be parsed.
@export var console_input : LineEdit
## The [RichTextLabel] to display Console output.
@export var console_output : RichTextLabel

func _ready():
	pass 

func _process(_delta):
	pass

func _close_requested():
	visible = false
