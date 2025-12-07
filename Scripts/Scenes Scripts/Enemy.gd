extends Character
##Declaración de variables
@onready var Left       :RayCast3D = $RayCastLeft   ##Raycast de la izquierda para detectar enemigos a la izquiera
@onready var Right      :RayCast3D = $RayCastRight  ##Raycast de la izquierda para detectar enemigos a la derecha
@export  var acel       :float     = 0.1            ##Aceleración
@export  var topSpeed   :int       = 2              ##Velocidad Máxima
@export  var dying_time :float     = 5.0    
@export  var range      :float     = 0.5

signal Attack(myPosition)


var darkness            :bool  = false ##Para detectar intensidad de la luz
var can_grab            :bool  = false ##Para permitir al enemigo agarrar
var has_player          :bool  = false ##Para detectar si el jugador está en su rango 
var is_atacking         :bool  = false ##Para reflejar el estado de atacando
var is_being_puryfied   :bool  = false ##Para cuando lo purifican
var is_being_pushed     :bool  = false ##Para cuando lo están pruficando
var is_dashing          :bool  = false ##Para cuando esta esquivando
var is_have_been_pushed :bool  = false ##Para cuando lo han empujado
var is_in_area          :bool  = false ##Para detectar la luz
var is_absorving        :bool  = false ##Para reflejar el estado de absorviendo
var is_missing          :bool  = false ##Para reflejar el estado de fallando el ataque
var player_spotted      :bool  = false ##Para recordar la posición del jugado
var area3Dposition      :float         ##Para detectar al jugador
var playerPosition      :float         ##Para guardar la posición del jugador
var progressBarValue    :float = 0     ##Para cambiar el valor de la barra de progreso
var interpValue         :float = 0.0   ##Valor para desacelerar cuando se ataca
var speedRun            :float = 1    ##Velocidad de correr
var speedWalk           :float = 0.5    ##Velocidad al caminar
var Light
var SelectedRaycast           :RayCast3D

##Constantes
const Gravity :float = 15


##Animaciones
var Animations :Dictionary = {
	'Idle':
		func(): velocity.z = 0,
	
	'Caminar':
		func(): 
			velocity.z = speedWalk * axis,
	
	'Correr':
		func(): velocity.z = speedRun * axis,
	
	'Atack':
		func():velocity.z = speedRun * axis,
	
	'Atack_2':
		func():velocity.z = speedRun * 2 * axis,

	'Absorving':
		func():
			velocity.z         = lerp(speedRun * get_physics_process_delta_time() * axis, 0.0, interpValue)
			interpValue        = clampf(interpValue + 2.0/1.0 * get_physics_process_delta_time(), 0.0, 1.0)
			$Sprite3D.offset.x = 100.0 if $Sprite3D.flip_h else -100.0,
	
	'Absorving2':
		func():
			velocity.z  = lerp(speedRun * get_physics_process_delta_time() * axis, 0.0, interpValue)
			interpValue = clampf(interpValue + 2.0/1.0 * get_physics_process_delta_time(), 0.0, 1.0),
			##El hitbox es 0.72 en z para absorving1
	
	'Absorving_Individual':
		func(): velocity.z = 0,
	
	'Fail_Atack':
		func(): velocity.z = lerp(velocity.z,0.0,0.05),##Arreglar esto
	
	'BackDash':
		func():
			velocity.z = lerp(speedRun *-axis * 5,0.0,interpValue)
			interpValue = clampf(interpValue + 1/$AnimationPlayer.get_animation("BackDash").length * get_physics_process_delta_time(),0,1),

	'Being_Pushed':
		func():
			velocity = Vector3.ZERO
			var anim = $AnimationPlayer.get_animation("Being_Pushed")
			anim.track_set_key_value(5, 0, Vector2(-axis * 118, 0)), 
	
	'Been_Pushed':
		func():
			velocity.z = lerp(3 * speedRun * (1 if $Sprite3D.flip_h else -1),0.0,interpValue)
			interpValue = clampf(interpValue + 1/$AnimationPlayer.get_animation("Been_Pushed").length * get_physics_process_delta_time(),0,1),
	
	'Recover':
		func():
			velocity = Vector3.ZERO
}


##Inicialización
func _ready():
	playback.start("Idle")
	axis                                               = 1
	$Sprite_Progress_Bar.visible                       = false
	$Sprite_Progress_Bar/SubViewport/ProgressBar.value = 0



##Funciones del Bucle Jugable

func detect_colissions() ->bool:
	if get_colissions(Left) ||  get_colissions(Right):
		player_spotted=true
		return true
	else:
		SelectedRaycast = null
		return false

func get_colissions( Raycast:RayCast3D ) ->bool:
	if Raycast.is_colliding():
		var col = Raycast.get_collider()
		if col.is_in_group("Player"): 
			SelectedRaycast = Raycast

			return true
		else: 
			return false

	else: 
		return false

