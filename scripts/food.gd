extends Node3D

const SPRITESHEET_ROWS = 2
const SPRITESHEET_COLUMNS = 4
const ANIMATION_SPEED = 14

var type = 0
var frame = 0
var collected = false

@onready var sprite = get_node("food_child/food_collision/food_sprite")

func random():
	seed(26 + hash(position))
	type = randi_range(0, SPRITESHEET_ROWS -1)
	
func _ready():
	random()
	sprite.set_surface_override_material(0, sprite.get_surface_override_material(0).duplicate())
	sprite.get_surface_override_material(0).uv1_offset.y = type * (1.00 / SPRITESHEET_ROWS)
	
func _process(delta):
	frame += ANIMATION_SPEED * delta
	var x = round(frame) * (1.00 / SPRITESHEET_COLUMNS)
	x -= floor(x)
	sprite.get_surface_override_material(0).uv1_offset.x = x
		
func _on_food_child_body_entered(_body):
	collected = true
	Global.food_counter += 1
	sprite.visible = false
	queue_free()
