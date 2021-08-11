extends ProgressBar


var timer : Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	var error = timer.connect("timeout", self, "_on_timer_timeout")
	
func showAndReset() -> void:
	visible = true
	timer.start(2)
	
func _on_timer_timeout() -> void:
	visible = false
