extends Node


func playAnimation() -> void:
	$AnimationPlayer.play("Slash")
	
func activateCollision() -> void:
	$Hitbox.get_child(0).set_disabled(false)
	
func deactivateCollision() -> void:
	$Hitbox.get_child(0).set_disabled(true)
