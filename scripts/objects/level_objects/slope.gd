@tool
extends Node3D

@export_subgroup("Slope Settings:")
@export var slope_length = 0.
@export var slope_width = 1.
@export var slope_direction = 0
@export var slope_up = true
@export var change_brightness = false
@export var has_platform_on_end = true
#func _ready():
func _ready():
	if slope_direction==0 || slope_direction==3:
			if abs(abs(get_tree().get_first_node_in_group("Player").global_position.x)-$slope_start.global_position.x)<=slope_width:	
				if slope_direction==0:
					if get_tree().get_first_node_in_group("Player").global_position.z>=$slope_start.global_position.z && get_tree().get_first_node_in_group("Player").global_position.z<=$slope_end.global_position.z:
						slope_processing_z()
				
				if slope_direction==3:
					if get_tree().get_first_node_in_group("Player").global_position.z<=$slope_start.global_position.z && get_tree().get_first_node_in_group("Player").global_position.z>=$slope_end.global_position.z:
						slope_processing_z()
	elif slope_direction==1 || slope_direction==2:
		if abs(abs(get_tree().get_first_node_in_group("Player").global_position.z)-$slope_start.global_position.z)<=slope_width:
			if slope_direction==1:
				if get_tree().get_first_node_in_group("Player").global_position.x>=$slope_start.global_position.x && get_tree().get_first_node_in_group("Player").global_position.x<=$slope_end.global_position.x:
					slope_processing_x()
			if slope_direction==2:
				if get_tree().get_first_node_in_group("Player").global_position.x<=$slope_start.global_position.x && get_tree().get_first_node_in_group("Player").global_position.x>=$slope_end.global_position.x:
					slope_processing_x()

func _process(_delta):
	
	if Engine.is_editor_hint():
		if slope_direction==0:
			$slope_end.position.z=slope_length
			$slope_end.position.x=0.0
		if slope_direction==3:
			$slope_end.position.z=slope_length*-1
			$slope_end.position.x=0.0
		if slope_direction==1:
			$slope_end.position.x=slope_length
			$slope_end.position.z=0.0
		if slope_direction==2:
			$slope_end.position.x=slope_length*-1
			$slope_end.position.z=0.0
			
	if !Engine.is_editor_hint():
		if slope_direction==0:
			$slope_end.position.z=slope_length
			$slope_end.position.x=0.0
		if slope_direction==3:
			$slope_end.position.z=slope_length*-1
			$slope_end.position.x=0.0
		if slope_direction==1:
			$slope_end.position.x=slope_length
			$slope_end.position.z=0.0
		if slope_direction==2:
			$slope_end.position.x=slope_length*-1
			$slope_end.position.z=0.0
			
		
		if slope_direction==0 || slope_direction==3:
			
			if abs(abs(get_tree().get_first_node_in_group("Player").global_position.x)-$slope_start.global_position.x)<=slope_width:	
				if slope_direction==0:
					if get_tree().get_first_node_in_group("Player").global_position.z>=$slope_start.global_position.z && get_tree().get_first_node_in_group("Player").global_position.z<=$slope_end.global_position.z:
						slope_processing_z()
						get_tree().get_first_node_in_group("Player_sprite").get_material_override().set_shader_parameter("modulate_color", Vector4($slope_end.global_position.z,$slope_end.global_position.z,$slope_end.global_position.z,1.0))
					else:
						if has_platform_on_end:
							if get_tree().get_first_node_in_group("Player").global_position.z<=$slope_end.global_position.z:
								gravity()
						else:
							gravity()
				
				if slope_direction==3:
					if get_tree().get_first_node_in_group("Player").global_position.z<=$slope_start.global_position.z && get_tree().get_first_node_in_group("Player").global_position.z>=$slope_end.global_position.z:
						slope_processing_z()
						get_tree().get_first_node_in_group("Player_sprite").get_material_override().set_shader_parameter("modulate_color", Vector4($slope_end.global_position.z,$slope_end.global_position.z,$slope_end.global_position.z,1.0))
					else:
						if has_platform_on_end:
							if get_tree().get_first_node_in_group("Player").global_position.z>=$slope_end.global_position.z:
								gravity()
						else:
							gravity()
			else:
				if slope_direction==0:
					if get_tree().get_first_node_in_group("Player").global_position.z<=$slope_end.global_position.z:
						gravity()
				if slope_direction==3:
					if get_tree().get_first_node_in_group("Player").global_position.z>=$slope_end.global_position.z:
						gravity()
		elif slope_direction==1 || slope_direction==2:
			
			if abs(abs(get_tree().get_first_node_in_group("Player").global_position.z)-$slope_start.global_position.z)<=slope_width:
				if slope_direction==1:
					if get_tree().get_first_node_in_group("Player").global_position.x>=$slope_start.global_position.x && get_tree().get_first_node_in_group("Player").global_position.x<=$slope_end.global_position.x:
						slope_processing_x()
					else:
						if has_platform_on_end:
							if get_tree().get_first_node_in_group("Player").global_position.x<=$slope_end.global_position.x:
								gravity()
						else:
							gravity()
				
				if slope_direction==2:
					if get_tree().get_first_node_in_group("Player").global_position.x<=$slope_start.global_position.x && get_tree().get_first_node_in_group("Player").global_position.x>=$slope_end.global_position.x:
						slope_processing_x()
					else:
						if has_platform_on_end:
							if get_tree().get_first_node_in_group("Player").global_position.x>=$slope_end.global_position.x:
								gravity()
						else:
							gravity()
			else:
				if slope_direction==1:
					if get_tree().get_first_node_in_group("Player").global_position.x<=$slope_end.global_position.x:
						gravity()
						
				if slope_direction==2:
					if get_tree().get_first_node_in_group("Player").global_position.x>=$slope_end.global_position.x:
						gravity()
			
				
