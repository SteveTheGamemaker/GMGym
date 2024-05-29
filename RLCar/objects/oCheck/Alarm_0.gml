//Deactivate the checkmark unless the car is close to it(to avoid farming rewards by staying in one place)
if point_distance(x, y, oCar.x, oCar.y) > 512
{
	activated=false;
	mask_index = sprite_index;
}
else
{
	alarm[0]=1;
	mask_index = -1;
}