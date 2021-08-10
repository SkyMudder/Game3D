extends Node


signal resume

const Inventory = preload("res://Inventory/Inventory.gd")

onready var currentInventory : int = 0
var currentFurnace : int = 0
var itemID : int = -1

var moving : = false
var open : = false
var unhandledData : Dictionary = {}

var playerInventory : Inventory = Inventory.new(0, 24, 6)
var toolbar : Inventory = Inventory.new(1, 10, 10)

onready var playerInventories : Array = []
onready var furnaceInventories : Array = []

func _ready():
	playerInventories.push_back(playerInventory)
	currentInventory += 1
	playerInventories.push_back(toolbar)
	currentInventory += 1
	
func newFurnaceInventory() -> int:
	furnaceInventories.push_back(Inventory.new(currentInventory, 3, 1))
	currentInventory += 1
	furnaceInventories.push_back(Inventory.new(currentInventory, 1, 1))
	currentInventory += 1
	currentFurnace += 2
	return currentFurnace - 2
	
func removeFurnaceInventory(inventoryID) -> void:
	furnaceInventories.erase(getInventoryByID(inventoryID))
	furnaceInventories.erase(getInventoryByID(inventoryID + 1))
	currentInventory -= 2
	currentFurnace -= 2
	
func getInventoryByID(inventoryID) -> Inventory:
	var inventory = getPlayerInventoryByID(inventoryID)
	if inventory != null:
		return inventory
	inventory = getFurnaceInventoryByID(inventoryID)
	if inventory != null:
		return inventory
	return null
	
func getPlayerInventoryByID(inventoryID) -> Inventory:
	for x in playerInventories:
		if x.id == inventoryID:
			return x
	return null
	
func getFurnaceInventoryByID(inventoryID) -> Inventory:
	for x in furnaceInventories:
		if x.id == inventoryID:
			return x
	return null
	
func notifyMoving(state) -> void:
	if state:
		moving = true
	else:
		moving = false
		emit_signal("resume")
	
func setUnhandledData(inventory, item, amount, index) -> void:
	unhandledData.inventory = inventory
	unhandledData.item = item
	unhandledData.amount = amount
	unhandledData.index = index
	
func getItemID():
	itemID += 1
	return itemID
