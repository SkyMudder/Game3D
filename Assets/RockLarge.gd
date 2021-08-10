extends "res://Assets/FarmableObjects.gd"

var recentlyDamaged : bool = false
var hp = 1000

func _on_Hurtbox_area_entered(_area):
	print("entered")
	takeDamage(self)
