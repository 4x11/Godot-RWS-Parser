class_name RWFrame
extends RWSection

var right := Vector3()
var up := Vector3()
var at := Vector3()
var position := Vector3()
var parent_index: int = -1
var geometry_index: int = -1
var extension_list: RWExtensionList = null


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	# read frame data
	right = stream.get_vector3()
	up = stream.get_vector3()
	at = stream.get_vector3()
	position = stream.get_vector3()
	parent_index = stream.get_32()
	stream.skip(4) # unused
	return true
