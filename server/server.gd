extends Node2D

var server : TCPServer
var port : int = 6000
var client : StreamPeerTCP = null  # Store the current connected client

func _ready():
	# Initialize TCPServer
	server = TCPServer.new()

	# Start listening on the specified port
	var result = server.listen(port)
	if result == OK:
		print("Godot TCP server started on port ", port)
		set_process(true)
	else:
		print("Failed to start server on port ", port)

# Called every frame
func _process(delta):
	# Accept new incoming connections if available
	if server.is_connection_available():
		client = server.take_connection()
		if client:
			print("NODE.JS SERVER CONNECTED")
	
	if client != null:
		if client.get_available_bytes() > 0:
			# Get the data as an Array (instead of PoolByteArray)
			var data = client.get_data(client.get_available_bytes())  # This now returns an Array of bytes
			print("Raw data received:", data)
			_handle_client_data(data)  # Call a separate function to handle the raw data

# Function to handle raw data
func _handle_client_data(data: Array) -> void:
	# Step 1: Extract the ASCII array (second element in the raw data)
	var ascii_array = data[1]  # This is the array of ASCII values

	# Step 2: Convert the ASCII values to a string
	var json_string = ""
	for ascii_value in ascii_array:
		json_string += String.chr(ascii_value) # Convert each ASCII value to a character

	# Step 3: Parse the JSON string
	var json = JSON.new()  # Create an instance of the JSON class
	var json_data = json.parse(json_string)  # Parse the JSON string using the instance

# Check if parsing was successful
	if json_data == OK:
		var parsed_data = json.get_data()  # Retrieve the parsed data (this is the Dictionary)
		print("Parsed data: ", parsed_data)  # This will print the parsed JSON object
		handle_message(parsed_data)  # Pass the parsed data to handle_message
	else:
		print("Failed to parse JSON: ", json_data)  # Output the error code if parsing fails



# Handle different types of messages
func handle_message(data: Dictionary) -> void:
	match data["type"]:
		"create_room":
			handle_create_room(data)
		_:
			print("Unknown message type:", data["type"])

# Handle creating a new room
func handle_create_room(data: Dictionary) -> void:
	var room_id = create_room()  # Call the function to generate a unique room ID
	print("Created new room with ID:", room_id)
	var response = { 
		"type": "room_created", 
		"success": true, 
		"message": "Room created successfully!", 
		"room_id": room_id  # Include the generated room ID in the response
	}
	send_message(response)

# Returns roomport
func create_room() -> int:
	return (randi_range(49152, 65535))

func send_message(response: Dictionary) -> void:
	var json_parser = JSON.new()
	var json_string = json_parser.stringify(response)  # Convert to JSON string
	client.put_data(json_string.to_utf8_buffer())  # Send the response as UTF-8 encoded data
	print("Sent response:", json_string)
