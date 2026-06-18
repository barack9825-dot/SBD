extends Character


##Declaración de variables exportables
@export  var curve_rejected :Curve     = Curve.new()    ##Curva para la velocidad de impulso cuando es rechazado
@export  var curve_recover  :Curve     = Curve.new()    ##Curva para la velocidad de impulso cuando se recuppera
@export  var acel           :float     = 0.1            ##Aceleración
@export  var dying_time     :float     = 5.0            ##Tiempo de duración de la purificación 
@export  var top_speed      :int       = 2              ##Velocidad Máxima

##Declaración de variables precargadas
@onready var left          :RayCast3D = $RayCastLeft   ##Raycast de la izquierda para detectar enemigos a la izquiera
@onready var right         :RayCast3D = $RayCastRight  ##Raycast de la izquierda para detectar enemigos a la derecha
@onready var state               :AnimationNodeStateMachinePlayback =get_tree().get_first_node_in_group("Player").get_node("AnimationTree").get("parameters/playback")
##señales
signal Attack(myPosition,id)

##Declaración de variables internas
var darkness            :bool  = false ##Para detectar intensidad de la luz
var can_grab            :bool  = false ##Para permitir al enemigo agarrar
var has_player          :bool  = false ##Para detectar si el jugador está en su rango 
var is_atacking         :bool  = false ##Para reflejar el estado de atacando
var is_absorving        :bool  = false ##Para reflejar el estado de absorviendo
var is_being_puryfied   :bool  = false ##Para cuando lo purifican
var is_being_pushed     :bool  = false ##Para cuando lo están pruficando
var has_been_pushed     :bool  = false ##Para cuando lo han empujado
var is_in_area          :bool  = false ##Para detectar la luz
var is_missing          :bool  = false ##Para reflejar el estado de fallando el ataque
var is_recovering       :bool  = false ##Para reflejar el estado de recuperación
var enemy_is_dashing    :bool  = false ##Para cuando esta esquivando
var player_spotted      :bool  = false ##Para recordar la posición del jugado
var area_3D_position    :float         ##Para detectar al jugador
var decoloration        :float = 1.0   ##Para ajustar el valor de la sombra de blanco y negro del enemigo 
var player_position     :float         ##Para guardar la posición del jugador
var progress_bar_value  :float = 0     ##Para cambiar el valor de la barra de progreso
var interp_value        :float = 0.0   ##Valor para desacelerar cuando se ataca
var speed_run           :float = 1     ##Velocidad de correr
var speed_walk          :float = 0.5   ##Velocidad al caminar
var selected_raycast    :RayCast3D

var light


##Constantes
const Gravity :float = 15


##Animaciones
var Animations :Dictionary = {
	'Idle':
		func(): 
			velocity.z    = 0
			is_recovering = true,
	
	'Caminar':
		func(): velocity.z = speed_walk * axis,
	
	'Correr':
		func(): velocity.z = speed_run * axis,
	
	'Atack':
		func():velocity.z = speed_run * axis,
	
	'Atack_2':
		func():velocity.z = speed_run * 2 * axis,
	
	'Absorving':
		func():
			velocity.z         = lerp(speed_run * get_physics_process_delta_time() * axis, 0.0, interp_value)
			interp_value       = clampf(interp_value + 2.0/1.0 * get_physics_process_delta_time(), 0.0, 1.0)
			$Sprite3D.offset.x = 100.0 if $Sprite3D.flip_h else -100.0,
	
	'Absorving2':
		func():
			velocity.z   = lerp(speed_run * get_physics_process_delta_time() * axis, 0.0, interp_value)
			interp_value = clampf(interp_value + 2.0/1.0 * get_physics_process_delta_time(), 0.0, 1.0),
			##El hitbox es 0.72 en z para absorving1
	
	'Absorving_Individual':
		func(): velocity.z = 0,
	
	'Fail_Atack':
		func(): velocity.z = lerp(velocity.z,0.0,0.05),##Arreglar esto

	'BackDash':
		func():
			velocity.z   = lerp(speed_run *-axis * 5,0.0,interp_value)
			interp_value = clampf(interp_value + 1/$AnimationPlayer.get_animation("BackDash").length * get_physics_process_delta_time(),0,1),

	'Being_Pushed':
		func():
			velocity = Vector3.ZERO
			var anim = $AnimationPlayer.get_animation("Being_Pushed")
			anim.track_set_key_value(4, 0, Vector2(-axis * 118, 0)), 
	
	'Recover':
		func():
			if !is_recovering:tween_func(0.25,0.0,$AnimationPlayer.get_animation("Recover").length,curve_recover)
			is_recovering = true
}


