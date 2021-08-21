extends HBoxContainer


onready var inventory: Inventory = Inventories.playerInventory

onready var craftingSection: VBoxContainer = get_node("CraftingSection")
onready var itemTexture: TextureRect = get_node("CraftingSection/ItemTexture")

onready var recipes: VBoxContainer = get_node("ScrollContainer/Recipes")
onready var RecipeContainer: PackedScene = preload("res://Recipes/RecipeContainer.tscn")

var currentlySelected: int
var previouslySelected: int

"""Hides the crafting Section to prevent unselected Items from being crafted
Adds all the Recipes to the Recipe Section
Connects the Signal for detecting when one got selected"""
func _ready() -> void:
	rect_clip_content = true
	craftingSection.hide()
	for x in range(Recipes.allRecipes.size()):
		var newRecipeContainer: HBoxContainer = RecipeContainer.instance()
		newRecipeContainer.item = Recipes.allRecipes[x]
	# warning-ignore:return_value_discarded
		newRecipeContainer.connect("recipe_selected", self, "_on_recipe_selected")
		recipes.add_child(newRecipeContainer)
	
func updateItemTexture() -> void:
	print(get_child(currentlySelected))
	itemTexture.texture = recipes.get_child(currentlySelected).item.product.texture
	
"""Checks if the requested Item is available to craft
This is done by checking if the needed Items are available in the Inventory"""
func checkCraft() -> bool:
	var currentItem: Recipe = recipes.get_child(currentlySelected).item
	for x in range(currentItem.ingredients.size()):
		if inventory.seek(currentItem.ingredients[x], currentItem.ingredientAmounts[x]) == false:
			inventory.scheduledRemovalInventories.clear()
			inventory.scheduledRemovalIndexes.clear()
			inventory.scheduledRemovalAmounts.clear()
			return false
	inventory.removeScheduled()
	return true
	
func _on_CraftButton_pressed() -> void:
	if checkCraft():
		inventory.add(recipes.get_child(currentlySelected).item.product)
	
"""When a Recipe gets selected, the previously selected one gets deselected
The Item Texture gets updated"""
func _on_recipe_selected(index: int) -> void:
		craftingSection.show()
		currentlySelected = index
		if previouslySelected != null and previouslySelected != currentlySelected:
			recipes.get_child(previouslySelected).deselect()
		updateItemTexture()
		previouslySelected = currentlySelected
