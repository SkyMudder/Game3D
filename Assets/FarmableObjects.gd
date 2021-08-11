extends Node


onready var HealthBar = preload("res://UIElements/HealthBar3D.tscn")
onready var player = get_node("/root/World/Player")
onready var playerTargetHealth = get_node("/root/World/Player/TargetHealth")
onready var toolbar = get_node("/root/World/Player/ToolbarCenterContainer/InventoryDisplay")

func takeDamage(object):
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
	
func checkItemCompatible(object, damageType, level) -> bool:
	var a = object.damageType == damageType
	var b = object.level == level
	return a and b
	
	
func create3DProgressBar():
	var healthBar = HealthBar.instance()
	return healthBar
