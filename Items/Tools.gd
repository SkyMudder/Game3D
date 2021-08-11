extends Node


func playAnimation() -> void:
	$Hitbox.get_child(0).set_disabled(false)
	$AnimationPlayer.play("Slash")
	
func deactivateCollision() -> void:
	$Hitbox.get_child(0).set_disabled(true)
