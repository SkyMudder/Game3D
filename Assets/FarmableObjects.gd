extends Node


var pickable = false
onready var player = get_node("/root/World/Player")
onready var playerTargetHealth = get_node("/root/World/Player/TargetHealth")
onready var toolbar = get_node("/root/World/Player/ToolbarCenterContainer/InventoryDisplay")

"""Reduce the Objects HP if hit with an appropriate Tool/Item
Update HP on the UI"""
func takeDamage(object) -> void:
	if !object.recentlyDamaged and player.playerItem != null:
		if checkItemCompatible(object, player.playerItem.damageType, player.playerItem.level):
			object.recentlyDamaged = true
			object.hp -= 100 * player.playerItem.damageMultiplier
			playerTargetHealth.showAndReset()
			playerTargetHealth.value = object.hp
		if object.hp <= 0:
			object.resource.amount = object.amount
			toolbar.inventory.add(object.resource)
			playerTargetHealth.hide()
			object.queue_free()
	
"""Check if an Item is compatible with the Farmable Object"""
func checkItemCompatible(object, damageType, level) -> bool:
	var a = object.damageType == damageType
	var b = object.level <= level
	return a and b