##Inicialización
func _ready():
	playback.start("Idle")
	axis                                               = 1
	$Sprite_Progress_Bar.visible                       = false
	$Sprite_Progress_Bar/SubViewport/ProgressBar.value = 0


##Funciones del Bucle Jugable
func attack_behavior():

	var col
	var distance
	if selected_raycast != null: col = selected_raycast.get_collider()
	
	if col != null:
		distance = position.z - col.position.z
		
		if abs(distance) <= 0.3 && distance/axis < 0 && !enemy_is_dashing:
			if !playback.get_current_node() == "BackDash" && col.is_on_floor(): emit_signal("Attack",position,get_groups()[1])

		player_position = col.position.z

func behavior():
	var col = selected_raycast.get_collider()
	## Para virarse en la dirección del jugador
	if playback.get_current_node() in ["Atack_2","Fail_Atack"]: axis   = selected_raycast.target_position.z / abs(selected_raycast.target_position.z) 
	var distance    = abs(position.z - col.position.z)
	player_position = col.position.z
	axis            = selected_raycast.target_position.z / abs(selected_raycast.target_position.z) 
	
	if  distance < 1 && !(playback.get_current_node() in ["Been_Pushed","Recover"]): 
		playback.travel("Atack_2")
		
		is_atacking = true
	
	else: playback.travel("Correr")

func being_purified(delta)->void:
	if is_being_puryfied:
		RenderingServer.global_shader_parameter_set("puryfing",true)
		RenderingServer.global_shader_parameter_set("player_selected",position)

		$Sprite_Progress_Bar.visible                        = true
		$Sprite_Progress_Bar/SubViewport/ProgressBar.value  = lerp(0,100,progress_bar_value)
		progress_bar_value                                 += 1/dying_time * delta 

		RenderingServer.global_shader_parameter_set("purifyng_progress",progress_bar_value)
	else:
		RenderingServer.global_shader_parameter_set("puryfing",false)

		$Sprite_Progress_Bar.visible                       = false
		progress_bar_value                                 = clampf(progress_bar_value- 1/dying_time * delta,0,1)
		if progress_bar_value != 0: RenderingServer.global_shader_parameter_set("purifyng_progress",progress_bar_value)
		$Sprite_Progress_Bar/SubViewport/ProgressBar.value = 0


func blind_spot() ->void:
	if $Sprite3D.flip_h:
		$RayCastLeft.target_position.z  = 2.37
		$RayCastRight.target_position.z = -3
	else:
		$RayCastLeft.target_position.z  = 3
		$RayCastRight.target_position.z = -2.37

func checkPlayer() -> void:
	var distance = abs(position.z - player_position)
	if distance > 5: axis = -(distance)/abs(distance)

func detect_colissions() -> bool:
	if get_colissions(left) ||  get_colissions(right):
		if !player_spotted: $MemoryTimer.start()
		player_spotted = true
	else:
		player_spotted   = false
		selected_raycast = null

	return player_spotted

func get_colissions( Raycast:RayCast3D ) ->bool:
	if Raycast.is_colliding():
		var col = Raycast.get_collider() as CharacterBody3D
		if col.is_in_group("Player") && player_detector(col): 
			selected_raycast = Raycast
			return true
		else: return false
	
	else: return false

