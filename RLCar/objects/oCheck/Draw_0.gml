//We only want to draw the checkpoints when using a numeric observation space.
//When using a visual observation space, we don't want to clutter the agents vision with checkpoints.
//You might think we'd want the agent to see the checkpoints, but since he gets rewarded for collecting them anyways, this lets him focus more on driving and less on the checkpoints themselves.
if oGym.observationtype = "Numeric" && visible = true
{
	//Set the color of the checkpoint
	if selected = true { var checkcolor = c_lime; } else { var checkcolor = c_green; }

	//Draw the checkpoint and its information
	if activated = false
	{
		draw_set_halign(fa_center); //Align the text horizontally
		draw_set_valign(fa_center); //Align the text vertically
		//Draw the select/hover outline used for selecting which checkpoint to reset on in 'fixed' reset mode
		if hover=true 
		{
			if selected = true { var hovercolor = c_blue; } else { var hovercolor = c_red; }
			draw_sprite_ext(sprite_index, image_index, x, y, image_xscale+0.025, image_yscale+0.75, image_angle, hovercolor, 1);
		}
		draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, checkcolor, ((0.25*hover)+0.75)-0.25) //Draw the checkmark itself
		//draw_text(x, y, string(index)); //Draw the index of the checkmark
	}
}