//Set whether you want the car to be controlled by AI or keyboard
controlmode="AI" 

//Set the starting position of the car
startx=x;
starty=y; 

//Set the number of sensors
sensors=32;

//Create the previous turn variable for the steering wheel visuals lerp
prevturn=0;

//Movement variables
mySpeed = 0; // Current mySpeed of the car
maxSpeed = 11; // Maximum mySpeed of the car
acceleration = 0.2; // How quickly the car accelerates
deceleration = 0.3; // How quickly the car slows down
turnSpeed = 0.42; // Turning mySpeed of the car
moveDirection = 0; //Move direction
move=0; //Whether the car is accelerating backwards, not accelerating, or accelerating forwards (-1 to 1)
turn=0; //Whether the car is turning left, not turning, or turning right (-1 to 1)
onRoad=1; //Whether the car is on the road or not

//Max sensor distance, used for normalizing the sensor distances
//The max sensor distance should be roughly the size of the longest line you could possibly travel on your track
//If your track takes up the whole room or even most of it, a good idea is to just use the higher of the room dimensions for this
maxsensordistance=1637;

checks=0; //Number of checkpoints collected

//Populate the information list
{
	ds_list_add(global.info_list, checks); //Add checks to info list
	ds_list_add(global.info_list, onRoad); //Add onRoad to info list
	ds_list_add(global.info_list, global.maxchecks); //Add the total number of checkpoints to info list
}

//Create sensors for numeric observation
{
	sensor_map = ds_map_create();
	for (var i = 1; i <= sensors; i++) {
		var sensor = instance_create_layer(x, y, "OnTrack", oSensor);
		sensor.direction = image_angle + (i - 1) * (360/sensors);
		ds_map_add(sensor_map, i, sensor);
	}
}

//Populate the numeric observation list
if oGym.observationtype = "Numeric"
{
	//Add normalized sensor distances to list
	for (var i = 1; i <= sensors; i++) {
		var sensor = ds_map_find_value(sensor_map, i);
		ds_list_add(global.observation_list, sensor.realdistance/maxsensordistance);
	}

	//Normalized speed
	ds_list_add(global.observation_list, mySpeed/maxSpeed)

	//Normalized image angle(direction the car is facing)
	ds_list_add(global.observation_list, image_angle/360)

	//Normalized move direction(direction the car is moving)
	ds_list_add(global.observation_list, moveDirection/360);

	//Normalized turn angle
	ds_list_add(global.observation_list, turn/90);
	
	//Last two actions
	ds_list_add(global.observation_list, 0);
	ds_list_add(global.observation_list, 0);
}

function step(){
	
	//Update the info list
	ds_list_replace(global.info_list, 0, checks) //Update the checkpoint count in the info list
	ds_list_replace(global.info_list, 1, onRoad); //Update the on road status in the info list
	ds_list_replace(global.info_list, 2, global.maxchecks); //Update the total number of checkpoints in the info list
	
	//Numeric observation update
	if oGym.observationtype = "Numeric"
	{
		//Update the sensor directions
		for (var i = 1; i <= sensors; i++) {
			var sensor = ds_map_find_value(sensor_map, i);
			sensor.direction = image_angle + (i - 1) * (360/sensors);
		}
	
		//Update the observation
		for (var i = 1; i <= sensors; i++) {
			var sensor = ds_map_find_value(sensor_map, i);
			ds_list_replace(global.observation_list, i - 1, sensor.realdistance/maxsensordistance);
		}
		
		//Normalized speed
		ds_list_replace(global.observation_list, sensors, mySpeed/maxSpeed)
	
		//Normalized image angle(direction the car is facing)
		ds_list_replace(global.observation_list, sensors+1, image_angle/360)
	
		//Normalized move direction(direction the car is moving)
		ds_list_replace(global.observation_list, sensors+2, moveDirection/360);
			
		//Turn angle
		ds_list_replace(global.observation_list, sensors+3, turn/90);
		
		//Last two actions
		if ds_exists(global.action_list, ds_type_list) //Make sure the action list exists
		{
			if ds_list_size(global.action_list) > 0 //Make sure the action list is populated
			{
				ds_list_replace(global.observation_list, sensors+4, ds_list_find_value(global.action_list, 0));
				ds_list_replace(global.observation_list, sensors+5, ds_list_find_value(global.action_list, 1));
			}
		}
		else
		{
			ds_list_replace(global.observation_list, sensors+4, 0);
			ds_list_replace(global.observation_list, sensors+5, 0);
		}
	}
	
	if controlmode = "AI" //If the AI is in control
	{
		if ds_exists(global.action_list, ds_type_list) //Make sure the action list exists
		{
			if ds_list_size(global.action_list) > 0 //Make sure the action list is populated
			{
				if global.actiontype = "Discrete"{
					//In this mode, the agent can move forward, backward, and turn left and right. These are binary actions
					move = ds_list_find_value(global.action_list, 0) - ds_list_find_value(global.action_list, 1); //Set the move variable
					turn = (ds_list_find_value(global.action_list, 3) - ds_list_find_value(global.action_list, 2))*90; //Set the turn variable
				}
				else if global.actiontype = "Continuous"{
					//In this mode, the first action determines the acceleration amount(-1 to 1, multiplied by acceleration value)
					//And the second action determines the speed and direction with which the agent is turning the steering wheel(-1 to 1, multiplied by 6)
					move = ds_list_find_value(global.action_list, 0);
					move = clamp(move, -0.85, 1); //Clamp the move value so you go slower backwards
					var turn1 = ds_list_find_value(global.action_list, 1);
					prevturn = turn;
					turn += turn1 * 6;
					turn = clamp(turn, -90, 90)
				}
			}
		}
	}
	else if controlmode = "human" //If the user is in control
	{
		move = keyboard_check(vk_up) - keyboard_check(vk_down); //Set the move variable
		turn = (keyboard_check(vk_left) - keyboard_check(vk_right)) * 90; //Set the turn variable
	}
	
	// Handling acceleration and movement
	if move != 0 { //If you're accelerating
		if move > 0 {
		    mySpeed += (acceleration * move); //Speed increases by acceleration value * acceleration amount determined by action list
		    if (mySpeed > maxSpeed) { //Makes sure the speed doesn't go over maxSpeed
		        mySpeed = maxSpeed; //Makes sure the speed doesn't go over maxSpeed
		    }
		} else if move < 0 {
			mySpeed += (acceleration * move); //Speed increases by acceleration value * acceleration amount determined by action list
		    if (mySpeed < -maxSpeed) { //Makes sure the speed doesn't go over maxSpeed
		        mySpeed = -maxSpeed; //Makes sure the speed doesn't go over maxSpeed
		    }
		}
	} else {
	    // Apply deceleration if not accelerating
	    if (mySpeed > 0) { 
	        mySpeed -= deceleration;
	    } else if (mySpeed < 0) {
	        mySpeed += deceleration;
	    } else {
			myspeed = 0;
		}
	}

	//Adjust the actual direction the car is facing
	image_angle += (turnSpeed * mySpeed) * (turn/90); // Turn based on current mySpeed

	// Calculate movement based on direction
	moveDirection = point_direction(0, 0, lengthdir_x(1, image_angle), lengthdir_y(1, image_angle));
	x += lengthdir_x(mySpeed, moveDirection);
	y += lengthdir_y(mySpeed, moveDirection);
	
	//Set the onroad variable to 0 when colliding with the track edge
	if place_meeting(x, y, oTrackEdge){
		onRoad=0;
	}
	else{
		onRoad=1;
	}
}