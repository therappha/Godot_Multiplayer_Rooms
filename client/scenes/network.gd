extends Control

#@export The WebSocket server URL to connect to.
@export var websocket_url : String = "ws://localhost:25565"
var socket : WebSocketPeer = WebSocketPeer.new()
var last_state = WebSocketPeer.STATE_CLOSED
var selected_room_id: int = -1
@onready var create_room: Button = $"../create_room"
@onready var join_room: Button = $"../join_room"
@onready var refresh: Button = $"../refresh"
@onready var item_list: ItemList = $"../ItemList"

signal connected_to_server()
signal connection_closed()
signal message_received(message: Variant)

var json_parser = JSON.new()
var current_room_id: String = ""

#@ Initializes the WebSocket connection and begins polling.
func _ready():
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect to server.")
	else:
		print("Attempting to connect to server...")
	set_process(true)

#@ Sends a message to the server over the WebSocket connection.
#@param message The message to be sent as a string.
func send_message(message: String) -> void:
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(message)

#@ Handles WebSocket polling and server state transitions each frame.
#@param delta The time elapsed since the last frame.
func _process(delta):
	if socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		socket.poll()
	var state = socket.get_ready_state()
	if last_state != state:
		last_state = state
		if state == WebSocketPeer.STATE_OPEN:
			print("Connected to server!")
			connected_to_server.emit()
		elif state == WebSocketPeer.STATE_CLOSED:
			print("Connection closed.")
			connection_closed.emit()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN and socket.get_available_packet_count() > 0:
		var message = get_message()
		if message != null:
			message_received.emit(message)
			handle_server_message(message)

#@ Retrieves the latest message from the WebSocket connection.
#@return The received message as a Variant or null if no message is available.
func get_message() -> Variant:
	if socket.get_available_packet_count() < 1:
		return null
	var pkt = socket.get_packet()
	if socket.was_string_packet():
		return pkt.get_string_from_utf8()
	return bytes_to_var(pkt)

#@ Parses and handles incoming server messages.
#@param message The message received from the server as a string.
func handle_server_message(message: String) -> void:
	var json_parser = JSON.new()
	var json_result = json_parser.parse(message)
	if json_result == OK:
		var data = json_parser.get_data()
		if data.has("error"):
			print("Error:", data["error"])
		else:
			if data.has("type"):
				var parsed_message = data
				match parsed_message["type"]:
					"room_list":
						update_room_list(parsed_message["rooms"])
					"create_ack":
						if parsed_message["success"]:
							print("Room created successfully!")
							refresh_room_list()
						else:
							print("Failed to create room.")
	else:
		print("Failed to parse JSON:", json_parser.get_error_message())

#@ Updates the displayed room list based on server data.
#@param rooms An array of dictionaries representing available rooms.
func update_room_list(rooms: Array) -> void:
	item_list.clear()
	for room in rooms:
		var room_name = "Room ID: " + str(room["id"]) + " | Players: " + str(room["player_count"])
		item_list.add_item(room_name)
		item_list.set_item_metadata(item_list.get_item_count() - 1, room["id"])

#@ Sends a request to refresh the list of available rooms.
func refresh_room_list() -> void:
	var request = { "type": "get_room_list" }
	var json_string = JSON.stringify(request)
	send_message(json_string)
	print("Sent request for room list.")

#@ Handles the Create Room button press event.
func _on_create_room_pressed() -> void:
	var request = { "type": "create_room" }
	var json_string = JSON.stringify(request)
	send_message(json_string)
	print("Sent request to create a new room.")

#@ Handles the Join Room button press event.
func _on_join_room_pressed() -> void:
	print("Joining room ", selected_room_id)
	pass

#@ Handles selection of a room from the ItemList.
#@param index The index of the selected item.
func _on_item_list_item_selected(index: int) -> void:
	if index != -1:
		join_room.show()
		selected_room_id = item_list.get_item_metadata(index)
		print("Room selected with ID:", selected_room_id)
	else:
		join_room.hide()

#@ Handles the Refresh button press event.
func _on_refresh_pressed() -> void:
	refresh_room_list()
	print("Sent request for room list.")
