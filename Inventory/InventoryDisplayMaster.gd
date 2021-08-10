extends GridContainer


onready var playerInventories : Array = Inventories.playerInventories
onready var furnaceInventories : Array = Inventories.furnaceInventories

"""Goes through the whole Inventory and updates the Slots"""
func updateInventoryDisplay(object, inventory, inventoryChanged) -> void:
	for itemIndex in inventory.size:
		object.updateInventorySlotDisplay(object, inventory, inventoryChanged, itemIndex)
	
"""Updates an Inventory Slot at a given Index"""
func updateInventorySlotDisplay(object, inventory, inventoryChanged, itemIndex) -> void:
	var inventorySlotDisplay = object.getSlot(itemIndex, inventoryChanged)
	var item = inventory.items[itemIndex]
	inventorySlotDisplay.displayItem(inventory, item)
	
"""Create Inventory with a given Amount of Slots"""
func addInventorySlots(object, amount) -> void:
	for _x in range(amount):
		var slot = object.InventorySlotDisplay.instance()
		object.add_child(slot)
	object.inventory.setInventorySize(object.inventory.size)
	
"""Load Inventory with a given Amount of Slots"""
func loadInventorySlots(object, amount) -> void:
	for _x in range(amount):
		var slot = object.InventorySlotDisplay.instance()
		object.add_child(slot)
	for x in range(amount):
		if object.inventory.items[x] != null:
			object.get_child(x).textureRect.texture = object.inventory.items[x].texture
			object.get_child(x).itemAmount.text = str(object.inventory.items[x].amount)
	
"""Handle Items not being dropped anywhere
Return them to their original Slot"""
func _unhandled_input(event):
	var data = Inventories.unhandledData
	if event.is_action_released("mouse_left"):
		if data.has("inventory"):
			if data.inventory != null:
				var item = data.item
				item.amount = data.amount
				data.inventory.set(item, data.index)
				Inventories.notifyMoving(false)
