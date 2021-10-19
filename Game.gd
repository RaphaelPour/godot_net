extends Spatial

func _ready():
	# initialize own player node
	var player1 = preload("res://Player.tscn").instance()
	
	# set node name to be the unique net id
	player1.set_name(str(get_tree().get_network_unique_id()))
	
	# set client which owns this player
	player1.set_network_master(get_tree().get_network_unique_id())
	
	# set spawn point
	player1.global_transform = $Player1Spawn.global_transform
	
	# add node to the game tree
	add_child(player1)

	var player2 = preload("res://Player.tscn").instance()
	player2.set_name(str(Globals.player2id))
	player2.set_network_master(Globals.player2id)
	player2.global_transform = $Player2Spawn.global_transform
	add_child(player2)
