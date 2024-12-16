extends Node2D

var server : TCPServer
var port : int = 6000
var client : StreamPeerTCP = null

#@ Initializes the server and starts listening on the specified port
func _ready():
	server = TCPServer.new()
	var result = server.listen(port)
	if result == OK:
		print("Godot TCP server started on port ", port)
		set_process(true)
	else:
		print("Failed to start server on port ", port)

#@ Processes incoming connections and handles client communication
func _process(delta):
	if server.is_connection_available():
		client = server.take_connection()
		if client:
			print("NODE.JS SERVER CONNECTED")

	if client != null:
		if client.get_available_bytes() > 0:
			var data = client.get_data(client.get_available_bytes())
			print("Raw data received:", data)
			_handle_client_data(data)

#@ Handles raw data received from the client
#@param data Array of raw bytes received
func _handle_client_data(data: Array) -> void:
	var ascii_array = data[1]
	var json_string = ""
	for ascii_value in ascii_array:
		json_string += String.chr(ascii_value)
	var json = JSON.new()
	var json_data = json.parse(json_string)

	if json_data == OK:
		var parsed_data = json.get_data()
		print("Parsed data: ", parsed_data)
		handle_message(parsed_data)
	else:
		print("Failed to parse JSON: ", json_data)

#@ Handles messages based on their type
#@param data Dictionary containing the parsed message data
func handle_message(data: Dictionary) -> void:
	match data["type"]:
		"create_room":
			handle_create_room(data)
		_:
			print("Unknown message type:", data["type"])

#@ Handles the creation of a new room and sends a response
#@param data Dictionary containing the message data for room creation
func handle_create_room(data: Dictionary) -> void:
	var room_id = create_room()
	print("Created new room with ID:", room_id)
	var response = {
		"type": "room_created",
		"success": true,
		"message": "Room created successfully!",
		"room_id": room_id
	}
	send_message(response)

#@ Creates a unique room ID
#@return int A randomly generated room ID
func create_room() -> int:
	return randi_range(49152, 65535)

#@ Sends a JSON response to the client
#@param response Dictionary containing the response data
func send_message(response: Dictionary) -> void:
	var json_parser = JSON.new()
	var json_string = json_parser.stringify(response)
	client.put_data(json_string.to_utf8_buffer())
	print("Sent response:", json_string)