func Behavior():
	var col        = SelectedRaycast.get_collider()
	
	## Para virarse en la dirección del jugador
	if playback.get_current_node() != "Atack_2" && playback.get_current_node() != "Fail_Atack":
			axis   = SelectedRaycast.target_position.z / abs(SelectedRaycast.target_position.z) 
	
	var distance   = abs(position.z - col.position.z)
	playerPosition = col.position.z
	
	
	if  distance < 1: 
		playback.travel("Atack_2")

		axis   = SelectedRaycast.target_position.z / abs(SelectedRaycast.target_position.z) 
		is_atacking = true
	else: playback.travel("Correr")

func AttackBehavior():
	var col      = SelectedRaycast.get_collider()
	var distance = position.z-col.position.z
	
	if abs(distance) <= 0.3 && distance/axis < 0 && !is_dashing:
		if !playback.get_current_node() == "BackDash" && col.is_on_floor():
			emit_signal("Attack",position)
	playerPosition = col.position.z

func movement(frame):
	velocity.y = -Gravity * frame
	
	move_and_slide()
	
	if is_dashing: playback.travel("BackDash")
	
	elif is_being_pushed && is_have_been_pushed: playback.travel("Been_Pushed")
	
	elif is_have_been_pushed: playback.travel("Being_Pushed")
	
	elif is_absorving:
		if (detect_colissions()):
			playerPosition = SelectedRaycast.get_collider().position.z
			axis = (playerPosition-position.z)/abs(playerPosition-position.z)
		playback.travel("Absorving_Individual")
	
	elif is_missing: playback.travel("Fail_Atack")
	
	elif (detect_colissions()):
		if !is_atacking:Behavior()
		else: AttackBehavior()
	
	else: 
		if $MemoryTimer.is_stopped() && player_spotted: 
			$MemoryTimer.start()
		playback.travel("Correr" if player_spotted else "Caminar")
	state_machine(Animations)
	
	if playback.get_current_node() != "Fail_Atack" :flip_h()

func blindSpot():
	if $Sprite3D.flip_h:
		$RayCastLeft.target_position.z = 2.37
		$RayCastRight.target_position.z = -3
	else:
		$RayCastLeft.target_position.z = 3
		$RayCastRight.target_position.z = -2.37
		

##Arreglar esto, cuando el enemigo esté en idle se va a virar siempre para el mismo lado
func flip_h(): 
	$Sprite3D.flip_h = axis == -1  


func Being_Purified(delta):
	if is_being_puryfied:
		$Sprite_Progress_Bar.visible                        = true
		$Sprite_Progress_Bar/SubViewport/ProgressBar.value  = lerp(0,100,progressBarValue)
		progressBarValue                                   += 1/dying_time * delta 
	
	else:
		$Sprite_Progress_Bar.visible                       = false
		progressBarValue                                   = 0
		$Sprite_Progress_Bar/SubViewport/ProgressBar.value = 0

func checkPlayer():
	if player_spotted:
		var distance = abs(position.z - playerPosition)
		if distance > 5:
			axis = -(position.z-playerPosition)/abs(position.z - playerPosition)


##Bucle Jugable
func _process(delta):

	
	if is_in_area: darkness = Light.light_energy <= 1.8
	else: darkness = false
	
	Being_Purified(delta)
	
	if !is_being_puryfied && (!is_in_area || (is_in_area && darkness)): movement(delta)
	else: playback.travel("Idle")
	
	blindSpot()
	
	checkPlayer()


##Eventos
func enterLightArea(light:SpotLight3D):
	is_in_area   = true
	Light = light

func enterOmniLightArea(light:OmniLight3D):
	is_in_area = true
	Light    = light

func exitLightArea(): is_in_area = false

func exitOmniLightArea(): is_in_area = false

func _on_player_purify(state):
	match state:
		"start":	
			$DyngTimer.start(dying_time)
			is_being_puryfied = true
		"interrupt":
			$DyngTimer.stop()
			is_being_puryfied = false

func miss():
	is_missing = true
	is_atacking = false

func recover():
	is_missing = false

func _on_player_freedom(playerPosition):
	is_atacking  = false
	is_absorving = false
	is_have_been_pushed = true

func turn(): axis *= -1

func _on_player_confirm(ans,Playerposition): 
	is_absorving = ans
	axis = (Playerposition.z-position.z)/abs(Playerposition.z-position.z)

func _on_dyng_timer_timeout():queue_free()

func _on_memory_timer_timeout():
	player_spotted = false

func _on_top_detector_body_entered(body):
	if body.is_in_group("Player"):
		var angle = rad_to_deg(atan2(body.velocity.y,body.velocity.z))
		if (angle < -110 && angle > -120) || (angle < -60 && angle > -70):
			is_dashing = true
			is_atacking = false
		else:
			emit_signal("Attack",position)

func endDashing():
	is_dashing = false
	interpValue = 0

func startBeingPushed():
	is_being_pushed = true

func end_been_pushed():
	is_being_pushed = false
	is_have_been_pushed = false
	interpValue = 0
