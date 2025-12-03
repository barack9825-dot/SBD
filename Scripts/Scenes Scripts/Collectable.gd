extends StaticBody3D

@export var item:InvItem

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):

		body.Collect(item)
		queue_free()


