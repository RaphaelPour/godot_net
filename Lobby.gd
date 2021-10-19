extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# connect callback that fires once a player joins
	get_tree().connect("network_peer_connected", self, "_player_connected")

# gets called once the opponent has connected successfull. This mirror-like
# event gets emitted on both sides, regardless of host/client.
func _player_connected(id):
	print("a player connected: " + str(id))
	# Stores the opponent's unique net id for identification
	Globals.player2id = id
	
	# Loads game and adds it to the game lobby tree
	var game = preload("res://Game.tscn").instance()
	get_tree().get_root().add_child(game)
	hide()

func _on_ButtonHost_pressed():
	# creates a new connection (aka network)
	var net = NetworkedMultiplayerENet.new()
	
	# creates a new server with the given port and up to two clients (including
	# the server itself)
	net.create_server(int($NetworkSettings/CenterContainer/VBoxContainer/GridContainer/PortEdit.text),2)
	
	get_tree().set_network_peer(net)
	print("start server localhost:1337")


func _on_ButtonJoin_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_client(
		$NetworkSettings/CenterContainer/VBoxContainer/GridContainer/HostEdit.text,
		int($NetworkSettings/CenterContainer/VBoxContainer/GridContainer/PortEdit.text)
	)
	get_tree().set_network_peer(net)
	print("connect to server localhost:1337")
