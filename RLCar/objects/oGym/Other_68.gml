//This event is called when the python socket sends information

//Receive the reset signal
gym_receive_reset();

//This code block will run the first time an action list packet is received from the server
if global.started=false { 
	
	global.started = true; //Sets the global started variable to true
	gym_start();
	
}

//Update the global action list with the received actions for this step
global.action_list = gym_receive_actions();

// Only proceed with action processing if action list exists
if (!is_undefined(global.action_list)) {
	
	gym_step();
	
}

//Send observation
if observationtype = "Visual"{
	gym_send_screen(0);
}
else if observationtype = "Numeric"{
	gym_send_observation(global.observation_list);
}