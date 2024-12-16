extends Control

@export var websocket_url : String = "ws://localhost:25565"  # Server URL
var socket : WebSocketPeer = WebSocketPeer.new()
var last_state = WebSocketPeer.STATE_CLOSED
var selected_room_id: int = -1  # Store the selected room_id
@onready var create_room: Button = $"../create_room"
@onready var join_room: Button = $"../join_room"
@onready var refresh: Button = $"../refresh"
@onready var item_list: ItemList = $"../ItemList"
signal connected_to_server()
signal connection_closed()
signal message_received(message: Variant)
var json_parser = JSON.new()  
var current_room_id: String = ""

func _ready():
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect to server.")
	else:
		print("Attempting to connect to server...")
	set_process(true)

func send_message(message: String) -> void:
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(message)

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

func get_message() -> Variant:
	if socket.get_available_packet_count() < 1:
		return null
	var pkt = socket.get_packet()
	if socket.was_string_packet():
		return pkt.get_string_from_utf8()
	return bytes_to_var(pkt)

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

func update_room_list(rooms: Array) -> void:
	item_list.clear() 
	for room in rooms:
		var room_name = "Room ID: " + str(room["id"]) + " | Players: " + str(room["player_count"])
		item_list.add_item(room_name) 
		item_list.set_item_metadata(item_list.get_item_count() - 1, room["id"])  

func refresh_room_list() -> void:
	var request = { "type": "get_room_list" }
	var json_string = JSON.stringify(request)
	send_message(json_string)
	print("Sent request for room list.")

func _on_create_room_pressed() -> void:
	var request = { "type": "create_room" }
	var json_string = JSON.stringify(request)
	send_message(json_string)
	print("Sent request to create a new room.")

func _on_join_room_pressed() -> void:
	print("joining room ", selected_room_id)
	pass

func _on_item_list_item_selected(index: int) -> void:
	if index != -1:
		join_room.show()
		selected_room_id = item_list.get_item_metadata(index) 
		print("Room selected with ID:", selected_room_id)
	else:
		join_room.hide() 
		
func _on_refresh_pressed() -> void:
	refresh_room_list() 
	print("Sent request for room list.")
