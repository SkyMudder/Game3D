extends Node


func playAnimation():
	$Hitbox.get_child(0).set_disabled(false)
	$AnimationPlayer.play("Slash")
	yield(get_tree().create_timer(0.3), "timeout")
	$Hitbox.get_child(0).set_disabled(true)
