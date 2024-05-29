draw_sprite_ext(sprTrack, 0, 512-228, 512-228, 0.0625, 0.0625, 0, c_black, 0.3); //Draw map
draw_circle_color((512-228)+(oCar.x*0.0625), (512-228)+(oCar.y*0.0625), 2, c_lime, c_lime, false); //Draw player dot on map


//Draw debug info
if debuginfo = true{
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_aqua)
	draw_set_alpha(0.75);
	draw_text(0, 0, "Port: " + string(global.port));
	draw_text(0, 18, "Resets: " + string(global.iterations))
	draw_text(0, 18*2, "Wheel Angle: " + string(oCar.turn))
	draw_text(0, 18*3, "Turn Angle: " + string(ds_list_find_value(global.action_list, 1)))
	draw_text(0, 18*4, "Acceleration: " + string(oCar.move))
	draw_text(0, 18*5, "Checkpoints Collected: " + string(oCar.checks));
	draw_text(0, 18*6, "Max Checkpoints Collected: " + string(global.maxcheckscollected));
	draw_text(0, 18*7, "Total Possible Reward(per lap): " + string(global.maxchecks));
	draw_text(0, 18*8, "Start Time: " + string(startdate));
	draw_text(0, 18*9, "Current Time: " + string(currentdate));
	draw_text(0, 18*10, "Reset Mode(R to change): " + resetmode);
	draw_text(0, 18*11, "Control Mode(C to change): " + oCar.controlmode);
	draw_text(0, 18*12, "Observation Type: " + oGym.observationtype);
	if oGym.observationtype = "Numeric"{
		draw_text(0, 18*13, "Press D to toggle checkpoint and sensor visualization");
	}
	draw_set_color(c_white)
	
}

//Draw steering wheel in the real GUI event when using a numeric observation type
if oGym.observationtype = "Numeric" {
	if global.actiontype = "Discrete"{ //Only lerp the steering wheel in continuous mode otherwise the wheel doesn't fully rotate to the left or right
		draw_sprite_ext(sprWheel, 0, 64, 448, 1, 1, oCar.turn, c_white, 0.3);
	}
	else
	{
		draw_sprite_ext(sprWheel, 0, 64, 448, 1, 1, lerp(oCar.prevturn, oCar.turn, 0.75), c_white, 0.3);
	}
	
}