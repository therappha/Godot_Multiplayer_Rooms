# Godot Room Manager with WebSocket
This is a **simple room manager** designed for **Godot** using **WebSocket**. The Node.js server acts as a lobby for players to join and manage rooms.

-⚠️ **Note**: This is not the most optimal solution. but it was what I could do with my current knowledge. Feel free to try it out, modify, and use the code!


## How It Works
- **WebSocket Communication**: Clients connect to the WebSocket server to get a list of available rooms.
- **Room List & Ports**: Each room in the `room_list` represents a port where an `ENetworkPeer` server is running.
- **Joining a Room**: 
  - The "Join" button on the client uses `peer.create_client(static_ip, int(port))`, where `port` corresponds to the selected room's ID.
- **Server Communication**: 
  - The client communicates with the Node.js server only when not in a room.
  - Once in a room, communication bypasses the Node.js server and goes directly through `ENetworkPeer`. This approach overcomes the 32-player limit of `ENetworkPeer`.

---

## Features
- **Room Creation**: Clients can request the WebSocket server to create rooms, then the websocket will request server.gd to create a room with Enetworkpeer!.
- **Room Management**: The server manages and shares a list of active rooms with connected clients.
- **Scalability**: Bypasses the limitations of `ENetworkPeer` for rooms by managing connections at the Node.js level.

---

## Getting Started

### Prerequisites
- **Godot**: Make sure Godot is installed to run the server and client projects.
- **Node.js & npm**: Required for the Node.js WebSocket server.

---

### How to Test

1. **Set Up the Godot Server**:
   - Open the **server project** in Godot.
   - Start the server. By default, it runs on `localhost` and port `6000`. Check the output logs for IP and port details.

2. **Set Up the Node.js WebSocket Server**:
   - Navigate to the `node_server` folder in your terminal.
   - Run the following commands:
     ```bash
     npm init -y          # Initialize an npm project
     npm install ws       # Install the WebSocket library
     node server.js       # Start the WebSocket server
     ```
   - Ensure the Godot server is running before starting `server.js`.

3. **Set Up the Godot Client**:
   - Open the **client project** in Godot and run it.
   - Check the `console.out` messages to verify connectivity.
   - Use the Buttons to:
     - **Create Room**: Requests the WebSocket server to create a new room.
     - **Refresh**: Retrieves the current list of rooms from the WebSocket server.

---

## Troubleshooting
- Ensure both the **Godot server** and **Node.js WebSocket server** are running before starting the client.
- Verify the `static_ip` and port values are correctly configured.

---

## Notes
- This project is a work in progress and is not fully functional yet.
- The primary goal is to bypass the limitations of `ENetworkPeer` for a lobby creation!.

---

## License
Feel free to use, modify, and share the code! Contributions are more than welcome.

---

Thanks for checking out this project! 😊
