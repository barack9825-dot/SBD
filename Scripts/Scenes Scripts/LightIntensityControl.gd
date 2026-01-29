extends SpotLight3D

#Variables
var graystyle     : bool  = false                                #Para activar la mascara de gris de la luz
var enemyposition : float                                        #Para acceder a la posicion del enemigo 
var frame         : int                                          #Para seleccionar cuál de los dos puntos del proyector se va a activar
var grad_tex              = light_projector as GradientTexture2D #Instancia del gradiente 2D


func _physics_process(delta):
	
	enemyposition = get_tree().get_nodes_in_group("Enemy")[0].global_position.z

	var offset = (enemyposition - global_position.z)/2

	if offset > 0: 
		frame = 1
		grad_tex.gradient.set_color(frame,Color(0.5,0.5,1.04))
		grad_tex.gradient.set_color(0,Color(1,1,1))
		grad_tex.gradient.set_offset(frame,clamp(offset,0,1)) 

	else: 
		frame = 0
		grad_tex.gradient.set_color(frame,Color(0.5,0.5,1.04))
		grad_tex.gradient.set_color(1,Color(1,1,1))
		grad_tex.gradient.set_offset(frame,clamp(abs(1/offset),0,1)) 
	
	

		
	


#Eventos
func _on_player_intensity(I,id):
	if id == "spotlight":
		if I == 'x': light_energy -= 5 * get_process_delta_time()
		if I == 'z': light_energy += 5 * get_process_delta_time()

func _on_ligh_area_body_entered(body):
	if body.is_in_group("Enemy"): 
		body.enter_light_area(self)
		graystyle = true
		#enemyposition = body.position.z
	
func _on_ligh_area_body_exited(body):
	if body.is_in_group("Enemy"): body.exit_light_area()
