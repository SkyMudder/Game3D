extends CenterContainer


signal slot_updated(index)

onready var playerInventories: Array = Inventories.playerInventories
var inventory: Inventory
onready var player: KinematicBody = get_node("/root/World/Player")

onready var textureRect: TextureRect = get_node("Item")
onready var itemAmount: Label = get_node("Item/ItemAmount")
onready var emptySlotTexture: Resource = preload("res://UIElements/EmptyInventorySlot.png")
onready var selected: Sprite = get_node("Selected")
onready var furnaceView = get_parent().get_parent().get_parent()

"""Shows a given Item on the UI
If the Amount is lower than 0 it gets setItem to null
If the Stack only has one Item, the Amount is not shown on the UI"""
func displayItem(inventoryDisplay: Inventory, item: Item) -> void:
	if item is Item and item.amount > 0:
		textureRect.texture = item.texture
		itemAmount.text = str(item.amount)
		if item.amount == 1:
			itemAmount.text = ""
	else:
		textureRect.texture = emptySlotTexture
		itemAmount.text = ""
		# Sets the Object to null because nothing is there anymore
		inventoryDisplay.items[inventoryDisplay.items.find(item)] = null
	if selected.visible:
		emit_signal("slot_updated", get_index())
	
func get_drag_data(_position) -> Dictionary:
	var itemIndex: int = get_index()
	var item: Item = inventory.items[itemIndex]
	var dragPreview: TextureRect
	var data: Dictionary = {}
	if item != null:
		# Notify specific Objects that an Item has been picked up
		# so they stop working
		if Inventories.getFurnaceInventoryByID(inventory.id) != null:
			Inventories.notifyMoving(true)
		dragPreview = TextureRect.new()
		dragPreview.texture = item.texture
		
		data.id = inventory.id
		data.name = item.name
		data.previousAmount = item.amount
		# Set unhandled data in case the Item doesn't get dropped anywhere
		Inventories.setUnhandledData(inventory, item, item.amount, itemIndex)
		# For half-splitting Item Stacks
		if Input.is_action_pressed("ctrl"):
			if item is Item:
				item.amount /= 2
				data.item = item.duplicate()
				inventory.emit_signal("items_changed", inventory.id, itemIndex)
				data.itemIndex = itemIndex
				data.split = true
				set_drag_preview(dragPreview)
				print(inventory)
				return data
		# For moving Items
		else:
			item = inventory.remove(itemIndex)
			if item is Item:
				data.item = item
				data.itemIndex = itemIndex
				set_drag_preview(dragPreview)
				return data
	return data
	
func can_drop_data(_position, data: Dictionary) -> bool:
	return data is Dictionary and data.has("item")
	
func drop_data(_position, data: Dictionary) -> void:
	var itemIndex: int = get_index()
	var item: Item = inventory.items[itemIndex]
	var tmpInventory: Inventory = Inventories.getFurnaceInventoryByID(data.id)
	# Check if the Source is an Item and if it is of the same Type
	if item is Item and item.name == data.item.name:
		# Check if the Source Slot is the same as the Target Slot
		# The Item will not be moved and will restore it's previous Value
		if itemIndex == data.itemIndex and inventory.id == tmpInventory.id:
			item.amount = data.previousAmount
			# warning-ignore:return_value_discarded
			inventory.setItem(item, itemIndex)
			# Notify specific Objects that an Item has been dropped
			# so they can continue working
			if tmpInventory != null:
				Inventories.notifyMoving(false)
			# Set unhandled data to null
			# Meaning the Item has been dropped in a valid Place
			Inventories.setUnhandledData(null, null, null, null)
			return
		# Check if the items are of the same Type
		# And if the Source Stack has been split
		if item.name == data.item.name and !data.has("split"):
			var space: int = item.stackLimit - item.amount
			# Check if the split Stack has enough Space to be merged
			# With the new Stack
			if item.amount + data.item.amount < item.stackLimit:
				item.amount += data.item.amount
				data.item.amount = 0
			# If not, add what has Space and readd the Rest to the Source Stack
			else:
				item.amount += space
				data.item.amount -= space
		# Check if the Source Item Stack was Split and had an uneven number
		elif data.has("split") and data.item.name == item.name:
			var space: int = item.stackLimit - item.amount
			# Check if the split Stack has enough Space to be merged
			# With the new Stack
			if item.amount + data.item.amount < item.stackLimit:
				item.amount += data.item.amount
				# Add one if the Number of the full Stack was uneven
				# Due to the Integer Decimal part being discarded
				if data.previousAmount % 2 != 0:
					item.amount += 1
			# If not, add what has Space and readd the Rest to the Source Stack
			else:
				item.amount += space
				data.item.amount = data.previousAmount - space
		# warning-ignore:return_value_discarded
		inventory.setItem(item, itemIndex)
		# warning-ignore:return_value_discarded
		Inventories.getInventoryByID(data.id).setItem(data.item, data.itemIndex)
	# Check if the Source Stack was Split
	elif data.has("split"):
		# Check if the Item is not null
		# So it doesn't get merged and it's old Value gets restored
		# To avoid merging different Types of Objects with each other
		if item != null:
			data.item.amount = data.previousAmount
			# warning-ignore:return_value_discarded
			Inventories.getInventoryByID(data.id).setItem(data.item, data.itemIndex)
		# Check if the Target Slot is empty, add the split Stack to it
		else:
			# Add one if the Number of the full Stack was uneven
			# Due to the Integer Decimal part being discarded
			# Duplicate the Item in Order for it not to share the same value
			# With the Source Stack
			if data.previousAmount % 2 != 0:
				# warning-ignore:return_value_discarded
				Inventories.getInventoryByID(data.id).setItem(data.item.duplicate(), data.itemIndex)
				data.item.amount += 1
			# warning-ignore:return_value_discarded
			inventory.setItem(data.item, itemIndex)
	# For simply swapping Items
	else:
		inventory.swap(data.id, inventory.id, data.itemIndex, itemIndex)
		# warning-ignore:return_value_discarded
		Inventories.getInventoryByID(data.id).setItem(item, data.itemIndex)
		# warning-ignore:return_value_discarded
		inventory.setItem(data.item.duplicate(), itemIndex)
	# Notify specific Objects that an Item has been dropped
	# so they can continue working
	if tmpInventory != null:
		Inventories.notifyMoving(false)
	# Set unhandled data to null
	# Meaning the Item has been dropped in a valid Place
	Inventories.setUnhandledData(null, null, null, null)
	
"""Handle Item Selection"""
func select() -> void:
	# Mark the Slot as selected
	selected.show()
	# If the Slot contains an Item, setItem it on the Player
	if inventory.items[get_index()] != null:
		player.playerItem = inventory.items[get_index()]
	else:
		player.playerItem = null
	get_parent().emit_signal("item_switched")
	
"""Deselect a Slot"""
func deselect() -> void:
	selected.hide()
	
"""Get notified when the Player stopped placing the Item"""
func _on_stopped_placing(placed):
	# Remove it from the Inventory if it was actually placed
	if placed:
		playerInventories[1].remove(get_index())
