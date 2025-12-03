extends CharacterBody3D
@onready var playback : AnimationNodeStateMachinePlayback = $AnimationTree.get('parameters/playback') #Inciializamos en Animation Tree

var spritesheetIdle = preload("res://Assets/SpriteSheet/Idle SpriteSheet.png")
var spritesheetWalk = preload("res://Assets/SpriteSheet/Caminar SpriteSheet.png")
var spritesheetRun = preload("res://Assets/SpriteSheet/Correr SpriteSheet.png")
var spritesheetDash = 	preload("res://Assets/SpriteSheet/Esquive SPRITESHEET.png")
var hframes
var vframes
var speed_factor = 1

const Gravity = 15
const Speed = 10

func _ready():
	playback.start("Idle")

func _process(delta):
	match playback.get_current_node():
		'Idle':
			$Sprite3D.texture = spritesheetIdle
			$Sprite3D.hframes = 4
			$Sprite3D.vframes = 4
		'Walk':
			$Sprite3D.texture = spritesheetWalk
			$Sprite3D.hframes = 4
			$Sprite3D.vframes = 4
		'Run':
			$Sprite3D.texture = spritesheetRun
			$Sprite3D.hframes = 4
			$Sprite3D.vframes = 5
		'Dash':
			$Sprite3D.texture = spritesheetDash
			$Sprite3D.hframes = 6
			$Sprite3D.vframes = 10
	move_and_slide()
	velocity.y -= Gravity * delta
	velocity.z = -(int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))) * Speed * delta * speed_factor
	$Sprite3D.flip_h = velocity.z > 0
	
	if velocity.z != 0:
		playback.travel("Walk")
		if Input.is_action_pressed("Correr"):
			playback.travel("Run")
			if Input.is_action_pressed("Dash"):
				playback.travel("Dash")
		else:
			playback.travel("Walk")

	else:
		playback.travel("Idle")

	if Input.is_action_pressed("Correr"):
		speed_factor = 5
	else:
		speed_factor = 1
	


func _on_enemy_attack(myPosition):
	pass # Replace with function body.
