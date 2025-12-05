extends Character

@export var dyingTime  : float = 5.0
@export var speed      : float = 1.0                                                                     #Velocidad del jugador
@export var inventory  : Inv
@export var curve      : Curve = Curve.new()
@export var curveClimb : Curve = Curve.new()
@export var interp     : float = 0.0 
@export var Jump_Speed : float = 40

signal Intensity(I,id)
signal Purify(state)
signal Freedom(myPosition)
signal LightBend(is_bending)
signal Confirm(ans,position)

##Declaración de variables
var can_climb         : bool    = false       #Variable para establecer el momento en que la animacion de escalar termina
var can_dash          : bool    = true        #Variable para establecer el momento del esquive   
var can_release       : bool    = true        #Variable para poder liberarse del agarre
var is_being_absorbed : bool    = false       #Variable para saber si esta siendo purificado
var is_dashing        : bool    = false       #Variable para saber si esta esquivando
var is_in_area        : bool    = false       #Variable para detectar si esta en el area de encendido y apagado
var is_purifying      : bool    = false       #Permite al jugador activar la animación de purificar
var near_enemy        : bool    = false       #Permite detectar si es hay un enemigo para poder purificarlo
var running_speed     : float   = speed * 2   #Multiplicador de la velocidad corriendo
var stealth_speed     : float   = speed * 0.5 #Multiplicador de la velocidad en sigilo
var identify          : String                #Variable para identificar el tipo de nodo de luz con el que estamos intereactuando
var screen_size       : Vector2               #Variable que almacena el tamaño de la pantalla            
var enemyNear         : Vector3               #Para saber donde esta el enemigo que te esta purificando  
var path_position     : Vector3               #Para obtener la posición global del path
var storaged_error    : Vector3               #Para la acción integral
var tween             : Tween                 #Instancia del tween
##Declaración de constantes
const Gravity      = 15 ##Constante para la gravedad

##Animaciones
var Animations : Dictionary = {
	'Idle':
		func():
			velocity = Vector3.ZERO
			$Path3D/PathFollow3D.progress_ratio = 0
			$Path3D.position = Vector3.ZERO
			playback.travel(ground_motion()),
	
	'Caminar':
		func():
			velocity.z = -get_axis() * speed
			playback.travel(ground_motion()),
	
	'Sigilo':
		func():
			velocity.z = -get_axis() * stealth_speed
			playback.travel(ground_motion()),
	
	'Correr':
		func():
			velocity.z = -get_axis() * running_speed
			playback.travel(ground_motion()),
	
	'Elevar':
		func(): 
			velocity.z = -get_axis() * running_speed
			playback.travel(air_motion()),
	
	'Caer':
		func(): 
			velocity.z = -get_axis() * running_speed
			playback.travel(air_motion()),
	
	'Incorporar':
		func(): 
			velocity.z = -get_axis() * running_speed
			playback.travel(air_motion()),
	
	'Aterrizar':
		func(): 
			velocity.z = 0
			playback.travel(ground_motion()),
	
	'Subir':
		func():
			if can_climb:
				$Path3D.global_position = path_position
				var error               = $Path3D/PathFollow3D.global_position-position
				storaged_error         += error
				velocity                = 6 * error + 0.7 * storaged_error, 
	
	'Idle_Caminar_Transition':
		func():
			velocity.z = -get_axis() * speed * 0.5
			playback.travel(ground_motion()),
	
	'Caminar_Idle_Transition':
		func():
			velocity.z *= -0.1
			playback.travel(ground_motion()),
	
	'Idle_Correr_Transition':
		func():
			velocity.z = -get_axis() * running_speed
			playback.travel(ground_motion()),
	
	'Idle_Correr_transition 2':
		func():
			velocity.z = -get_axis() * running_speed
			playback.travel(ground_motion()),
	
	'Correr_Idle_Transition':
		func():
			velocity.z *= -0.1
			playback.travel(ground_motion()),
	
	'Being_Absorbed':
		func(): velocity = Vector3.ZERO,
	
	'Being_Absorbed 2':
		func(): velocity = Vector3.ZERO,
	
	'Dash':
		func():
			playback.travel(ground_motion()),

}

