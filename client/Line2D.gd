extends Line2D

var start
var end
var mid


func _ready():
    var curve := Curve2D.new()
    start = points[0]
    end = points[1]
    mid = (end + start) / 2

    curve.add_point(start, Vector2(0, 0), Vector2(mid.x - start.x, 0))
    curve.add_point((end + start) / 2)
    curve.add_point(end, Vector2(mid.x - end.x, 0))
    points = curve.get_baked_points()


func _draw():
    draw_circle(start, 2, Color.AQUAMARINE)
    draw_circle(end, 2, Color.AQUAMARINE)

    draw_circle(start + Vector2(mid.x - start.x, 0), 2, Color.GREEN)
    draw_circle(end + Vector2(mid.x - end.x, 0), 2, Color.GREEN)
