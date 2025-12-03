extends Camera3D
@onready var followPosition = get_parent().get_node('Player/Marker3D') #Posición del nodo Marker 3D  del CharacterBody
@export var Smoothness      = 0.1                                               #Parámetro que indica la suavidad con la que trancisiona la camara

var newPosition  : Vector2 = Vector2.ZERO #Variable para almacenar el valor de la nueva posición asignada a la cámara
var offset       : float                  #Variable que posee la difeencia de pisición entre la camara y el nodo Marker3D del CharacterBody
var followPlayer : bool    = true         #Variable para saber cuando seguir o no al jugador

##Inicialización
func _ready():
	offset = global_transform.origin.y - followPosition.global_position.y


##Funciones del bucle jugable
func updatePos():
	newPosition = Vector2(
		lerp(
		global_transform.origin.z,
		followPosition.global_position.z,
		Smoothness
		),
		global_transform.origin.y
		#lerp(
		#global_transform.origin.y,
		#followPosition.global_position.y + offset,
		#Smoothness)
		)
	global_transform.origin.z = newPosition.x
	#global_transform.origin.y = newPosition.y


##Bucle Jugable
func _process(delta):
	if followPlayer: updatePos()

func _on_player_follow_camera(confirm):
	followPlayer = confirm
