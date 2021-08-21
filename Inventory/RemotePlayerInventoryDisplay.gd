extends "res://Inventory/InventoryDisplayMaster.gd"


onready var InventorySlotDisplay: PackedScene = preload("res://Inventory/InventorySlotDisplay.tscn")
onready var inventory: Inventory = Inventories.playerInventory
var currentlySelected: int = 1

"""Adds the given Amount of Inventory Slots to the UI
Connects Signal for when Items changed
Updates the Inventory on the UI"""
func _ready() -> void:
	inventory.playerInventories = Inventories.playerInventories
	loadInventorySlots(self, inventory.size)
	columns = inventory.columns
	for x in get_children():
		x.inventory = inventory
	updateInventoryDisplay(self, inventory, inventory.id)
	if inventory == playerInventories[1]:
		get_child(currentlySelected).select()
	# warning-ignore:return_value_discarded
	inventory.connect("items_changed", self, "_on_items_changed")
	
func getSlot(index: int, _inventoryChanged) -> Node:
	return get_child(index)
	
"""When Item changes, update the Inventory Slot Display"""
func _on_items_changed(inventoryChanged: int, index: int) -> void:
	if inventoryChanged == inventory.id:
		updateInventorySlotDisplay(self, inventory, inventoryChanged, index)
	
