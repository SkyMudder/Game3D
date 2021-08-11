extends Node


onready var player = get_node("/root/World/Player")
onready var toolbar = get_node("/root/World/Player/ToolbarCenterContainer/InventoryDisplay")

func takeDamage(object):
	if !object.recentlyDamaged and player.playerItem != null:
		if checkItemCompatible(object, player.playerItem.damageType, player.playerItem.level):
			object.recentlyDamaged = true
			object.hp -= 100
		if object.hp <= 0:
			object.resource.amount = object.amount
			toolbar.inventory.add(object.resource)
			object.queue_free()
	
func checkItemCompatible(object, damageType, level) -> bool:
	var a = object.damageType == damageType
	var b = object.level == level
	return a and b
