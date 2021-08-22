extends Node


var pickable: bool = false

onready var player: KinematicBody = get_node("/root/World/Player")
onready var playerTargetHealth: ProgressBar = get_node("/root/World/Player/TargetHealth")
onready var toolbar: GridContainer = get_node("/root/World/Player/ToolbarCenterContainer/InventoryDisplay")
onready var BreakingEffect: PackedScene = preload("res://Particles/ObjectBreaking.tscn")
onready var DamagingEffect: PackedScene = preload("res://Particles/ObjectDamaged.tscn")

"""Reduce the Objects HP if hit with an appropriate Tool/Item
Update HP on the UI"""
func takeDamage(object: Object) -> void:
	if !object.recentlyDamaged and player.playerItem != null:
		if checkItemCompatible(object, player.playerItem.damageType, player.playerItem.level):
			object.recentlyDamaged = true
			createDamagingEffect(object)
			object.hp -= 100 * player.playerItem.damageMultiplier
			playerTargetHealth.showAndReset()
			playerTargetHealth.value = object.hp
		if object.hp <= 0:
			object.resource.amount = object.amount
			toolbar.inventory.add(object.resource)
			playerTargetHealth.hide()
			createBreakingEffect(object)
			object.queue_free()
	
"""Check if an Item is compatible with the Farmable Object"""
func checkItemCompatible(object: Object, damageType: int, level: int) -> bool:
	var a: bool = object.damageType == damageType
	var b: bool = object.level <= level
	return a and b
	
func createBreakingEffect(object: Object) -> void:
	var effect: Particles = BreakingEffect.instance()
	effect.draw_pass_1.material = object.material
	effect.translation = object.translation 
	object.get_parent().add_child(effect)
	effect.emitting = true
	
func createDamagingEffect(object: Object) -> void:
	var effect: Particles = DamagingEffect.instance()
	effect.draw_pass_1.material = object.material
	effect.translation = object.effectOffset
	object.add_child(effect)
	effect.emitting = true
