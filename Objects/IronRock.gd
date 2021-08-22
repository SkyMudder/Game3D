extends "res://Objects/FarmableObjects.gd"


var timer: Timer
var hp: int = 1000
var level: int = 1
var recentlyDamaged: bool = false
var damageType: int = Types.resourceType.MINERALS
var resource: Resource = preload("res://Items/IronRaw.tres")
var amount: int = 4
var material: SpatialMaterial = preload("res://Assets/Rock.material")
var effectOffset: Vector3 = Vector3(0, 1, 0)

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "_on_timer_timeout")
	
func _on_Hurtbox_area_entered(_area) -> void:
	takeDamage(self)
	if timer.time_left == 0:
		timer.start()
	
func _on_timer_timeout() -> void:
	recentlyDamaged = false