##Inicialización
func _ready() ->void:
	playback.start("Idle")
	raycast_target                      = $RayCast3D.target_position.x
	camera_position                     = $Marker3D.position
	area_position                       = $Area3D.position.x
	screen_size                         = get_viewport().size
	$CanvasLayer/Inventory.position     = Vector2( 250, screen_size.y - 250)
	storaged_error                      = Vector3.ZERO

##Lógica de obtencón de dirección
func get_axis() ->int:
	##Función para obtener la direccion en la que se desea que el jugador mire
	axis = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return axis


##Funciones del bucle jugable
func ground_motion() ->String: ##Función para establecer las condiciones en las animaciones terrestres
	if is_on_floor():
		can_climb = true ##OJO veriicar si es necesario la condicion is_on_floor
		if is_being_absorbed:
			tweenFunc(abs(position.z-enemyNear.z)-0.21,position.z,0.2)
			return "Being_Absorbed"
		
		if Input.is_action_just_pressed("ui_accept") && playback.get_current_node() != 'Aterrizar':
			velocity.y += Jump_Speed
			return "Elevar"
		
		if get_axis() != 0:
			if Input.is_action_pressed("Correr"):
				if Input.is_action_just_pressed("Dash") && playback.get_current_node()=="Correr":
					if can_dash:
						var duration = $AnimationPlayer.get_animation("Dash").length
						tweenFunc(1,position.z,duration)
						return "Dash"
				
				return "Correr"
			
			elif Input.is_action_pressed("Sigilo"): return "Sigilo"
			else:                                   return "Caminar"
		
		else: return "Idle"
	
	elif can_climb: return "Caer"
	else:           return "Idle"

func air_motion() ->String: ##Función para establecer las condiciones en las animaciones aéreas
	if is_being_absorbed:

		tweenFunc2(abs(position.z - enemyNear.z) - 0.21,position.z,0.2,abs(position.y - enemyNear.y),position.y)
		return "Being_Absorbed 2"
	
	if $RayCast3D.is_colliding():
		var col = $RayCast3D.get_collider()
		if col.is_in_group("Plataforma"):
			$RayCast3D.enabled = false
			path_position      = $Path3D.global_position
			$CollisionShape3D.disabled = true
			tweenFuncT($Path3D/PathFollow3D.progress_ratio,$AnimationPlayer.get_animation("Subir").length)
			return "Subir"
	
	if   velocity.y < 0:  return "Caer"
	elif velocity.y < Jump_Speed * 3/10: return "Incorporar"
	elif is_on_floor():   return "Aterrizar"
	else:                 return "Elevar"

func climb() ->void: ##Función para habilitar que el personaje escale
##OJO arreglar bug cuando el personaje cae y pasa por la esquina de la plataforma 
##activando el climb pero continuando con su caida
	if !is_on_floor() && $RayCast3D.is_colliding():
		var col = $RayCast3D.get_collider()
		if col.is_in_group("Plataforma"):
			$RayCast3D.enabled = false
			playback.travel("Subir")

##Función para corregir las físicas del personaje cuando este se le desplaza por código de forma abrupta
##Buscar una manera de corregir esto de mejor manera
func physics(frame) ->void: 
	if(velocity.x != 0):
		set_velocity(Vector3(0,-Gravity*frame,0))
	if(position.x !=2.05): position.x = 2.05

func flip_h_player() ->void: ##Función para voltear el Sprite en la dirección correcta
	if !["Subir","Being_Absorved","Being_Absorved2","Dash_2","Caminar_Idle_Transition"].has(playback.get_current_node()): flip_h()
	
	if is_being_absorbed:
		var distance =position.z-enemyNear.z
		axis = distance/abs(distance)

func updatePosAfterClimb() ->void: ##Función que se encarga de establecer la posicion del nodo al terminar la animacion de subir en función de el offset del Sprite
	##Se establece la nueva posición del nodo
	var actualPosition:Vector3 = Vector3(
		0,
		$Sprite3D.offset.y,
		$Sprite3D.offset.x * -$Sprite3D.scale.x / abs( $Sprite3D.scale.x )#En este caso se multiplica por el opuesto de la escala entre su valor absoluto para obtener ajustar la posicion segun la direccion en la que mire
		)
	set_position(position + actualPosition * abs( $Sprite3D.scale.x ) / 100)
	$Sprite3D.offset           = Vector2.ZERO
	if $Sprite3D.scale.x == -0.25: $Sprite3D.flip_h = true
	$Sprite3D.scale.x          = 0.25
	$CollisionShape3D.disabled = false

