extends "res://Items/Tools.gd"


func _on_AnimationPlayer_animation_finished(_anim_name):
	playAnimation("Idle")
