//Gym code
{
	
	global.action_list = ds_list_create(); //Create the action list that will contain received actions
	global.observation_list = ds_list_create(); //Create the observation list that will contain the numeric observation
	global.info_list = ds_list_create(); //Create the info list that will contain info you want to pass to the model without including it in the observation
	global.connected=false; //Create connected variable
	global.port = 0; //Create port variable
	global.ip = ""; //Create IP variable
	global.started=false; //Create started variable

	global.actiontype="Discrete" //Set the action type:
	//Discrete:
	//In this mode, the agent can move forward, backward, and turn left and right. These are binary actions
	//Continous:
	//In this mode, the first action determines the acceleration amount(-1 to 1, multiplied by acceleration value)
	//And the second action determines the force/speed and direction with which the agent is turning the steering wheel(-1 to 1, multiplied by 6)
	//In this example this is passed through as a command line parameter by the python server that starts the client(in the start_client method of gmgym.py)

	observationtype = "Numeric"; //Set the observation type:
	//Visual: The screen(application_surface) will be sent as the observation. This does NOT include anything in the Draw GUI event.
	//Numeric: The observation will be sent as a list of floats
	//In this example this is passed through as a command line parameter by the python server that starts the client(in the start_client method of gmgym.py)

	displayMode = "all"; //Set the rendering mode ONLY if not using a visual observation space:
	//All: All processes will be shown when using parallel environments
	//First: Only the first process(first port) will be rendered
	//None: No windows will be shown

	//Used to automatically align the windows into a grid on your screen when using parallel environments
	autoalign=true; 
	
}


//Socket code
{
	
	alarm[1] = 60*(60*5); //Set the timeout alarm
	
	try
	{
	    //Process the parameters passed in through the execution of the game in the python script
	    var p_num;
	    p_num = parameter_count();
	    if p_num > 0
	    {
	        var i;
	        for (i = 0; i < p_num; i += 1)
	        {
	            p_string[i] = parameter_string(i + 1);
	        }
	    }
	    
		global.ip = p_string[0]; //Get the IP
	    global.port = p_string[1]; //Get the port number passed through in the training script for paralellization. 
	    observationtype = p_string[2]; //Get the observationtype passed through in the training script
		global.actiontype=p_string[3] //Get the actiontype passed through in the training script
	    displayMode = p_string[4]; //Get the displayMode passed through by the gym environments render method if you're using a numeric observation type
	}
	catch(_exception)
	{
	    show_debug_message("Failed to retrieve parameters. Using default port, observationtype, and displayMode.");
	}
	
	//Handle display mode
	//With a visual observation space, passing the screen along as the observation with gym_send_screen
	//The application_surface used as the screen buffer doesn't get created if draw_enable_drawevent is false
	//This unfortunately means that if we want to use the screen as an observation, we have to render each instance of the game.
	if observationtype = "Numeric"
	{
		switch(displayMode)
		{

			case "all":
				// Code to display all instances (This is the default so no code goes here)
				break;
				
			case "first":
				if (p_string[0]) == 8888 //Only draw the first instance of the subprocesses when using subprocvecenv
				{
				    draw_enable_drawevent(true);
				}
				else
				{
				    draw_enable_drawevent(false);
				}
				break;
				
			case "none":
				draw_enable_drawevent(false);
				break;
				
		}
	}

	global.client=undefined;
	alarm[0]=1; //Set the connection timer
}

//Window positioning code
//Useful if you're using subprocvecenv and want to automatically stagger the windows into a grid
//Set autoalign to false if you don't want this
if autoalign = true
{
	//Set window border to false
	window_set_showborder(false);
	
	// Define screen and window dimensions
	var screen_width = display_get_width();
	var screen_height = display_get_height();
	var window_width = window_get_width();
	var window_height = window_get_height();

	// Calculate how many windows can fit horizontally and vertically
	var windows_horizontal = floor(screen_width / window_width);
	var windows_vertical = floor(screen_height / window_height);

	// Calculate this window's position in the grid
	var position_index = global.port-8888; 

	var row = floor(position_index / windows_horizontal);
	var column = position_index mod windows_horizontal;

	var x_position = column * window_width;
	var y_position = row * window_height;

	// Set this window's position
	window_set_position(x_position, y_position);
		
}