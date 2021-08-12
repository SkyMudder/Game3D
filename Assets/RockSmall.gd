extends "res://Assets/PickableObjects.gd"


var resource = preload("res://Items/Stone.tres")

func _on_interact():
	pickUp(self)
