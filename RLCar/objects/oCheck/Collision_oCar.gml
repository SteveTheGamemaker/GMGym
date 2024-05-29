if activated = false && oCar.mySpeed > 0 //Only reward a checkpoint collected when going forward
{
	activated=true; //Set activated to true
	alarm[0]=100; //Set the deactivation alarm to 100
	mask_index = -1; //Set the collision mask to -1 so the car can't collect it again until it's deactivated
	other.checks+=1; //Increase the number of checkpoints the car has collected
}