extends GridContainer


onready var playerInventories: Array = Inventories.playerInventories
onready var furnaceInventories: Array = Inventories.furnaceInventories

"""Goes through the whole Inventory and updates the Slots"""
func updateInventoryDisplay(object: Object, inventory: Inventory, inventoryChanged: int) -> void:
	for itemIndex in inventory.size:
		object.updateInventorySlotDisplay(object, inventory, inventoryChanged, itemIndex)
	
"""Updates an Inventory Slot at a given Index"""
func updateInventorySlotDisplay(object: Object, inventory: Inventory, inventoryChanged: int, itemIndex: int) -> void:
	var inventorySlotDisplay: Node = object.getSlot(itemIndex, inventoryChanged)
	var item: Item = inventory.items[itemIndex]
	inventorySlotDisplay.displayItem(inventory, item)
	
"""Create Inventory with a given Amount of Slots"""
func addInventorySlots(object: Object, amount: int) -> void:
	for _x in range(amount):
		var slot: CenterContainer = object.InventorySlotDisplay.instance()
		object.add_child(slot)
	object.inventory.setInventorySize(object.inventory.size)
	
"""Load Inventory with a given Amount of Slots"""
func loadInventorySlots(object: Object, amount: int) -> void:
	for _x in range(amount):
		var slot: Node = object.InventorySlotDisplay.instance()
		object.add_child(slot)
	for x in range(amount):
		if object.inventory.items[x] != null:
			object.get_child(x).textureRect.texture = object.inventory.items[x].texture
			object.get_child(x).itemAmount.text = str(object.inventory.items[x].amount)
	
"""Handle Items not being dropped anywhere
Return them to their original Slot"""
func _unhandled_input(event) -> void:
	var data: Dictionary = Inventories.unhandledData
	if event.is_action_released("mouse_left"):
		if data.has("inventory"):
			if data.inventory != null:
				var item: Item = data.item
				item.amount = data.amount
				data.inventory.setItem(item, data.index)
				Inventories.notifyMoving(false)