func impulse(to_speed:float, time:float, displacement:float) ->float:
	return (2 * displacement - to_speed * time)/time

func jump_modulator(frame) ->void:
	if playback.get_current_node() != "Subir":
		if !is_on_floor():
			if !Input.is_action_pressed("ui_accept"): velocity.y -= Gravity/2 * 1.5  * frame
			else: velocity.y -= Gravity/2 * frame

func IntesityEmitter() ->void:
	if is_in_area:
		if Input.is_action_pressed("X"): emit_signal("Intensity","x",identify)
		if Input.is_action_pressed("Z"): emit_signal("Intensity","z",identify)

func Collect(item): inventory.insert(item)

func light_bend():
	if Input.is_action_pressed("Light_Bend"): emit_signal("LightBend",true)
	if Input.is_action_just_released("Light_Bend"): emit_signal("LightBend",false)

func release():
	if Input.is_action_just_pressed("Liberarse"):
		is_being_absorbed                                  = false
		interp                                              = 0.0
		playback.travel("Idle")
		$DyingTime.stop()
		emit_signal("Freedom",position.z)

func motion(delta):
	if !is_purifying:
		state_machine(Animations)
		if !is_being_absorbed: jump_modulator(delta)
		if playback.get_current_node() != "Dash": 
			move_and_slide()
			flip_h_player()
		if !is_being_absorbed: jump_modulator(delta)
	
	climb()
	physics(delta)

func tweenFunc(distance,from,duration):
	reset_tween()
	tween.tween_method(func(interp):curveFuncX(interp,distance,from),0.0,1.0,duration)

func tweenFunc2(distanceX,fromX,duration,distanceY,fromY):
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_method(func(interp):curveFuncX(interp,distanceX,fromX),0.0,1.0,duration)
	tween.tween_method(func(interp):curveFuncY(interp,distanceY,fromY),0.0,1.0,duration)

func tweenFuncT(progRatio,duration):
	var tween = create_tween()
	tween.tween_method(func(interp):curveFuncT(progRatio,interp),0.0,1.0,duration)

func curveFuncX(t,distance,from):
	var axis = -1 if $Sprite3D.flip_h else 1
	position.z = lerp(from,from + distance * -axis,curve.sample(t))

func curveFuncY(t,distance,from):
	position.y = lerp(from,from - distance,curve.sample(t))

func curveFuncT(progRatio,t):
	$Path3D/PathFollow3D.progress_ratio = lerp(0.0,1.0,curveClimb.sample(t))


##Bucle jugable
func _physics_process(delta) ->void:
	$Path3D.scale.x = 1 if $Sprite3D.flip_h else -1 
	if Input.is_action_just_pressed("Purificar") && near_enemy && !is_being_absorbed: emit_signal("Purify","start")
	is_purifying = Input.is_action_pressed("Purificar") && near_enemy
	if Input.is_action_just_released("Purificar") && near_enemy: emit_signal("Purify","interrupt")
	
	if is_being_absorbed && can_release:
		release()
	
	light_bend()
	motion(delta)
	IntesityEmitter()


##Eventos 
func endDashing():
	is_dashing = false
	$Cooldown.start()
	can_dash = false

func _on_area_3d_2_body_entered(body):
	is_in_area = true
	identify   = "spotlight"

func _on_area_3d_2_body_exited(body):is_in_area = false

func _on_area_3d_3_body_entered(body):
	is_in_area = true
	identify   = "omnilight"

func _on_area_3d_3_body_exited(body): is_in_area = false

func _on_area_3d_body_entered(body): if body.is_in_group("Enemy"): near_enemy = true

func _on_area_3d_body_exited(body): if body.is_in_group("Enemy"): near_enemy = false

func _on_enemy_attack(enemyPosition):
	enemyNear = enemyPosition
	if !is_dashing:
		is_being_absorbed = true
		$DyingTime.start(dyingTime)
		emit_signal("Confirm",true,position)
	else: emit_signal("Confirm",false)

func _on_dying_time_timeout():get_tree().quit()

func _on_cooldown_timeout():
	can_dash = true

func reset_tween():
	if tween:
		tween.kill()
	tween = create_tween()

func start_dashing():
	is_dashing = true

func end_climbing():
	$CollisionShape3D.disabled = false
	$RayCast3D.enabled = true

func gameOver():
	can_release = false
