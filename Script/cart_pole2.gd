extends Node3D

@onready var cart: RigidBody3D = $"Cart-Pole/Cart"
@onready var pole: RigidBody3D = $"Cart-Pole/Pole"

@onready var ai_controller: AIController3D = $AIController3D

const MAX_CART_DIST: float = 1.9
const MAX_NUM_STEPS: int = 800
const CART_FORCE: float = 10.0
const MAX_POLE_ANGULAR_VELOCITY: float = 200

var POLE_DEFAULT_TRANSFORM: Transform3D
const CART_DEFAULT_POSITION: Vector3 = Vector3.ZERO

const SOLVED_REWARD: float = 0.85
const SOLVED_EPISODES: int = 5

var episode_returns: Array[float] = []
var current_episode_return: float = 0.0
var solved: bool = false


func reset_values() -> void:
	pole.transform = POLE_DEFAULT_TRANSFORM
	cart.position = CART_DEFAULT_POSITION
	
	pole.linear_velocity = Vector3.ZERO
	pole.angular_velocity = Vector3.ZERO
	cart.linear_velocity = Vector3.ZERO
	cart.angular_velocity = Vector3.ZERO

func get_average_reward() -> float:
	var total_reward: float = 0.0

	for episode_return in episode_returns:
		total_reward += episode_return

	return total_reward / episode_returns.size()

func check_if_solved() -> void:
	episode_returns.append(current_episode_return)

	if episode_returns.size() > SOLVED_EPISODES:
		episode_returns.pop_front()

	if episode_returns.size() == SOLVED_EPISODES:
		var average_reward: float = get_average_reward()

		if average_reward >= SOLVED_REWARD:
			solved = true
			print("Environment solved!")

	current_episode_return = 0.0

func reward_func(angle: float, pos_x: float) -> float:
	var n: float = 0.5 * (1.0 - cos(angle))
	var d: float = pow(pos_x / MAX_CART_DIST, 2.0)
	return n - d
	

func termination_conditions() -> bool:
	var pole_angular_velocity: float = ai_controller.pole_angular_velocity
	var cart_pos_x: float = ai_controller.cart_pos_x
	var pole_angle: float = ai_controller.pole_angle
	
	var pole_failed: bool = abs(pole_angular_velocity) > MAX_POLE_ANGULAR_VELOCITY
	var cart_failed: bool = abs(cart_pos_x) > MAX_CART_DIST
	var time_limit: bool = ai_controller.n_steps >= MAX_NUM_STEPS
	
	
	if cart_failed:
		ai_controller.reward = -400
	else:
		ai_controller.reward = reward_func(pole_angle, cart_pos_x)
	
	current_episode_return += ai_controller.reward
	
	if pole_failed or cart_failed or time_limit:
		current_episode_return /= MAX_NUM_STEPS
		check_if_solved()
		ai_controller.reset()
		reset_values()
		return true
	return false

func _ready() -> void:
	POLE_DEFAULT_TRANSFORM = pole.transform
	reset_values()

func _physics_process(_delta: float) -> void:
	var force: Vector3 = Vector3.ZERO
	match ai_controller.slide:
		0:
			force = Vector3.LEFT * CART_FORCE
		1:
			force = force
		2:
			force = Vector3.RIGHT * CART_FORCE
			
	
	cart.apply_central_force(force)
	
	if termination_conditions():
		return
