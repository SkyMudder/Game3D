extends Node


onready var toolbar = get_node("/root/World/Player/ToolbarCenterContainer/InventoryDisplay")
var pickable = true

func pickUp(object):
	toolbar.inventory.add(object.resource)
	object.queue_free()
