extends "res://Assets/FarmableObjects.gd"


var timer : Timer
var hp : int = 1000
var level : int = 1
var recentlyDamaged = false
var damageType = Types.resourceType.WOOD
var resource : Resource = preload("res://Items/WoodDark.tres")
var amount : int = 6
var material = preload("res://Assets/Log1.material")
var effectOffset = Vector3(0, -2.7, 0)

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
