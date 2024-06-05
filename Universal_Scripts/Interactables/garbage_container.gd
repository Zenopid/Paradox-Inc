class_name GarbageContainer extends MoveableObject

const GARBAGE_BAG_PATH:String = "uid://qdbmrdg5rvrr" 

func destroy():
	var bag_instance:MoveableObject = load(GARBAGE_BAG_PATH).instantiate()
	add_child(bag_instance)
	bag_instance.global_position = self.global_position
	bag_instance.set_timeline(current_timeline)
	queue_free()
