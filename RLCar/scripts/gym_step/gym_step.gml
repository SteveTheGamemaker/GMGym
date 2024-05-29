//Call each objects update function in this part. Remember the step function for each object should be equivalent to a normal step event.
//The entire reason we need this is to easily keep sync with the environment,
//Because in gamemaker we do not have access to an internal "game.step()" type function.
//This also means that any processing of object variables that goes on behind the scenes(for Box2D physics, or things like vspeed and hspeed) can not easily be synced through this extension.

//This is game specific
function gym_step(){
	
	with(oCar){
		step();
	}
	
	with(oSensor){
		step();
	}
	
}