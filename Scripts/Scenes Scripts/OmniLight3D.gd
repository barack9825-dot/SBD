extends OmniLight3D

func _on_player_intensity(I,id):
	if id == "omnilight":
		if I == 'x':
			light_energy -= 5 * get_process_delta_time()
		if I == 'z':
			light_energy += 5 * get_process_delta_time()



func _on_omni_light_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.enterOmniLightArea(self)


func _on_omni_light_area_body_exited(body):
	if body.is_in_group("Enemy"):
		body.exitOmniLightArea()
