extends Node3D

@onready var spot_light             = $spotLightMeacnism/SpotLight3D
@onready var enemy                  = $Enemy as CharacterBody3D

@export  var CurveLight     : Curve = Curve.new()                      # Curva para mover la luz

##Variables
var activate_bend     : bool    = false        ##Para activar el control de las luces del escenario
var interpolate       : float   = 0.0          ##Variable de interpolación para algunas transcisiones
var finalRotation     : Vector3 = Vector3.ZERO ##Para obtener la rotación deseada
var spotLightRotation : Vector3 = Vector3.ZERO ##Para obtener la rotación inicial del spotlight

##Inicialización
func _ready():
	spotLightRotation = spot_light.rotation
	RenderingServer.global_shader_parameter_add("player_pos2",RenderingServer.GLOBAL_VAR_TYPE_VEC3,Vector3.ZERO)
	#$AudioStreamPlayer.play()

func shader_assingment():
		for i in get_node("BlenderImportCopy").get_children() as Array[MeshInstance3D]:
			if i.get_class() == "MeshInstance3D":
				i.set_instance_shader_parameter("player_pos",enemy.position)

##Bucle jugable
func _process(_delta):
	if $Enemy:
		RenderingServer.global_shader_parameter_set("player_pos",$Enemy.position)
	else:
		RenderingServer.global_shader_parameter_set("player_pos",Vector3(1000,0,0))
	if $Enemy2:
		RenderingServer.global_shader_parameter_set("player_pos2",$Enemy2.position)

	
	if activate_bend:
		var dir             = ($Player.global_position-spot_light.global_position).normalized()
		var basis           = spot_light.basis.looking_at(dir,Vector3.UP)
		finalRotation       = basis.get_euler()
		var playerCloseness = $Player.global_position.distance_to(spot_light.global_position)
		
		if playerCloseness <=2 && playerCloseness >=-2:
			spot_light.rotation = lerp(spotLightRotation,finalRotation,interpolate)
			interpolate         = clampf(interpolate+4 * get_process_delta_time(),0,1)
		
		else:
			spot_light.rotation = lerp(spotLightRotation,finalRotation,interpolate)
			interpolate         = clampf(interpolate - 4 * get_process_delta_time(),0,1)
	
	else: 
		spot_light.rotation = lerp(spotLightRotation,finalRotation,interpolate)
		interpolate         = clampf(interpolate - 4 * get_process_delta_time(),0,1)


##Eventos
func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"): TransitionCamera.transition_camera3D_Into($PlayerCamera,$ZoneCamera,0.5)

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"): TransitionCamera.transition_camera3D_Outo("PlayerCamera")

func _on_button_pressed(): get_tree().quit()

func _on_area_3d_2_body_exited(body):
	if body.has_method('turn'): body.turn()

func _on_player_light_bend(is_bending): activate_bend = is_bending

#Funciones Auxiliares

func CurveFuncLigh():
	spot_light.look_at()


func _on_area_3d_3_body_exited(body):
	if body.has_method('turn'): body.turn()
