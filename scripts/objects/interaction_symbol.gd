extends Node3D

#CUSTOMIZABLE SETTINGS
@export_group("Display Properties")
@export var height_offset = 0.
@export var min_distance = 2.5
@export var show_while_interacted = true
@export var show_after_interacted = true
@export_group("Dialogue Properties")
@export var show_dialogue = true
@export var dialogue_id = ""
@export var textbox_background = 0
@export_group("Misc.")
@export var behavior = 0

#RELATED-NODES
@onready var interaction_mesh = $height_offset/float_root/interaction_mesh
@onready var symbol_root = $height_offset/float_root

var origin = 0.0

var player_inside_zone = false

#ANIMATION VARIABLES
const HEIGHT_LIMIT = 0.65
const HEIGHT_ANIM_SPEED = 0.65
const ROTATION_LIMIT = 0.25
const ROTATION_ANIM_SPEED = 1.5
const GROW_ANIMATION_SPEED = 0.25

func _ready():
	interaction_mesh.scale = Vector3.ZERO
	$height_offset.position.y = height_offset
	origin = symbol_root.position.y
	animate()
	
func _process(delta):
	if global_position.distance_to(get_tree().get_first_node_in_group("Player").global_position)<min_distance:
		if !player_inside_zone:
			$interaction_sound.play()
			create_tween().tween_property(interaction_mesh,"scale",Vector3(1.,1.,1.),GROW_ANIMATION_SPEED)
		player_inside_zone = true
		
		if show_dialogue:
			if Input.is_action_just_pressed("pressed_action"):
				if Global.control_mode==0 || Global.control_mode==4:
					if get_tree().get_first_node_in_group("HUD_textboxes").get_child(0).get_child_count()==0:
						if Global.dialogue.has(dialogue_id):
							Global.create_textbox(textbox_background,Global.dialogue[dialogue_id])
						elif dialogue_id=="":
							Global.create_textbox(0,["NO TEXT FOUND!"])
						else:
							Global.create_textbox(textbox_background,[dialogue_id])
						interaction_checks()
		else:
			if behavior==0:
				if Input.is_action_just_pressed("pressed_action"):
					if Global.control_mode==0 || Global.control_mode==4:
						Global.create_keyboard(0,true,true)
			if behavior==1:
				if Input.is_action_just_pressed("pressed_action"):
					if Global.control_mode==0 || Global.control_mode==4:
						Global.create_keyboard(1,true,true)
	else:
		create_tween().tween_property(interaction_mesh,"scale",Vector3(0.,0.,0.),GROW_ANIMATION_SPEED)
		if player_inside_zone:
			$interaction_sound.play()
		player_inside_zone = false
		
func interaction_checks():
	if !show_while_interacted:
		$interaction_sound.play()
		create_tween().tween_property(interaction_mesh,"scale",Vector3(0.,0.,0.),GROW_ANIMATION_SPEED)
	if !show_after_interacted:
		$interaction_sound.play()
		var tweener = create_tween()
		tweener.tween_property(interaction_mesh,"scale",Vector3(0.,0.,0.),GROW_ANIMATION_SPEED)
		await tweener.finished
		queue_free()
		
func delete():
	queue_free()
	return true


func animate():
	var tweener_symbol = create_tween().set_loops()
	tweener_symbol.tween_property(symbol_root, "position:y",  origin+randf_range(origin,HEIGHT_LIMIT), HEIGHT_ANIM_SPEED).set_trans(Tween.TRANS_SINE)
	tweener_symbol.tween_property(symbol_root, "position:y", origin-randf_range(origin,HEIGHT_LIMIT), HEIGHT_ANIM_SPEED).set_trans(Tween.TRANS_SINE)
	
	var tweener = create_tween().set_loops()
	tweener.tween_property(interaction_mesh, "rotation:z", ROTATION_LIMIT*-1, ROTATION_ANIM_SPEED).set_trans(Tween.TRANS_SINE)
	tweener.tween_property(interaction_mesh, "rotation:z", ROTATION_LIMIT, ROTATION_ANIM_SPEED).set_trans(Tween.TRANS_SINE)
	
