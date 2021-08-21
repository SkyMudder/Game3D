extends "res://Assets/FarmableObjects.gd"


var timer: Timer
var hp: int = 1000
var level: int = 0
var recentlyDamaged: bool = false
var damageType: int = Types.resourceType.WOOD
var resource: Resource = preload("res://Items/Wood.tres")
var amount: int = 6
var material: SpatialMaterial = preload("res://Assets/Log2.material")
var effectOffset: Vector3 = Vector3(-0.5, 0.5, 0.7)

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
