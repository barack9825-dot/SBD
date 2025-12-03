extends CharacterBody3D
class_name Character
@onready var playback : AnimationNodeStateMachinePlayback = $AnimationTree.get('parameters/playback') #Inciializamos en Animation Tree

var axis              :int      #Variable para obtener el eje en que se mira
var raycast_target    : float   #Variable que contiene el valor del tamaño del nodo raycast
var camera_position   : Vector3 #Variable que contiene la posición del Marker3D
var area_position     : float   #Variable que contiene el valor de la posición del area 3D

func state_machine(Animations:Dictionary):
	if Animations.has(playback.get_current_node()):
		Animations[playback.get_current_node()].call()

func flip_h():
	if axis == 1:
		$Sprite3D.flip_h = false
		$RayCast3D.target_position.x = raycast_target
		$Marker3D.position           = camera_position
		$Area3D.position.x	         = area_position

	elif axis == -1:
		$Sprite3D.flip_h = true
		$RayCast3D.target_position.x = -raycast_target
		$Marker3D.position           = -camera_position
		$Area3D.position.x	         = -area_position
