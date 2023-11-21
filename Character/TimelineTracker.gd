extends Label
 
func init(player: Player):
	var level = player.get_level()
	level.connect("swapped_timeline", Callable(self, "timeline_text"))
	
func timeline_text(new_text):
	text = new_text
	
