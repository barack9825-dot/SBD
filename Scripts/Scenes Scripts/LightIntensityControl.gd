extends Node3D
@onready var light : Light3D = $SpotLight3D

#Eventos
func _on_player_intensity(I,id):
	if id == "spotlight":
		if I == 'x': light.light_energy -= 5 * get_process_delta_time()
		if I == 'z': light.light_energy += 5 * get_process_delta_time()

func _on_ligh_area_body_entered(body):
	#print("Something Spotted it´s a ", body) 
	if body.is_in_group("Enemy"):
		#print("It´s an enemy") 
		body.enter_light_area(light)

func _on_ligh_area_body_exited(body):
	if body.is_in_group("Enemy"): body.exit_light_area()
