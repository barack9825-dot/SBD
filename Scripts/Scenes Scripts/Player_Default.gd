extends CharacterBody3D
@onready var playback : AnimationNodeStateMachinePlayback = $AnimationTree.get('parameters/playback') #Inciializamos en Animation Tree

###Declaración de variables###

@export  var speed    : float                             = 1.0                                       #Velocidad del jugador

var running_speed   : int     = speed * 2    #Multiplicador de la velocidad corriendo
var stealth_speed   : float   = speed * 0.5  #Multiplicador de la velocidad en sigilo
var axis            : Vector2 = Vector2.ZERO #Variable que contiene la dirección elegida por el judador segun los controles
var can_climb       : bool    = false        #Variable para establecer el momento en que la animacion de escalar termina
var raycast_target  : float                  #Variable que contiene el valor del tamaño del nodo raycast
var camera_position : Vector3                #Variable que contiene la posición del Marker3D

const Jump_Height  = 5                       #Constante para la alturea del salto
const Gravity     = 15                       #Constante para la gravedad


###Inicialización###
func _ready() ->void:
	#Inicializamos las variables relacionadas con los nodos
	raycast_target  = $RayCast3D.target_position.x
	camera_position = $Marker3D.position


func get_axis() ->Vector2:
	#Función para obtener la direccion en la que se desea que el jugador mire
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return axis


func state_machine() ->void:

	match playback.get_current_node():  #Función para elegir varios parámetros de acuerdo con el tipo de animacion que esté activa en cada bloque:
										 #1-Se establecen los parametros 
										 #2-Se establecen las condiciones (Botones presionados, Cambios en el jugador) para cambiar de animacion
									   
										#En la primer bloque se puede ver un ejemplo 

###Bloque de animaciones terrestres###
 
		'Idle': #Idle=Parado

			#Se evaluan los parámetros
			velocity.z = 0


			#Se establecen las condiciones para cambiar de animación
			playback.travel(ground_motion())


		'Caminar':

			velocity.z = -get_axis().x * speed

			playback.travel(ground_motion())


		"Correr":

			velocity.z = -get_axis().x * running_speed

			playback.travel(ground_motion())


		"Sigilo":

			velocity.z = -get_axis().x * stealth_speed

			playback.travel(ground_motion())



###Bloque de animaciones aéreas###

		"Elevar":

			playback.travel(air_motion())


		"Incorporar":

			playback.travel(air_motion())


		'Caer':

				if is_on_floor():
					playback.travel('Idle')

##Bloque de animaciones de interaccion con el suelo

		'Aterrizar':

			velocity.z = 0


		'Subir': #Subir=Escalar

			if can_climb:

				if $Sprite3D.flip_h:
					$Sprite3D.scale.x = -0.25
					$Sprite3D.flip_h  = false

				can_climb = false

			velocity                   = Vector3.ZERO
			$CollisionShape3D.disabled = true


###Bloque de animaciones de transición

		'Idle_Caminar_Transition':

			velocity.z = -get_axis().x * speed * 0.5

			playback.travel(ground_motion())

			if get_axis().x == 0:
				playback.travel("Idle")


		'Caminar_Idle_Transition':

			velocity.z *= -0.1

			playback.travel(ground_motion()) ##OJO ESTO ESTA PROVOCANDO UN ERRO EN EL SALTO

		'Idle_Correr_transition':

			velocity.z = -get_axis().x * running_speed

			playback.travel(ground_motion()) ##OJO ESTO ESTA PROVOCANDO UN ERRO EN EL SALTO

		'Idle_Correr_transition 2':

			velocity.z = -get_axis().x * running_speed

			playback.travel(ground_motion()) ##OJO ESTO ESTA PROVOCANDO UN ERRO EN EL SALTO

		'Correr_Idle_transition':

			velocity.z *= -0.1

			playback.travel(ground_motion()) ##OJO ESTO ESTA PROVOCANDO UN ERRO EN EL SALTO

func ground_motion() ->String: #Función para establecer las condiciones en las animaciones terrestres
	if is_on_floor():
		can_climb = true
		
		if Input.is_action_just_pressed("ui_accept") && playback.get_current_node() != 'Aterrizar':
			velocity.y += Jump_Height

			return "Elevar"
		
		if get_axis().x != 0:

			if Input.is_action_pressed("Correr"):
				return "Correr"
				
			elif Input.is_action_pressed("Sigilo"):
				return "Sigilo"

			else:
				return "Caminar"

		else:
			return "Idle"

	elif can_climb:
		return "Caer"

	else: 
		return "Idle"


func air_motion() ->String: #Función para establecer las condiciones en las animaciones aéreas

	if $RayCast3D.is_colliding():
		var col = $RayCast3D.get_collider()

		if col.is_in_group("Plataforma"):
			$RayCast3D.enabled = false

			return "Subir"
	
	if velocity.y < 0:
		return "Caer"
	
	elif velocity.y < 20 :
		return "Incorporar"
	
	else:
		return "Elevar"


func climb() ->void: #Función para habilitar que el personaje escale

	if !is_on_floor() && $RayCast3D.is_colliding():
		var col = $RayCast3D.get_collider()

		if col.is_in_group("Plataforma"):
			$RayCast3D.enabled = false

			playback.travel("Subir")


func physics(frame) ->void: #Función para corregir las físicas del personaje cuando este se le desplaza por código de forma abrupta

	if(velocity.x != 0):

		print("I'm falling!!!")

		set_velocity(Vector3(0,-Gravity*frame,0))


func flip_h() ->void: #Función para voltear el Sprite en la dirección correcta

	if playback.get_current_node() != "Subir":

		if get_axis().x == 1 :
			$Sprite3D.flip_h             = false
			$RayCast3D.target_position.x = raycast_target
			$Marker3D.position           = camera_position

		elif get_axis().x == -1:
			$Sprite3D.flip_h             = true
			$RayCast3D.target_position.x = -raycast_target
			$Marker3D.position           = -camera_position


func updatePosAfterClimb() ->void: #Funcion que se encarga de establecer la posicion del nodo al terminar la animacion de subir en función de el offset del Sprite

	var actualPosition:Vector3 = Vector3( #Se establece la nueva posición del nodo
		0,                                                               
		$Sprite3D.offset.y,                                              
		$Sprite3D.offset.x * -$Sprite3D.scale.x / abs($Sprite3D.scale.x)
		#En este caso se multiplica por el opuesto de la escala entre su valor absoluto para obtener ajustar la posicion segun la direccion en la que mire
		)

	set_position(position + actualPosition * abs($Sprite3D.scale.x) / 100)

	$Sprite3D.offset = Vector2.ZERO
	
	if $Sprite3D.scale.x == -0.25:
		$Sprite3D.flip_h = true

	$Sprite3D.scale.x          = 0.25
	$CollisionShape3D.disabled = false


###Funcion process###
func _physics_process(delta) ->void:

	velocity.y -= Gravity * delta

	state_machine()

	move_and_slide()

	flip_h()

	physics(delta)


