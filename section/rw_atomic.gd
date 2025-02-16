class_name RWAtomic
extends RWSection

var frame_index: int = 0
var geometry_index: int = 0
var flags: int = 0
var extension_list: RWExtensionList = null


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	# read data section
	var data_header: Dictionary = stream.get_section_header()
	if data_header["type"] != RWSection.Type.DATA:
		return false
	
	frame_index = stream.get_u32()
	geometry_index = stream.get_u32()
	flags = stream.get_u32()
	
	if version >= 0x30400:
		stream.skip(4)
	
	# read extension list section
	var extension_list_header: Dictionary = stream.get_section_header()
	if extension_list_header["type"] != RWSection.Type.EXTENSION_LIST:
		return false
	
	extension_list = RWExtensionList.new()
	if not extension_list._read(instance, self, stream,
			extension_list_header["size"], extension_list_header["version"]):
		return false
	
	return true
