extends Control

func _ready():
	$VideoStreamPlayer.stop()
	$VideoStreamPlayer.hide()
	$AudioStreamPlayer2D.play()
	$AnimationPlayer.play("creppy title")


func _on_button_pressed():
	$AudioStreamPlayer2D.stop()
	$VideoStreamPlayer.show()
	$VideoStreamPlayer.play()
	$AnimationPlayer.play("Cinematic")
	$VBoxContainer.hide()
	$Label.hide()


func _process(delta):
	$Label.position.x+=delta

func _on_button_2_pressed():
	get_tree().quit()


func _on_video_stream_player_finished():
	get_tree().change_scene_to_file("res://node_3d.tscn")
