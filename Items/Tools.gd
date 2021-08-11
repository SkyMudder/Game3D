extends Node


func playAnimation():
	$Hitbox.get_child(0).set_disabled(false)
	$AnimationPlayer.play("Slash")
	
func deactivateCollision():
	$Hitbox.get_child(0).set_disabled(true)
