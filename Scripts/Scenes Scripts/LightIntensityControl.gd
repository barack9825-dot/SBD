extends SpotLight3D

#Variables
var enemyposition : float                                        #Para acceder a la posicion del enemigo 
var frame         : int                                          #Para seleccionar cuál de los dos puntos del proyector se va a activar



func _physics_process(delta):
	
	enemyposition = get_tree().get_nodes_in_group("Enemy")[0].global_position.z


	
	

		
	


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
