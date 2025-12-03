extends Panel

@onready var item_visual :Sprite2D = $CenterContainer/Panel/Item_Display
@onready var amount: Label = $CenterContainer/Panel/Label

func update(slot: InvSlot):
	if !slot.item:
		item_visual.visible = false
		amount.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
		amount.visible = true
		amount.text = str(slot.amount)
