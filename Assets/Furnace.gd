extends StaticBody


signal ready_to_remove

onready var collision = get_node("CollisionShape")
onready var ui = get_node("FurnaceView")
onready var fuelProgress = get_node("FurnaceView/FurnaceHBoxContainer/InventoryVBoxContainer/FuelHBoxContainer/Fuel")

var queue : = []
var productItems : Array

var previousCollisionShape : CylinderShape
var previousHurtboxShape : BoxShape

var currentlyBurning : = false
var currentlySmelting : = false
var queuedForRemoval : = false
var fuel : int = 0

const burnDuration : = 1
const smeltDuration : = 4

"""Deactivate _process, meaning Burning or Smelting
Connect the Signal for updating the Queue
Make the Furnace ready for Blueprinting
Meaning Collisions and UI are deactivated"""
func _ready():
	set_process(false)
	ui.hide()
	ui.connect("queue_updated", self, "_on_queue_updated")
	productItems = ui.productInventory.items
	previousCollisionShape = collision.shape
	previousHurtboxShape = $Hurtbox/CollisionShape.shape
	#furnace.texture = furnaceNotPlaceable
	
"""Runs while there are Items in the Queue"""
func _process(_delta):
	if queue.size() > 0 and !queuedForRemoval:
		if readyToBurn():
			burn()
		if readyToSmelt():
			if productItems[0] != null:
				if ableToContinue():
					smelt()
			elif ableToContinue():
				smelt()
	else:
		setState(0)
		set_process(false)
	
"""Set the Material using a Blueprint State"""
func setBlueprintState(state) -> void:
	if state == 0:
		for x in get_children():
			if x is MeshInstance:
				x.material_override = null
	elif state == 1:
		for x in get_children():
			if x is MeshInstance:
				x.material_override = load("res://Assets/BluePrint.tres")
	
"""Set the Materials using a Furnace State"""
func setState(state) -> void:
	if state == 0:
		pass
	elif state == 1:
		pass
	else:
		pass
	
"""Toggle Collision"""
func setCollision(state) -> void:
	if state == 0:
		collision.shape = null
		$Hurtbox/CollisionShape.shape = null
	if state == 1:
		collision.shape = previousCollisionShape
		$Hurtbox/CollisionShape.shape = previousHurtboxShape
	
"""Burn a Stack until the Fuel has reached its max Value
Or until the Stack has no Items"""
func burn() -> void:
	var sourceItems = ui.sourceInventory.items
	var index = findBurnable()	# First Slot with a burnable Item
	if index != null:	# Only burn if an Item was found
		currentlyBurning = true
		# Only burn if there is enough Space for Fuel
		# And if there are enough burnable Resources
		if fuel < 100 and sourceItems[index].amount > 0:
			# Wait a specific Amount of Time to simulate the Furnace burning
			yield(get_tree().create_timer(burnDuration), "timeout")
			# Only smelt if the Item is burnable
			# The Check has to be done again in case the Item was removed while
			# the Furnace was burning the Item
			if checkBurnable(sourceItems[index]):
				# Remove the burnt Item and add it as Fuel
				sourceItems[index].amount -= 1
				fuel += 20
				# Update the Fuel on the UI
				fuelProgress.value = fuel
				# Set the new Item Value on the UI unless the Amount is 0
				# Then the Item gets removed from the Inventory
				if sourceItems[index].amount > 0:
					ui.sourceInventory.set(sourceItems[index], index)
				else:
					ui.sourceInventory.remove(index)
		currentlyBurning = false
		if queuedForRemoval:
			emit_signal("ready_to_remove")
	
"""Burn a Stack until there is no Fuel anymore,
Until the Stack has no Items
Or until the Product Inventory is full
Also does multiple Checks to guarantee that an Item like Wood
Does not have its value incremented when put in the Product Inventory
"""
func smelt() -> void:
	var sourceItems = ui.sourceInventory.items
	var targetItems = ui.productInventory.items
	var index = findSmeltable()
	# Check if there is enough Fuel and a smeltable Item was found
	if index != null:
		# Get the Source Item and determine what the Product is
		var item = getProductFromSource(sourceItems[index]).duplicate()
		currentlySmelting = true
		# Wait a specific Amount of Time to simulate the Furnace smelting
		yield(get_tree().create_timer(smeltDuration), "timeout")
		# If an Item is currently being moved, wait until it's dropped again
		# To avoid Bugs regarding the Amount of the Product
		if Inventories.moving:
			yield(Inventories, "resume")
		# Check if the Item is smeltable
		# and make sure that the Item in the Product Inventory is
		# the Smelting Product of the Source Item
		# To avoid that any Resource being placed there
		# can have its Amount incremented
		if checkSmeltable(sourceItems[index]):
			if targetItems[0] != null:
				if targetItems[0].name == getProductFromSource(sourceItems[index]).name:
					smeltUpdateValues(sourceItems[index], index, targetItems[0], item)
			else:
				smeltUpdateValues(sourceItems[index], index, targetItems[0], item)
		currentlySmelting = false
		if queuedForRemoval:
			emit_signal("ready_to_remove")
	
