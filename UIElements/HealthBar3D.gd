extends Sprite3D


onready var bar = $Viewport/TextureProgress

func _ready():
	texture = $Viewport.get_texture()
	
func update(hp):
	bar.value = hp
	print(bar.value)
