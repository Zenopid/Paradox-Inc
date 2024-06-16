class_name GarbageContainer extends MoveableObject

const GARBAGE_BAG_PATH:String = "uid://qdbmrdg5rvrr" 
@export var bag_spawn_count:int = 3
func kill():
	for bags in bag_spawn_count:
		var bag_instance:MoveableObject = load(GARBAGE_BAG_PATH).instantiate()
		get_tree().get_first_node_in_group("CurrentLevel").call_deferred("add_child", bag_instance)
		bag_instance.global_position = self.global_position
		bag_instance.set_timeline(current_timeline)
	queue_free()
