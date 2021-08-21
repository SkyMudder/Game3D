extends Node


func playAnimation(name : String) -> void:
	$AnimationPlayer.play(name)
	
func activateCollision() -> void:
	$Hitbox.get_child(0).set_disabled(false)
	
func deactivateCollision() -> void:
	$Hitbox.get_child(0).set_disabled(true)
