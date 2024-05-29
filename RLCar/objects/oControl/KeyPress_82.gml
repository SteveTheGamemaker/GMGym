//Switch through reset modes so you can test your car from different positions
if resetmode="fixed"{
	resetmode="random";
}else if resetmode="random"{
	resetmode="randomnorepeat";
}else if resetmode="randomnorepeat"{
	resetmode="randomgeneral";
}else if resetmode="randomgeneral"{
	resetmode="optimize";
}else if resetmode="optimize"{
	resetmode="fixed";
}