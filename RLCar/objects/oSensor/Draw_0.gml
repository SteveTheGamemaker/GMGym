if oGym.observationtype = "Numeric" && visible = true //Only draw the sensors in a numeric observation space so that they dont clutter the agents vision in the visual observation space
{
draw_circle(x, y, 2, false)
draw_line(x, y, x1, y1)
draw_circle(x1, y1, 2, false)
}