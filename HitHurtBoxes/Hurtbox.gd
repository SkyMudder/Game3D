extends Area


var pickable: bool = true

func interact() -> void:
	get_parent().handleUI()
