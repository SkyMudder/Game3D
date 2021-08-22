extends Node


onready var toolbar: GridContainer= get_node("/root/World/Player/ToolbarCenterContainer/InventoryDisplay")

func pickUp(object: Object) -> void:
	object.resource.amount = object.amount
	toolbar.inventory.add(object.resource)
	object.queue_free()
