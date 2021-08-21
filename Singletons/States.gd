extends Node

var mainInventoryOpen: bool = false
var secondaryInventoryOpen: bool = false
var zooming: bool = false

func inventoriesOpen() -> bool:
	return mainInventoryOpen or secondaryInventoryOpen