func slope_processing_z():
	if slope_up:
		#get_tree().get_first_node_in_group("Player_sprite").get_material_override().set_shader_parameter("modulate_color", Vector4(clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.z)-$slope_start.global_position.z)/2),0.,1.),clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.z)-$slope_start.global_position.z)/2),0.,1.),clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.z)-$slope_start.global_position.z)/2),0.,1.),1.0))
		get_tree().get_first_node_in_group("Player_sprite").position.y=abs(abs(get_tree().get_first_node_in_group("Player").global_position.z)-$slope_start.global_position.z)
	else:
		#get_tree().get_first_node_in_group("Player_sprite").get_material_override().set_shader_parameter("modulate_color", Vector4(clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.z)-$slope_end.global_position.z)/2),0.,1.),clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.z)-$slope_end.global_position.z)/2),0.,1.),clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.z)-$slope_end.global_position.z)/2),0.,1.),1.0))
		get_tree().get_first_node_in_group("Player_sprite").position.y=(abs(abs(get_tree().get_first_node_in_group("Player").global_position.z)-$slope_start.global_position.z))*-1
	
func slope_processing_x():
	if slope_up:
		#get_tree().get_first_node_in_group("Player_sprite").get_material_override().set_shader_parameter("modulate_color", Vector4(clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.x)-$slope_start.global_position.x)/2),0.,1.),clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.x)-$slope_start.global_position.x)/2),0.,1.),clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.x)-$slope_start.global_position.x)/2),0.,1.),1.0))
		get_tree().get_first_node_in_group("Player_sprite").position.y=abs(abs(get_tree().get_first_node_in_group("Player").global_position.x)-$slope_start.global_position.x)
	else:
		#get_tree().get_first_node_in_group("Player_sprite").get_material_override().set_shader_parameter("modulate_color", Vector4(clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.x)-$slope_end.global_position.x)/2),0.,1.),clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.x)-$slope_end.global_position.x)/2),0.,1.),clamp(abs(abs((get_tree().get_first_node_in_group("Player").global_position.x)-$slope_end.global_position.x)/2),0.,1.),1.0))
		get_tree().get_first_node_in_group("Player_sprite").position.y=abs(abs(get_tree().get_first_node_in_group("Player").global_position.x)-$slope_start.global_position.x)*-1


func gravity():
	if get_tree().get_first_node_in_group("Player_sprite").position.y<=0.:
		get_tree().get_first_node_in_group("Player_sprite").position.y=0.
	if get_tree().get_first_node_in_group("Player_sprite").position.y>=0.:
		if get_tree().get_first_node_in_group("Player_sprite").position.y>=0.5:
			get_tree().get_first_node_in_group("Player_sprite").position.y-=0.5
		else:
			get_tree().get_first_node_in_group("Player_sprite").position.y=0.
