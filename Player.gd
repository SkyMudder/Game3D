extends KinematicBody


onready var toolbar = get_node("ToolbarCenterContainer/InventoryDisplay")
onready var rayCastPickable = get_node("Rotation_Helper/Camera/RayCastPickable")
onready var rayCastFarmable = get_node("Rotation_Helper/Camera/RayCastFarmable")
onready var RockSmall = preload("res://Assets/RockSmall.tscn")

var playerItem : Item # The Item the Player has equipped
var currentItem : Spatial # The 3D Model of the Item
var previousItem : Spatial # The 3D Model of the previous Item
const GRAVITY : float = -24.8
var vel : Vector3 = Vector3()
var MAX_SPEED : float = 8.0
const JUMP_SPEED : float = 10.0
const ACCEL : float = 4.5

var dir : Vector3 = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera : Camera
var rotation_helper : Spatial

var MOUSE_SENSITIVITY : float = 0.05

func _ready():
	toolbar.connect("item_switched", self, "switchItem")
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	var object = rayCastPickable.get_collider()
	if object != null:
		if object.pickable:
			if Input.is_action_just_pressed("interact"):
				object.interact()

func process_input(_delta):

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
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# ----------------------------------
		# Capturing/Freeing the cursor
		if $TabContainer.visible:
			$TabContainer.visible = false
		else:
			$TabContainer.visible = true
		# ----------------------------------
	# ----------------------------------
	
	# ----------------------------------
	# Attacking
	if Input.is_action_just_pressed("mouse_left") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if playerItem != null:
			if playerItem.damageType != -1:
				previousItem.playAnimation()
	# ----------------------------------
	
func process_movement(delta):
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

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
	
"""Switch the Item in the Player's hand"""
func switchItem() -> void:
	if previousItem != null:
		previousItem.queue_free()
	if playerItem != null:
		if playerItem.model != "":
			var model
			model = load(playerItem.model)
			currentItem = model.instance()
			$Rotation_Helper/Camera.add_child(currentItem)
			previousItem = currentItem
			currentItem = null
			return
	else:
		previousItem = null
	previousItem = currentItem
