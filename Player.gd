extends KinematicBody

export var speed:int = 5

var direction = Vector3()

# position setter which can be used for rpc
remote func _set_position(pos):
	global_transform.origin = pos

func _physics_process(_delta):
	direction = Vector3()
	
	if Input.is_action_pressed("ui_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("ui_right"):
		direction += transform.basis.x
	
	if Input.is_action_pressed("ui_up"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("ui_down"):
		direction += transform.basis.z
	
	direction = direction.normalized()
		
	if direction == Vector3():
		return
	
	# only move player if it belongs to the client
	if is_network_master():
		move_and_slide(direction * speed, Vector3.UP)

	# set position of the own player at the opponent
	rpc_unreliable("_set_position", global_transform.origin)
