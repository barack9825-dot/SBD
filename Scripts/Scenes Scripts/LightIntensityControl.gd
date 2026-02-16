extends SpotLight3D


#Eventos
func _on_player_intensity(I,id):
	if id == "spotlight":
		if I == 'x': light_energy -= 5 * get_process_delta_time()
		if I == 'z': light_energy += 5 * get_process_delta_time()

func _on_ligh_area_body_entered(body):
	if body.is_in_group("Enemy"): 
		body.enter_light_area(self)
		#enemyposition = body.position.z
	
func _on_ligh_area_body_exited(body):
	if body.is_in_group("Enemy"): body.exit_light_area()
