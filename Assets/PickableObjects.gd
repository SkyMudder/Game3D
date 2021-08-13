extends Node


onready var toolbar = get_node("/root/World/Player/ToolbarCenterContainer/InventoryDisplay")

func pickUp(object):
	object.resource.amount = object.amount
	toolbar.inventory.add(object.resource)
	object.queue_free()
