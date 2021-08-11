extends ProgressBar


var timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "_on_timer_timeout")
	
func showAndReset():
	visible = true
	timer.start(2)
	
func _on_timer_timeout():
	self.visible = false
