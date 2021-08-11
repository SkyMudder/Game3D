extends "res://Assets/FarmableObjects.gd"


var timer : Timer
var hp = 1000
var level = 0
var recentlyDamaged = false
var damageType = Types.resourceType.WOOD
var resource = preload("res://Items/Wood.tres")
var amount = 6

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "_on_timer_timeout")
	
	
func _on_Hurtbox_area_entered(_area):
	takeDamage(self)
	if timer.time_left == 0:
		timer.start()
	
func _on_timer_timeout():
	recentlyDamaged = false
