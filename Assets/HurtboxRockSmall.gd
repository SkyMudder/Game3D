extends Area

var pickable: bool = true
var minable: bool = false
var choppable: bool = false

func interact() -> void:
	get_parent()._on_interact()
