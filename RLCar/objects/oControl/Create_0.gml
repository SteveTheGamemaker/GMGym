randomize();
global.iterations = 0; //Set iterations
global.maxchecks = 512; //Set maxchecks - I realy don't recommend putting this above 512, (ESPECIALLY if you have a lower end machine)
global.maxcheckscollected = 0;

path_increment = 1/global.maxchecks; //Set the path increment for the path_get_x and path_get_y functions that will be used to scatter checkpoints along the track
fixedpoint=irandom_range(path_increment, path_increment*global.maxchecks); //Set the fixed reset point to the first pseudo-point
startdate = "Not started yet"; //Set the startdate string to not started yet
currentdate = date_datetime_string(date_current_datetime()); //Set the current date
path_id = Path1; //Set the path to the tracks path

debuginfo=true; //Set toggle for displaying debug info

// Add a new list to track maxcheckscollected for each point
global.checksCollectedList = ds_list_create();
// Initialize the list with zeros
for (var i = 0; i < global.maxchecks; i++) {
    ds_list_add(global.checksCollectedList, 0);
}

resetmode="randomnorepeat"; //This is used to determine where the car will be placed upon reset -
//randomnorepeat: Will randomly visit points along the path, not allowing any repeats, so that all points in the track are visited equally, but in a random order
//randomgeneral: Will randomly visit points along the track itself, with a random direction. This is useful for making the car visit any possible position and situation it can be in. This was added as an attempt to get the car in situations where it is close to a wall and will need to learn how to reverse.
//random: Will randomly visit points along the path
//fixed: Will visit the same point on the path (You can use the mouse to select which checkpoint this is. This can be useful if your agent is having trouble with a specific part of the track and you want to visit it.
//optimized: (BROKEN CURRENTLY) will collect data on the first lap of paths and then visit them in order of least rewards collected per reset

//Create checkpoints for rewards
{
	//In this code, we are creating pseudo points that are along the path instead of actually using the path points. This is mostly so we don't have to spend so much time creating paths but it also results in the paths looking more aesthetically pleasing and I suppose the numbers will be prettier as the checkpoints end up being the same distance apart.

	// Loop through each pseudo-point in the path
	for (var i = 0; i < global.maxchecks; i++) {
	    // Get the first point's position
		if i>0{
			var x_pos = path_get_x(path_id, (i*path_increment)-path_increment);
			var y_pos = path_get_y(path_id, (i*path_increment)-path_increment);
		}
		else{
			var x_pos = 0;
			var y_pos = 0;
		}
    
	    // Create an instance of 'oCheck' at the current point
	    var instance = instance_create_layer(x_pos, y_pos, "OnTrack", oCheck);
		instance.index = i+1;
    
	    // Check if this is not the last point in the path
	    if (i < global.maxchecks - 1) {
	        // Get the next point's position
	        var next_x_pos = path_get_x(path_id, (i*path_increment)+path_increment);
	        var next_y_pos = path_get_y(path_id, (i*path_increment)+path_increment);
			
			// Get the last point's position
			var last_x_pos = path_get_x(path_id, (i*path_increment)-path_increment);
	        var last_y_pos = path_get_y(path_id, (i*path_increment)-path_increment);
        
	        // Set the image_angle of the instance to point towards the next point
	        instance.image_angle = point_direction(last_x_pos, last_y_pos, next_x_pos, next_y_pos)+90;
	    } else {
	        // Optional: If the path is closed and you want the last point to point towards the first
	        var first_x_pos = path_get_x(path_id, 0);
	        var first_y_pos = path_get_y(path_id, 0);
	        instance.image_angle = point_direction(x_pos, y_pos, first_x_pos, first_y_pos)+90;
        
	        // If you don't need the last point to rotate towards the first, you might just not rotate it
	        // Or handle the logic as needed if your path is not closed
	    }
	}
}

