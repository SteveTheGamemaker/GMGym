//Set the variable that returns if the mouse is hovering over the checkpoint
if collision_point(mouse_x, mouse_y, self, true, false)
{
	hover = 1;
}
else
{
	hover = 0;
}

if mouse_check_button_released(mb_left) //If you release the left mouse button
{
	if hover = true //If the mouse is hovering over this checkpoint
	{
		selected = true; //Set selected to true	
		oControl.fixedpoint = index*oControl.path_increment //Set the cars new reset point to this checkpoints point on the path
	}
	else if collision_point(mouse_x, mouse_y, oCheck, true, true) //If the mouse is hovering over any other checkpoint
	{
		selected = false;
	}
}