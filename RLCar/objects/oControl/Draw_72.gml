//Draw the steering wheel in the actual draw event for a visual observation since the application_surface doesn't capture Draw GUI events
if oGym.observationtype = "Visual" {
	if global.actiontype = "Continuous"{ //Only lerp the steering wheel in continuous mode otherwise the wheel doesn't fully rotate to the left or right
		draw_sprite_ext(sprWheel, 0, camera_get_view_x(view_get_camera(0))+64, camera_get_view_y(view_get_camera(0))+448, 1, 1, lerp(oCar.prevturn, oCar.turn, 0.75), c_white, 0.3);
	}
	else
	{
		draw_sprite_ext(sprWheel, 0, camera_get_view_x(view_get_camera(0))+64, camera_get_view_y(view_get_camera(0))+448, 1, 1, oCar.turn, c_white, 0.3);
	}
}