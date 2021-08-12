extends TabContainer

func _on_TabContainer_tab_changed(tab):
	if tab == 0:
		rect_size = Vector2(610, 440)
	elif tab == 1:
		rect_size = Vector2(940, 440)
