//Connect to python socket/OpenAI Gym environment
{
	global.client = network_create_socket(network_socket_tcp); //Create the client socket
	network_connect_raw(global.client, global.ip, real(global.port)); //Connect to the socket with the port passed along in the environment parameter by our python server that actually starts the game
	global.connected=true; //Set connected to true
}