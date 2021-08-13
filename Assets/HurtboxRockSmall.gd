extends Area

var pickable = true
var minable = false
var choppable = false

func interact():
	get_parent()._on_interact()
