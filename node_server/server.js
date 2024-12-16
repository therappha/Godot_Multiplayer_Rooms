const WebSocket = require('ws');
const net = require('net');

let rooms = [];
const tcpClient = new net.Socket();
const TCP_SERVER_HOST = 'localhost';
const TCP_SERVER_PORT = 6000;

tcpClient.connect(TCP_SERVER_PORT, TCP_SERVER_HOST, () => {
	console.log(`Connected to TCP server at ${TCP_SERVER_HOST}:${TCP_SERVER_PORT}`);
});

const wss = new WebSocket.Server({ port: 25565 });

wss.on('connection', (ws) => {
	console.log('New client connected');
	ws.on('message', (message) => {
		console.log('Received message:', message);
		try {
			const data = JSON.parse(message);
			if (data.type === 'get_room_list') {
				handleGetRoomList(ws);
			} else if (data.type === 'create_room') {
				handleCreateRoomRequest(ws);
			} else {
				console.log('Unknown message type:', data.type);
			}
		} catch (err) {
			console.error('Error parsing message:', err);
		}
	});
	ws.on('close', () => {
		console.log('Client disconnected');
	});
});

console.log('WebSocket server is running on ws://localhost:25565');

function handleGetRoomList(ws) {
	const roomListResponse = {
		type: 'room_list',
		rooms: rooms
	};
	ws.send(JSON.stringify(roomListResponse));
	console.log('Sent room list:', rooms);
}

function handleCreateRoomRequest(ws) {
	console.log('Received create_room request');
	const createRoomMessage = JSON.stringify({ type: 'create_room' });
	tcpClient.write(createRoomMessage);
	console.log('sent create_room to tcp');
	tcpClient.once('data', (data) => {
		const response = JSON.parse(data.toString());
		console.log('Received response from TCP server:', response);
		if (response.success) {
			const newRoom = {
				id: response.room_id,
				player_count: 0
			};
			rooms.push(newRoom);
			const createRoomResponse = {
				type: 'create_ack',
				success: true,
				message: 'Room created successfully!',
				room_id: newRoom.id
			};
			ws.send(JSON.stringify(createRoomResponse));
			console.log('Room created and added to room list:', newRoom);
		} else {
			const createRoomResponse = {
				type: 'create_ack',
				success: false,
				message: 'Failed to create room!'
			};
			ws.send(JSON.stringify(createRoomResponse));
			console.log('Failed to create room:', response.message);
		}
	});
}
