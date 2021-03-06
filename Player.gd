extends KinematicBody


signal stopped_placing

onready var toolbar: GridContainer = get_node("ToolbarCenterContainer/InventoryDisplay")
onready var rayCast: RayCast = get_node("Rotation_Helper/Camera/RayCast")
onready var rayCastBuild: RayCast = get_node("Rotation_Helper/Camera/RayCastBuild")

var areaClear: bool = false

var currentObject: Spatial
var playerItem: Item # The Item the Player has equipped
var currentItem: Spatial # The 3D Model of the Item
const GRAVITY: float = -24.8
var vel: Vector3 = Vector3()
var MAX_SPEED: float = 8.0
const JUMP_SPEED: float = 10.0
const ACCEL: float = 4.5

var dir: Vector3 = Vector3()

const DEACCEL: int = 16
const MAX_SLOPE_ANGLE: int = 40

var camera: Camera
var rotation_helper: Spatial

var MOUSE_SENSITIVITY: float = 0.05

func _ready() -> void:
	set_process(false)
	# warning-ignore:return_value_discarded
	toolbar.connect("item_switched", self, "switchItem")
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
"""Used for placing Objects and handling their Placement"""
func _process(delta) -> void:
	placeObject()
	if Input.is_action_pressed("Q"):
		currentObject.rotation_degrees.y += 200 * delta
	elif Input.is_action_pressed("E"):
		currentObject.rotation_degrees.y -= 200 * delta
	
func _physics_process(delta) -> void:
	process_input(delta)
	process_movement(delta)
	var object = rayCast.get_collider()
	if object != null:
		if object.pickable:
			$PickUp.show()
			if Input.is_action_just_pressed("interact"):
				object.interact()
	else:
		$PickUp.hide()

func process_input(_delta) -> void:
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------
	
	# ----------------------------------
	# Sprinting
	if Input.is_action_pressed("movement_sprint"):
		MAX_SPEED = 12.0
	else:
		MAX_SPEED = 8.0
	# ----------------------------------
	
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_focus_next"):
		if States.mainInventoryOpen:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			States.mainInventoryOpen = false
			$TabContainer.visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			States.mainInventoryOpen = true
			$TabContainer.visible = true
	# ----------------------------------
	
	# Attacking
	if Input.is_action_pressed("mouse_left") and !States.inventoriesOpen():
		if playerItem != null:
			if playerItem.damageType != -1:
				currentItem.playAnimation("Slash")
	# ----------------------------------
	
func process_movement(delta) -> void:
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot: Vector3 = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
	
"""Switch the Item in the Player's hand"""
func switchItem() -> void:
	if currentObject != null:
		currentObject.queue_free()
		currentObject = null
		rayCastBuild.enabled = false
		set_process(false)
	elif currentItem != null:
		currentItem.queue_free()
		currentItem = null
	if playerItem != null:
		if playerItem.buildable:
			var pos: Vector3 = Vector3.ZERO
			rayCastBuild.enabled = true
			rayCastBuild.force_raycast_update()
			if rayCastBuild.is_colliding():
				pos = rayCastBuild.get_collision_point()
			instancePlaceableObject(load(playerItem.model), pos)
		elif playerItem.model != "":
			var model: PackedScene = load(playerItem.model)
			currentItem = model.instance()
			$Rotation_Helper/Camera.add_child(currentItem)
	
func blueprint(object: Object) -> void:
	object.setBlueprintState(1)
	areaClear = true
	if rayCastBuild.is_colliding():
		positionObject(object, rayCastBuild.get_collision_point())
	else:
		positionObject(object, $Rotation_Helper/Camera.translation)
	
"""Places an Object at a specific Position"""
func positionObject(instance, position: Vector3) -> void:
	instance.translation = position + Vector3(0, -2, 0)
	
"""Instance a new Object, add it to the Scene Tree
Show its Blueprint Texture which should be in the Scene"""
func instancePlaceableObject(object: PackedScene, position: Vector3) -> void:
	set_process(true)
	var newObject = object.instance()
	get_node("/root/World").add_child(newObject)
	positionObject(newObject, position)
	newObject.setCollision(0)
	currentObject = newObject
	blueprint(currentObject)
	
"""Checks if the Player clicked LMB to place an object"""
func checkPlaceObject() -> bool:
	blueprint(currentObject)
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and !Input.is_action_pressed("ctrl") and rayCastBuild.is_colliding() and areaClear:
		return true
	return false
	
"""Places an Object"""
func placeObject() -> void:
	if checkPlaceObject():
		set_process(false)
		currentObject.setState(0)
		currentObject.setCollision(1)
		currentObject.setBlueprintState(0)
		currentObject = null
		toolbar.inventory.remove(toolbar.currentlySelected)
		emit_signal("stopped_placing")
		
"""Creates and returns a new RayCast with preferred Settings for Building Placement"""
func newRayCast() -> RayCast:
	var newRaycast = RayCast.new()
	newRaycast.enabled = true
	newRaycast.collide_with_areas = true
	newRaycast.collide_with_bodies = false
	newRaycast.collision_mask = 8
	newRaycast.cast_to = Vector3(1, 1, 1)
	get_node("/root/World").call_deferred("add_child", newRaycast)
	return newRaycast