##Arreglar esto, cuando el enemigo esté en idle se va a virar siempre para el mismo lado
func flip_h(): $Sprite3D.flip_h = axis == -1  

func movement(frame):
	velocity.y = -Gravity * frame
	
	move_and_slide()
	
	if enemy_is_dashing: playback.travel("BackDash")
	elif is_being_pushed && has_been_pushed: 
		playback.travel("Been_Pushed")
		
		tween_func(speed_run * 3,0.25,$AnimationPlayer.get_animation("Been_Pushed").length,curve_rejected)

	elif has_been_pushed: playback.travel("Being_Pushed")
	
	elif is_absorving:
		if (detect_colissions()):
			player_position = selected_raycast.get_collider().position.z
			axis            = (player_position-position.z)/abs(player_position-position.z)
		
		playback.travel("Absorving_Individual")
	
	
	elif is_missing: 
		playback.travel("Fail_Atack")
		attack_behavior()
	
	elif (detect_colissions()):
		if !is_atacking: behavior()
		else: attack_behavior()

	else:playback.travel("Correr" if !$MemoryTimer.is_stopped() else "Caminar")
	
	state_machine(Animations)
	
	if playback.get_current_node() != "Fail_Atack" :flip_h()

func tween_func(top_speed,bottom_speed,duration,curve):
	var tween = create_tween()
	
	tween.tween_method(func(interp_value):curve_func_tween(interp_value,top_speed,bottom_speed,curve),0.0,1.0,duration)

func player_detector(player) ->bool:
	#print((player.position.z - position.z)/axis)
	return state.get_current_node()!="Sigilo" || ((player.position.z - position.z)/axis>0 && state.get_current_node()=="Sigilo")

##Bucle Jugable
func _process(delta):
	
	if is_in_area: darkness = light.light_energy <= 1.8
	else: darkness = false
	
	being_purified(delta)
	
	if !is_being_puryfied && (!is_in_area || (is_in_area && darkness)): movement(delta)
	else: 
		playback.travel("Idle")
	
	blind_spot()
	
	if !$MemoryTimer.is_stopped():checkPlayer()


##Eventos
func enter_light_area(light_entered:SpotLight3D):
	is_in_area   = true
	light        = light_entered

func enter_omni_light_area(light_entered:OmniLight3D):
	is_in_area = true
	light      = light_entered

func exit_light_area(): is_in_area = false

func exit_omni_light_area(): is_in_area = false

func _on_dying_timer_timeout():queue_free()

func _on_player_confirm(ans,Playerposition,id):
	if id == get_groups()[1]: 
		is_absorving = ans
		axis         = (Playerposition.z-position.z)/abs(Playerposition.z-position.z)

func _on_player_freedom(player_position,id):
	if id == get_groups()[1]: 
		is_atacking         = false
		is_absorving        = false
		has_been_pushed     = true

func _on_player_purify(state,id):
	match state:
		"start":	
			$DyingTimer.start(dying_time)
			
			is_being_puryfied = true
		
		"interrupt":
			$DyingTimer.stop()
			
			is_being_puryfied = false

func _on_top_detector_body_entered(body):
	if body.is_in_group("Player"):
		var angle = rad_to_deg(atan2(body.velocity.y,body.velocity.z))
		
		if (angle < -110 && angle > -120) || (angle < -60 && angle > -70):
			enemy_is_dashing  = true
			is_atacking       = false


##Funciones auxiliares
func curve_func_tween(t,top_speed,bottom_speed,curve):
	var direction = 1 if $Sprite3D.flip_h else -1
	velocity.z    = direction * lerp(top_speed,bottom_speed,curve_rejected.sample(t))

func end_been_pushed():
	is_being_pushed     = false
	has_been_pushed     = false
	interp_value        = 0

func end_dashing():
	enemy_is_dashing    = false
	interp_value        = 0

func miss():
	is_missing  = true

func recover(): 
	is_missing  = false
	is_atacking = false
	
func startBeingPushed(): is_being_pushed = true

func turn(): axis *= -1
