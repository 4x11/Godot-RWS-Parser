class_name RWStream
extends RefCounted

var stream: StreamPeerBuffer = null


func open_from_file(file_path: String) -> bool:
	return open_from_memory(FileAccess.get_file_as_bytes(file_path))


func open_from_memory(data: PackedByteArray) -> bool:
	close()
	
	if data.is_empty():
		return false
	
	stream = StreamPeerBuffer.new()
	stream.set_data_array(data)
	return true


func close() -> void:
	stream = null


func is_open() -> bool:
	return stream != null


func skip(size: int) -> void:
	stream.seek(stream.get_position() + size)


func get_8() -> int:
	return stream.get_8()


func get_16() -> int:
	return stream.get_16()


func get_32() -> int:
	return stream.get_32()


func get_u8() -> int:
	return stream.get_u8()


func get_u16() -> int:
	return stream.get_u16()


func get_u32() -> int:
	return stream.get_u32()


func get_float() -> float:
	return stream.get_float()


func get_partial_data(size: int) -> PackedByteArray:
	var result = stream.get_partial_data(size)
	var data: PackedByteArray = result[1]
	return data


func get_section_header() -> Dictionary:
	var header = {}
	header["type"] = get_u32()
	header["size"] = get_u32()
	
	var libid = get_u32()
	header["version"] = RWStream._unpack_version(libid)
	header["build"] = RWStream._unpack_build(libid)
	return header


func get_vector2() -> Vector2:
	var vector2 := Vector2()
	vector2.x = get_float()
	vector2.y = get_float()
	return vector2


func get_vector3() -> Vector3:
	var vector3 := Vector3()
	vector3.x = get_float()
	vector3.y = get_float()
	vector3.z = get_float()
	return vector3


func get_color() -> Color:
	var color := Color()
	color.r8 = get_u8()
	color.g8 = get_u8()
	color.b8 = get_u8()
	color.a8 = get_u8()
	return color


func get_surface_properties() -> Dictionary:
	var surface_properties := Dictionary()
	surface_properties["ambient"] = get_float()
	surface_properties["specular"] = get_float()
	surface_properties["diffuse"] = get_float()
	return surface_properties


static func _unpack_version(libid: int) -> int:
	if (libid & 0xffff0000):
		return ((libid >> 14 & 0x3ff00) + 0x30000) | (libid >> 16 & 0x3f)
	else:
		return (libid << 8)


static func _unpack_build(libid: int) -> int:
	if (libid & 0xffff0000):
		return (libid & 0xffff)
	else:
		return 0
