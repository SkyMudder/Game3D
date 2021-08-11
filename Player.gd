extends KinematicBody


onready var toolbar = get_node("ToolbarCenterContainer/InventoryDisplay")

var playerItem
var currentItem
var previousItem
const GRAVITY = -24.8
var vel = Vector3()
var MAX_SPEED = 8
const JUMP_SPEED = 10
const ACCEL = 4.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

func _ready():
	toolbar.connect("item_switched", self, "switchItem")
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

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
		MAX_SPEED = 12
	else:
		MAX_SPEED = 8
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
		if $InventoryCenterContainer.visible:
			$InventoryCenterContainer.visible = false
		else:
			$InventoryCenterContainer.visible = true
		# ----------------------------------
	# ----------------------------------
	
	# ----------------------------------
	# Attacking
	if Input.is_action_just_pressed("mouse_left"):
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
	
func switchItem(_a):
	if previousItem != null:
		previousItem.queue_free()
	if playerItem != null:
		var model
		if playerItem.model == 0:
			model = preload("res://Items/IronHandAxe.tscn")
		elif playerItem.model == 1:
			model = preload("res://Items/IronPickAxe.tscn")
		else:
			previousItem = null
			return
		currentItem = model.instance()
		$Rotation_Helper/Camera.add_child(currentItem)
		previousItem = currentItem
		currentItem = null
		return
	else:
		previousItem = null
	previousItem = currentItem
