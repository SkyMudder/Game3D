extends "res://Objects/PickableObjects.gd"


var resource: Resource = preload("res://Items/Stone.tres")
var amount: int = 1

func _on_interact() -> void:
	pickUp(self)
