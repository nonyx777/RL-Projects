extends Node3D

@onready var cart: RigidBody3D = $Cart
@onready var pole: RigidBody3D = $Pole

func _ready() -> void:
	pole.linear_velocity = Vector3.ZERO
	pole.angular_velocity = Vector3.ZERO
	cart.linear_velocity = Vector3.ZERO
	cart.angular_velocity = Vector3.ZERO
	

func _process(_delta: float) -> void:
	if Input.is_action_pressed("left"):
		cart.apply_force(Vector3(-10, 0, 0))
	if Input.is_action_pressed("right"):
		cart.apply_force(Vector3(10, 0, 0))
