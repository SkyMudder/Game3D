extends "res://Items/Tools.gd"


func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	playAnimation("Idle")
