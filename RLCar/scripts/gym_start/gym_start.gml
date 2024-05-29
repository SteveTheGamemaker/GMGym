//Called upon the very start of training(more specifically, when the first async event in oGym is triggered)
//This is game specific
function gym_start(){
	//show_message("Start");
	
	oControl.startdate = date_datetime_string(date_current_datetime()); //Set the start date
	
}