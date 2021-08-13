extends "res://Assets/PickableObjects.gd"


var resource = preload("res://Items/Stone.tres")
var amount = 1

func _on_interact():
	pickUp(self)
