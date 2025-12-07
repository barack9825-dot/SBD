extends Node3D

@onready var light_rotation = $spotLightMeacnism/SpotLight3D.rotation
@onready var spot_light     = $spotLightMeacnism/SpotLight3D

##Variables
var activate_bend :bool  = false ##Para activar el control de las luces del escenario
var interpolate   :float = 0.0   ##Variable de interpolación para algunas transcisiones


##Inicialización
func _ready():
	pass
	#$AudioStreamPlayer.play()


##Bucle jugable
func _process(delta):
	#RenderingServer.global_shader_parater_set("player_pos",$Enemy.position)
	if activate_bend:
		var playerCloseness = $Player.global_position.distance_to(spot_light.global_position)
		if playerCloseness <=2 && playerCloseness >=-2:
			spot_light.rotation = lerp(
				spot_light.rotation,spot_light.look_at($Player.global_position,Vector3.UP)
				,interpolate
				)
			interpolate        += 4 * get_process_delta_time()
	
	else: spot_light.rotation = light_rotation


##Eventos
func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"): TransitionCamera.transition_camera3D_Into($PlayerCamera,$ZoneCamera,0.5)

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"): TransitionCamera.transition_camera3D_Outo("PlayerCamera")

func _on_button_pressed(): get_tree().quit()

func _on_area_3d_2_body_exited(body):
	if body.has_method('turn'): body.turn()

func _on_player_light_bend(is_bending): activate_bend = is_bending
