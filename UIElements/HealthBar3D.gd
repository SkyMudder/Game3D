extends Sprite3D


onready var bar: TextureProgress = $Viewport/TextureProgress

func _ready() -> void:
	texture = $Viewport.get_texture()
	
func update(hp: int) -> void:
	bar.value = hp