func smeltUpdateValues(sourceItem, index, targetItem, item) -> void:
	# Remove the smelted Item and the Fuel
	sourceItem.amount -= 1
	fuel -= 20
	# Update the Fuel on the UI
	fuelProgress.value = fuel
	# If there is no Item in the Product Inventory, add one
	# Else, increment its Value
	# Set the Items
	if targetItem == null:
		ui.productInventory.set(item.duplicate(), 0)
	else:
		item = targetItem
		item.amount += 1
		ui.productInventory.set(item, 0)
	# Set the Source Item, as its Value was decremented earlier
	ui.sourceInventory.set(sourceItem, index)
	
"""Return the first burnable Item Index found in the Queue
If no Item is found, null is returned"""
func findBurnable():
	for x in queue:
		if checkBurnable(ui.sourceInventory.items[x]):
			return x
	
"""Return the first smeltable Item Index found in the Queue
If no Item is found, null is returned"""
func findSmeltable():
	for x in queue:
		if checkSmeltable(ui.sourceInventory.items[x]):
			return x
	
"""Checks if a specific Item is Burnable
Returns a Boolean"""
func checkBurnable(item) -> bool:
	if item != null:
		if item.burnable:
			return true
	return false
	
"""Checks if a specific Item is Smeltable
Returns a Boolean"""
func checkSmeltable(item) -> bool:
	if item != null:
		if item.smeltable:
			return true
	return false
	
"""Check if Items are already being burned"""
func readyToBurn() -> bool:
	if !currentlyBurning:
		return true
	return false
	
"""Check if Items are already being smelted"""
func readyToSmelt() -> bool:
	if !currentlySmelting:
		return true
	return false
	
func getProductFromSource(item) -> Item:
	return item.smeltingProduct
	
"""Gets the Items that are in the Furnace Inventories
And returns them to the Player Inventory"""
func getFurnaceItems(inventory) -> void:
	for x in range(inventory.size):
		if inventory.items[x] != null:
			Inventories.playerInventory.add(inventory.items[x])
	
"""Checks if the Furnace can continue to process anything
If not, sets process to false"""
func ableToContinue() -> bool:
	var checks = [false, false]
	if (findSmeltable() != null or (findBurnable() != null and fuel != 100)) and (findBurnable() != null or fuel > 0):
		checks[0] = true
	if productItems[0] != null:
		if productItems[0].amount < productItems[0].stackLimit:
			checks[1] = true
	else:
		checks[1] = true
	if checks[0] and checks[1]:
		setState(1)
		return true
	else:
		setState(0)
		set_process(false)
		return false
	
"""This gets called when Items enter or leave the Furnace
They are added or removed from the Queue accordingly
Starts the Process when something entered the Queue"""
func _on_queue_updated(itemIndex, flag):
	if flag == 0:
		if !itemIndex in queue:
			queue.push_back(itemIndex)
			set_process(true)
	else:
		queue.erase(itemIndex)
	
"""For closing the Furnace Inventory when opening the Main Inventory
Or right Clicking anywhere"""
func _input(_event):
	if Input.is_action_just_pressed("ui_focus_next") or Input.is_action_just_pressed("mouse_right") or Input.is_action_just_pressed("ui_cancel"):
		ui.hide()
		States.inventoryOpen = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
"""Handles the Furnace Input"""
func handleUI():
	# Toggle the Furnace UI Visibility
	if Input.is_action_just_pressed("interact"):
		if ui.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			ui.hide()
			States.inventoryOpen = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			ui.show()
			States.inventoryOpen = true
	# Deactivate the Furnace's Collision, remove the Texture and hide the UI
	# Add the Furnace and the Items inside it to the Player Inventory
	# The Furnace Node will be removed once all its Operations are finished
	if Input.is_action_just_pressed("interact"):
		if Input.is_action_pressed("ctrl"):
			# warning-ignore:return_value_discarded
			connect("ready_to_remove", self, "_on_ready_to_remove")
			queuedForRemoval = true
			Inventories.playerInventory.add(preload("res://Items/Furnace.tres"))
			getFurnaceItems(ui.sourceInventory)
			getFurnaceItems(ui.productInventory)
			setCollision(0)
			setState(-1)
			ui.hide()
			States.inventoryOpen = false
	
# Destroy the Furnace
func _on_ready_to_remove():
	if !currentlyBurning and !currentlySmelting:
		Inventories.removeFurnaceInventory(ui.sourceInventory.id)
		queue_free()
