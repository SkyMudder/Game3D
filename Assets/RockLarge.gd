extends "res://Assets/FarmableObjects.gd"

var hp = 1000

func _on_Hurtbox_area_entered(_area):
	print("entered")
	takeDamage(self)
