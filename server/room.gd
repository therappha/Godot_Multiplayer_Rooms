
#generate ENetworkPeer server, try to upnp a port and send this port as a return of create_room, when player join
#the ip should be the same, but the port that connects to the ENetworkPeer server will be what changes wich room it will enter!

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("Room is ready, waiting for connections...")

# Handle incoming client connection
func _on_peer_connected(id: int):
	print("Client connected: ", id)
	#tell server.gd player joined room_id, it needs to send send a message to  server.js code to update roomlist size

# Handle client disconnection
func _on_peer_disconnected(id: int):
	print("Client disconnected: ", id)
	## if player on room
		##tell server.gd player left room_id, it needs to send a message to server.js code to update roomlist size
