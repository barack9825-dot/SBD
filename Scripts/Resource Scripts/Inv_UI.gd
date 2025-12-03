extends Control

@onready var inventory: Inv = preload("res://Resources/Player_Inventory.tres")
@onready var slots :Array =  $NinePatchRect/GridContainer.get_children()

func _ready():
	inventory.update.connect(func():return update_slots())
	visible = false
	update_slots()

func update_slots():
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])

func toggleInventoryVisibility():
	visible = !visible

func _process(delta):
	if Input.is_action_just_pressed("Inventory"):
		toggleInventoryVisibility()
