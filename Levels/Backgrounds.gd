extends ParallaxBackground

var player:Player
var level: GenericLevel

@onready var past_background:ParallaxLayer = $PastBackground
@onready var future_background:ParallaxLayer = $FutureBackground

@export var tween_duration: float = 0.1
var tween: Tween

func init(entity: Player):
	tween = get_tree().create_tween()
	player = entity
	level = player.get_level()
	get_viewport().connect("size_changed", Callable(self, "resize_backgrounds"))
	swap_view(level.current_timeline)
	level.connect("swapped_timeline", Callable(self, "swap_view"))

func resize_backgrounds():
	for nodes in get_children():
		if nodes is ParallaxLayer:
			nodes.motion_mirroring.x = get_viewport().get_visible_rect().size.x

func swap_view(timeline):
	if tween.is_running():
		tween.kill()
	tween = get_tree().create_tween()
	if timeline == "Future":
		past_background.modulate.a = 0
		tween.tween_property(future_background,"modulate:a", 1, tween_duration)
	else:
		future_background.modulate.a = 0
		tween.tween_property(past_background, "modulate:a", 1, tween_duration)
