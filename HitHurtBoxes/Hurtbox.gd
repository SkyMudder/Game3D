extends Area


var pickable = true

func interact():
	get_parent()._on_interact()
