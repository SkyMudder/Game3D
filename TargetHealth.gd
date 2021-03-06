extends ProgressBar


var timer : Timer

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "_on_timer_timeout")
	
func showAndReset() -> void:
	visible = true
	timer.start(2)
	
func _on_timer_timeout() -> void:
	visible = false
