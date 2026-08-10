extends Node3D

@onready var cart: RigidBody3D = $"Cart-Pole/Cart"
@onready var pole: RigidBody3D = $"Cart-Pole/Pole"

@onready var ai_controller: AIController3D = $AIController3D

const MAX_POLE_ANGLE: float = deg_to_rad(30)
const MAX_CART_DIST: float = 2.5
const MAX_NUM_STEPS: int = 500
const CART_FORCE: float = 5.0

var pole_default_transform: Transform3D
const cart_default_position: Vector3 = Vector3.ZERO

func reset_values() -> void:
	pole.transform = pole_default_transform
	cart.position = cart_default_position
	
	pole.linear_velocity = Vector3.ZERO
	pole.angular_velocity = Vector3.ZERO
	cart.linear_velocity = Vector3.ZERO
	cart.angular_velocity = Vector3.ZERO

func termination_conditions() -> bool:
	var pole_angle: float = ai_controller.pole_angle
	var cart_pos_x: float = ai_controller.cart_pos_x
	
	var pole_failed: bool = abs(pole_angle) > MAX_POLE_ANGLE
	var cart_failed: bool = abs(cart_pos_x) > MAX_CART_DIST
	var time_limit: bool = ai_controller.n_steps >= MAX_NUM_STEPS
	
	
	if pole_failed or cart_failed:
		ai_controller.reward = -1.0
	else:
		ai_controller.reward = 1.0
	
	if pole_failed or cart_failed or time_limit:
		ai_controller.reset()
		reset_values()
		return true
	return false

func _ready() -> void:
	pole_default_transform = pole.transform
	reset_values()

func _physics_process(_delta: float) -> void:
	var force: Vector3 = Vector3.ZERO
	match ai_controller.slide:
		0:
			force = Vector3.LEFT * CART_FORCE
		1:
			force = Vector3.RIGHT * CART_FORCE
	
	cart.apply_central_force(force)
	
	if termination_conditions():
		return
