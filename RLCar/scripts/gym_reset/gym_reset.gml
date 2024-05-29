//Activated when the reset method is called in the gym environment
//This is game specific. Do not try to restart the game or the room as this will interrupt the socket connection
//Resetting things like position, image_angle, etc, is sufficient for this
function gym_reset(){
	//show_message("Reset");
	
	randomize(); // Optional
	
	with(oControl){
		reset();
	}
	
}