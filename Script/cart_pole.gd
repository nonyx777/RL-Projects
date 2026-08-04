extends Node3D

@onready var cart: RigidBody3D = $Cart

func _process(_delta: float) -> void:
	if Input.is_action_pressed("left"):
		cart.apply_force(Vector3(-10, 0, 0))
	if Input.is_action_pressed("right"):
		cart.apply_force(Vector3(10, 0, 0))
