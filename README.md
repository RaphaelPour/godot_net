# NET

Educational project about [High-Level
multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html) with Godot based on [this
video](https://www.youtube.com/watch?v=K0luHLZxjBA).

- lobby configures, listens and establishes connections
- on successful connection, both sides load the game scene
- each game scene loads both players
- game consists of two movable and collidable capsulses on a floor
- on moving a player, the transformation matrix gets synced with the opponent

## Getting started

Default hostname is `localhost` such as port `1337`.

1. start twice (e.g. by start godot with this project twice)
2. click `Create server` on the first instance
3. click `Join` on the second instance
4. move around with arrow-keys

## Networking

__Client__ will be denoted with (C) and __Server__ with (S) whereas __opponent__
reffers to the other side. 


### Establish a connection [[Lobby](Lobby.gd)]

It begins with setting up a network `NetworkedMultiplayerENet` on both sides.
Beside hostname and port, the max. client count can be defined at (S).

The (S) sets up a new server, the client tries to connect to one. This is the
only exception where the code differs on both sides. The network will get stored
to the lobbie's node tree so it can react to events.
```
#
# set up client
#

# creates a new connection (aka network)
var net = NetworkedMultiplayerENet.new()
	
# creates a new server with the given port and up to two clients (including
# the server itself)
net.create_server(PORT,MAX_CLIENTS)
	
get_tree().set_network_peer(net)

#
# set up client
#   
var net = NetworkedMultiplayerENet.new()
net.create_client(HOSTNAME, PORT)
get_tree().set_network_peer(net)
```

Once (C) and (S) are connected, the `network_peer_connected` event fires on
both sides with an unique net identifier (also known as `peer_id`, `net_id`).
This is the reference to the opponent which gets used anytime a specific 
player (other than self) needs to get addressed.

The `net_id` [gets stored away](Globals.gd) for later use.

```
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
```



### Initialize game [[Game](Game.gd)]

Both players will get set up where the player number is relative to the
opponent. The own one will always be `player1` and `player2 the other/peer.

The player's `network_master` refers to the owner's `net_id`. This is important
to differ between both players and ensure they behave properly (the opponent
shouldn't move the own player).

```
var player1 = preload("res://Player.tscn").instance()
	
# set node name to be the unique net id
player1.set_name(str(get_tree().get_network_unique_id()))
	
# set client which owns this player
player1.set_network_master(get_tree().get_network_unique_id())

var player2 = preload("res://Player.tscn").instance()
player2.set_name(str(Globals.player2id))
player2.set_network_master(Globals.player2id)
```


### Updating the players [[Player](Player.gd)]

On processing the user's input, the transformation will be made if it's the
own player. Afterwards the latest position/transformation will get pushed to
the opponent via rpc using a __remote__ position setter.

```
# position setter which can be used for rpc
remote func _set_position(pos):
	global_transform.origin = pos

func _physics_process(_delta):
    # process movement
    ...
	
	# only move player if it belongs to the client
	if is_network_master():
		# actually move player
        ...

	# set position of the own player at the opponent
	rpc_unreliable("_set_position", global_transform.origin)
```
