extends Node

@onready var camera3D: Camera3D = $Camera3D


var transitioning: bool = false

func _ready() -> void:
	camera3D.current = false

func switch_camera(from:Camera3D, to:Camera3D) -> void:
	from.current = false
	to.current = true



func transition_camera3D_Into(from: Camera3D, to: Camera3D, duration: float = 1.0) -> void:
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if transitioning: return
	# Copy the parameters of the first camera
	camera3D.fov = from.fov
	camera3D.cull_mask = from.cull_mask
	
	# Move our transition camera to the first camera position
	camera3D.global_transform = from.global_transform
	
	# Make our transition camera current
	camera3D.current = true
	
	transitioning = true
	
	# Move to the second camera, while also adjusting the parameters to
	# match the second camera
	#tween.remove_all()
	
	tween.tween_property($Camera3D,"global_transform",to.global_transform,duration)
	#tween.interpolate_property(camera3D, "global_transform", camera3D.global_transform, 
		#to.global_transform, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.tween_property($Camera3D,"fov",to.fov,duration)
	#tween.interpolate_property(camera3D, "fov", camera3D.fov, 
		#to.fov, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	#tween.start()
	
	# Wait for the tween to complete
	#await tween.tween_all_completed
	tween.tween_callback(func():
		if camera3D.current:
			to.current = true	
		transitioning = false)
	# Make the second camera current
func transition_camera3D_Outo(node_group:String):
	
	var Camera=get_tree().get_first_node_in_group(node_group)
	Camera.fov = camera3D.fov
	Camera.cull_mask = camera3D.cull_mask
	
	# Move our transition camera to the first camera position
	Camera.global_transform = camera3D.global_transform
	Camera.current=true
