extends ParallaxBackground

var player:Player
var level: GenericLevel

func init(entity: Player):
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
	get_node(str(timeline) + "Background").visible = true
	get_node(level.get_next_timeline_swap() + "Background").visible = false
