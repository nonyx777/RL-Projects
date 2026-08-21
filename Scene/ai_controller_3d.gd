extends AIController3D


@onready var cart: RigidBody3D = $"../Cart-Pole/Cart"
@onready var pole: RigidBody3D = $"../Cart-Pole/Pole"

var slide: int = 0
var pole_angle: float = 0
var cart_pos_x: float = 0
var pole_angular_velocity: float = 0

func get_pole_angle() -> float:
	var pole_dir: Vector3 = (pole.position - cart.position).normalized()
	return atan2(pole_dir.dot(Vector3.RIGHT), pole_dir.dot(Vector3.DOWN))

func get_pole_angular_velocity() -> float:
	var angular_velocity: float = pole.angular_velocity.dot(Vector3.FORWARD)
	return angular_velocity

func get_obs() -> Dictionary:
	pole_angle = get_pole_angle()
	cart_pos_x = cart.position.x
	pole_angular_velocity = get_pole_angular_velocity()
	var obs: Array = [
		cart_pos_x,
		cart.linear_velocity.x,
		sin(pole_angle),
		cos(pole_angle),
		pole_angular_velocity
	]
	return {"obs":obs}

func get_reward() -> float:	
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"slide" : {
			"size": 2,
			"action_type": "discrete"
		},
	}
	
func set_action(action) -> void:
	slide = int(action["slide"])
