extends "res://Inventory/InventoryDisplayMaster.gd"


signal item_switched(flag)	# Flag: 0 if the Player Item should be updated
							# Flag: 1 if the Building Object should be updated

onready var InventorySlotDisplay = preload("res://Inventory/InventorySlotDisplay.tscn")
onready var inventory : Inventory = Inventories.toolbar

var currentlySelected : int = 9

"""Adds the given Amount of Inventory Slots to the UI
Connects Signal for when Items changed
Updates the Inventory on the UI"""
func _ready():
	inventory.playerInventories = Inventories.playerInventories
	addInventorySlots(self, inventory.size)
	columns = inventory.columns
	for x in get_children():
		x.inventory = inventory
	updateInventoryDisplay(self, inventory, inventory.id)
	if inventory == playerInventories[1]:
		get_child(currentlySelected).select()
	# warning-ignore:return_value_discarded
	inventory.connect("items_changed", self, "_on_items_changed")
	for x in get_children():
		x.connect("slot_updated", self, "_on_slot_updated")
	for _x in range(30):
		inventory.add(preload("res://Items/Wood.tres"))
	inventory.add(preload("res://Items/Pickaxe.tres"))
	inventory.add(preload("res://Items/Axe.tres"))
	
"""When Item changes, update the Inventory Slot Display"""
func _on_items_changed(inventoryChanged, index) -> void:
	if inventoryChanged == inventory.id:
		updateInventorySlotDisplay(self, inventory, inventoryChanged, index)
	
"""Update Slots when a new Slot is selected"""
func _input(event) -> void:
	if event.is_action_pressed("scroll_up") and canSwitchSlot():
		get_child(currentlySelected).deselect()
		if !(currentlySelected - 1 < 0):
			currentlySelected -= 1
		else:
			currentlySelected = inventory.size - 1
		if get_child(currentlySelected).inventory == playerInventories[1]:
			get_child(currentlySelected).select()
	if event.is_action_pressed("scroll_down") and canSwitchSlot():
		get_child(currentlySelected).deselect()
		if !(currentlySelected + 1 > inventory.size - 1):
			currentlySelected += 1
		else:
			currentlySelected = 0
		if get_child(currentlySelected).inventory == playerInventories[1]:
			get_child(currentlySelected).select()
	selectSlotByNumber(event)
	
"""Selects the Slot by the number pressed"""
func selectSlotByNumber(event) -> void:
	if event.is_action_pressed("1") and !Inventories.open:
		get_child(currentlySelected).deselect()
		get_child(0).select()
		currentlySelected = 0
	elif event.is_action_pressed("2") and !Inventories.open:
		get_child(currentlySelected).deselect()
		get_child(1).select()
		currentlySelected = 1
	elif event.is_action_pressed("3") and !Inventories.open:
		get_child(currentlySelected).deselect()
		get_child(2).select()
		currentlySelected = 2
	elif event.is_action_pressed("4") and !Inventories.open:
		get_child(currentlySelected).deselect()
		get_child(3).select()
		currentlySelected = 3
	elif event.is_action_pressed("5") and !Inventories.open:
		get_child(currentlySelected).deselect()
		get_child(4).select()
		currentlySelected = 4
	elif event.is_action_pressed("6") and !Inventories.open:
		get_child(currentlySelected).deselect()
		get_child(5).select()
		currentlySelected = 5
	elif event.is_action_pressed("7") and !Inventories.open:
		get_child(currentlySelected).deselect()
		get_child(6).select()
		currentlySelected = 6
	elif event.is_action_pressed("8") and !Inventories.open:
		get_child(currentlySelected).deselect()
		get_child(7).select()
		currentlySelected = 7
	elif event.is_action_pressed("9") and !Inventories.open:
		get_child(currentlySelected).deselect()
		get_child(8).select()
		currentlySelected = 8
	elif event.is_action_pressed("0") and !Inventories.open:
		get_child(currentlySelected).deselect()
		get_child(9).select()
		currentlySelected = 9
	
func getSlot(index, _inventoryChanged):
	return get_child(index)
	
"""Checks if the Slot can be switched"""
func canSwitchSlot() -> bool:
	if !States.inventoryOpen and !States.zooming:
		return true
	return false
	
"""For updating the Player Item
When an Item is placed in an already selected Slot"""
func _on_slot_updated(index):
	get_child(index).select()
	emit_signal("item_switched")
