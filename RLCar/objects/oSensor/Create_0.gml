distance = 24 //Set the starting distance
realdistance = 0 //Set the realdistance
x1=0; //Set the starting x for the end of the sensor ray
y1=0; //Set the starting y for the end of the sensor ray

function step(){
	x = oCar.x + lengthdir_x(8, direction); //Set the x to the cars x plus 8 pixels in the direction of the sensor
	y = oCar.y + lengthdir_y(8, direction); //Set the x to the cars y plus 8 pixels in the direction of the sensor
	colobject = oTrackEdge //Set the collision object (Should make this a list and use collision_circle_list)
	var raycastdistance = oCar.maxsensordistance*1.5; //Set the maximum distance the ray can cast to the maximum sensor distance(found manually for now) and a half(for good measure)
		for (var i = 0; i < raycastdistance; i += 1)
		{
			if !collision_circle(x + lengthdir_x(i, direction), y + lengthdir_y(i, direction), 2, colobject, true, false)
			{
				distance+=1
			}
			else
			{
				x1 = x + lengthdir_x(i, direction)
				y1 = y + lengthdir_y(i, direction)
				break;
			}
		}

		realdistance=point_distance(x, y, x1, y1) //Sets the distance of this sensor
}