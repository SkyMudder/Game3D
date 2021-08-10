extends Resource
class_name Inventory


signal items_changed(inventoryChanged, index)

var items : Array = []
	
var playerInventories : Array
var remoteInventories : Array
	
var id : int
var size : int
var columns : int
	
var scheduledRemovalInventories : Array = []
var scheduledRemovalIndexes : Array = []
var scheduledRemovalAmounts : Array = []
	
func _init(inventoryId, inventorySize, inventoryColumns):
	id = inventoryId
	size = inventorySize
	columns = inventoryColumns
	
"""Automatically determines where to add an Item to the Inventory/Toolbar
Splits Stacks automatically"""
func add(item) -> void:
	var x = playerInventories.size() - 1
	while x >= 0 and item.amount > 0:
		var y = 0
		while y <= playerInventories[x].items.size() - 1 and item.amount > 0:
			if playerInventories[x].items[y] != null:
				if playerInventories[x].items[y].name == item.name and playerInventories[x].items[y].amount + item.amount < item.stackLimit:
					playerInventories[x].items[y].amount += item.amount
					playerInventories[x].emit_signal("items_changed", playerInventories[x].id, y)
					return
				elif playerInventories[x].items[y].name == item.name:
					splitAdd(item, x, y)
			y += 1
		x -= 1
	x = playerInventories.size() - 1
	while x >= 0:
		var y = 0
		while y <= playerInventories[x].items.size() - 1 and item.amount > 0:
			if playerInventories[x].items[y] == null:
				if item.amount <= item.stackLimit:
					addNewItem(item, x, y)
					playerInventories[x].items[y].amount += item.amount
					emit_signal("items_changed", id, y)
					return
				else:
					addNewItem(item, x, y)
					splitAdd(item, x, y)
			y += 1
		x -= 1
	
"""Seeks a specific Amount of an Item in the Inventory/Toolbar
If there is not enough in one Stack it searches in another Stack
Schedules the previous Stack for Removal by adding it to an Array
with the respective Amount that might be removed in another Array
Also saves the Inventory from which it was removed in an Array
Items do not directly get removed in this Method
Returns True if enough Items have been found, False if not"""
func seek(item, amount) -> bool:
	var amountTaken = 0
	var need = amount - amountTaken
	var x = playerInventories.size() - 1
	while x >= 0:
		var y = playerInventories[x].items.size() - 1
		while y >= 0:
			if playerInventories[x].items[y] != null and need:
				if playerInventories[x].items[y].name == item.name:
					if playerInventories[x].items[y].amount >= need:
						scheduledRemovalInventories.push_back(playerInventories.find(playerInventories[x]))
						scheduledRemovalIndexes.push_back(y)
						scheduledRemovalAmounts.push_back(need)
						amountTaken += need
						return true
					else:
						var available = playerInventories[x].items[y].amount
						scheduledRemovalInventories.push_back(playerInventories.find(playerInventories[x]))
						scheduledRemovalIndexes.push_back(y)
						scheduledRemovalAmounts.push_back(available)
						amountTaken += available
			if amountTaken == amount:
				return true
			y -= 1
		x -= 1
	return false

func set(item, itemIndex):
	var previousItem = items[itemIndex]
	items[itemIndex] = item
	emit_signal("items_changed", id, itemIndex)
	return previousItem
	
func swap(sourceInventory, targetInventory, itemIndex, targetItemIndex) -> void:
	var tmp = Inventories.getInventoryByID(targetInventory).items[targetItemIndex]
	Inventories.getInventoryByID(targetInventory).items[targetItemIndex] = Inventories.getInventoryByID(sourceInventory).items[itemIndex]
	Inventories.getInventoryByID(sourceInventory).items[itemIndex] = tmp
	
func remove(itemIndex):
	var previousItem = items[itemIndex]
	items[itemIndex] = null
	emit_signal("items_changed", id, itemIndex)
	return previousItem
	
"""Removes scheduled Items from the Inventory
Clears the Arrays after the Action is complete"""
func removeScheduled() -> void:
	for x in range(scheduledRemovalIndexes.size()):
		playerInventories[scheduledRemovalInventories[x]].items[scheduledRemovalIndexes[x]].amount -= scheduledRemovalAmounts[x]
	for x in range(scheduledRemovalInventories.size()):
		playerInventories[scheduledRemovalInventories[x]].emit_signal("items_changed", scheduledRemovalInventories[x], scheduledRemovalIndexes[x])
	scheduledRemovalInventories.clear()
	scheduledRemovalIndexes.clear()
	scheduledRemovalAmounts.clear()
	
func setInventorySize(inventorySize) -> void:
	for _x in range(inventorySize):
		items.push_back(null)
	
"""If the Stack that gets added is too big,
It splits up the Rest on the next Stack"""
func splitAdd(item, inventoryIndex, itemsIndex) -> void:
	var space = item.stackLimit - playerInventories[inventoryIndex].items[itemsIndex].amount
	playerInventories[inventoryIndex].items[itemsIndex].amount += space
	item.amount -= space
	playerInventories[inventoryIndex].emit_signal("items_changed", playerInventories[inventoryIndex].id, itemsIndex)
	
"""Creates a new Item, meaning it duplicates the given one"""
func addNewItem(item, inventoryIndex, itemsIndex) -> void:
	playerInventories[inventoryIndex].set(item.duplicate(), itemsIndex)
	playerInventories[inventoryIndex].items[itemsIndex].amount = 0
