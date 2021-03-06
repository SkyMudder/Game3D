extends HBoxContainer


signal recipe_selected(index)

onready var selected: Sprite = $Selected
onready var itemTexture: TextureRect = $ItemTexture

onready var ingredientTextures: VBoxContainer = get_node("IngredientsAmount/Ingredients")
onready var ingredientNames: VBoxContainer = get_node("IngredientsAmount/IngredientNames")
onready var ingredientAmounts: VBoxContainer = get_node("IngredientsAmount/Amounts")

onready var description: Label = get_node("IngredientsAmount/Description/Description")

var item: Resource

"""Sets all the Recipe Information on the UI"""
func _ready() -> void:
	if item != null:
		setTextures()
		setNames()
		setAmounts()
		setDescription()
	
func setTextures() -> void:
	if item.product != null:
		itemTexture.texture = item.product.texture
	for x in range(item.ingredients.size()):
		if item.ingredients[x] != null:
			ingredientTextures.get_child(x).texture = item.ingredients[x].texture
	
func setNames() -> void:
	for x in range(item.ingredients.size()):
		if item.ingredients[x] != null:
			ingredientNames.get_child(x).text = item.ingredients[x].name
	
func setAmounts() -> void:
	for x in range(item.ingredientAmounts.size()):
		if item.ingredients[x] != null:
			ingredientAmounts.get_child(x).text = str(item.ingredientAmounts[x])
	
func setDescription() -> void:
	description.text = item.description
	
func select() -> void:
	selected.show()
	
func deselect() -> void:
	selected.hide()
	
func _on_RecipeContainer_gui_input(_event) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		select()
		emit_signal("recipe_selected", get_index())