//Reset function
function reset(){
	
		//Update debug info
		global.iterations += 1;
        if (oCar.checks > global.maxcheckscollected) { global.maxcheckscollected = oCar.checks; }
	
		//Create randpathpoint variable
		var randpathpoint = 0;

		//Helper function for finding the minimum value in a list(used in the 'optimize' reset mode)
		function find_min_index(list) {
			var min_val = ds_list_find_value(list, 0);
			var min_index = 0;
			
			for (var i = 1; i < ds_list_size(list); i++) {
				var val = ds_list_find_value(list, i);
				if (val < min_val) {
					min_val = val;
					min_index = i;
				}
			}
			
			return min_index;
		}
			
		//Helper function for finding the maximum value in a list(used in the 'optimize' reset mode)
		function find_max_index(list) {
			var max_val = ds_list_find_value(list, 0);
			var max_index = 0;
			
			for (var i = 1; i < ds_list_size(list); i++) {
				var val = ds_list_find_value(list, i);
				if (val > max_val) {
					max_val = val;
					max_index = i;
				}
			}
			
			return max_index;
		}
		
		//Determine where the car should be placed on the path on reset
		switch (resetmode) 
		{

		    case "random":
		        var randpathpoint = irandom(global.maxchecks)*path_increment;
		        break;

		    case "randomnorepeat":
		        var numlist1 = ds_list_create();
		        randomize();
		        while (true) {
		            // Check if the size of 'numlist1' is under the amount of points in the path
		            if (ds_list_size(numlist1) < global.maxchecks) {
		                // Generate a random number out of the amount of points in the path
		                var number = irandom(global.maxchecks - path_increment);
                
		                // If the number isn't in the list of already visited points, add it, and set the new path point to it
		                if (ds_list_find_index(numlist1, number) == -1) {
		                    ds_list_add(numlist1, number);
		                    randpathpoint = number*path_increment;
		                    break; // Break out of the while loop, but not the switch statement
		                }
		            } else {
		                // If 'numlist1' size is the amount of points in the path or over, clear the list
		                ds_list_clear(numlist1);
		            }
		        }
		        break;
			
			case "optimize":
				if (global.iterations <= global.maxchecks) {
					var numlist = ds_list_create();
					randomize();
					var found = false;
					while (!found) {
						var number = irandom(global.maxchecks - 1);
						if (ds_list_find_index(numlist, number) == -1) {
							ds_list_add(numlist, number);
							randpathpoint = number * path_increment;
							found = true;
						}
						// If all points have been visited, clear the list and start over
						if (ds_list_size(numlist) >= global.maxchecks) {
							ds_list_clear(numlist);
						}
					}
				} else {
					// After collecting data, switch to visiting points based on least maxcheckscollected
					var minIndex = find_min_index(global.checksCollectedList);
					randpathpoint = minIndex * path_increment;
					// Update the point's maxcheckscollected to a high value to avoid immediate repetition
					ds_list_replace(global.checksCollectedList, minIndex, find_max_index(global.checksCollectedList) + 1);
				}
				break;
			
			case "randomgeneral":
				// Loop until a free spot is found
				with(oCar){
					var spotFound = false; // A flag to track whether a free spot has been found
					while (!spotFound) {
					    // Generate random x and y coordinates within the room boundaries
					    other.newgeneralx = random(room_width);
					    other.newgeneraly = random(room_height);
					
					    // Check for collision with oTrackEdge at the random coordinates
					    if (!place_meeting(other.newgeneralx, other.newgeneraly, oTrackEdge)) {
					        spotFound = true;
							x = other.newgeneralx;
							y = other.newgeneraly;
							image_angle = random(360);
							moveDirection = 0;
						}
					}
				}
				break;
				
		    case "fixed":
		        randpathpoint = fixedpoint;
		        break;
			
		}
		
		//Place the car in its new position (for path based reset modes)
		if resetmode != "randomgeneral"{
			oCar.x = path_get_x(path_id, randpathpoint);
			oCar.y = path_get_y(path_id, randpathpoint);
			oCar.image_angle = point_direction(path_get_x(path_id, randpathpoint-path_increment), path_get_y(path_id, randpathpoint-path_increment), path_get_x(path_id, randpathpoint+path_increment), path_get_y(path_id, randpathpoint+path_increment));
			//oCar.image_angle = random(360);
			oCar.moveDirection = 0;
		}
		
		//Reset the cars onRoad state
		oCar.onRoad=1;
		
		//Reset the cars speed
        oCar.mySpeed = 0;
		
		//Reset the number of checkpoints the car has collected
        oCar.checks = 0;
		
		//Reset the wheel angle
		oCar.turn = 0;
		
		//Reset the checkpoints activated status
        with (oCheck) {
            activated = false;
            mask_index = sprite_index;
        }
}