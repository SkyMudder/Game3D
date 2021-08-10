extends Node

func takeDamage(object):
	if !object.recentlyDamaged:
		object.recentlyDamaged = true
		object.hp -= 100
		yield(get_tree().create_timer(0.4), "timeout")
		object.recentlyDamaged = false
	if object.hp <= 0:
		object.queue_free()
