extends Node3D

const ANIM_SPEED = 10
const HOR_SPEED = 5
const VER_SPEED = 5

var current_frame = 0
var collected = false
var random_sound = 0

func _ready():
	$piece_sprite.frame_coords.y = Global.pieces[get_parent().get_node(str(self.name)).get_index()]
	if Global.gen<=2:
		queue_free()

func _process(delta):
	current_frame+=ANIM_SPEED*delta
	if current_frame>20:
		current_frame=0
	$piece_sprite.frame_coords.x=current_frame
	
	if collected:
		position+= Vector3(0.,VER_SPEED*delta,HOR_SPEED*delta)
	if position.y>10:
		queue_free()


func _on_piece_area_body_entered(body):
	if body==get_tree().get_first_node_in_group("Player"):
		collected=true
		random_sound = randi_range(0,2)
		Global.pieces_amount[Global.current_character]+=1
		if random_sound==0:
			$piece_sound1.play()
		if random_sound==1:
			$piece_sound2.play()
		if random_sound==2:
			$piece_sound3.play()
