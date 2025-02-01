class_name RWClump
extends RWSection

var frame_list: RWFrameList = null
var geometry_list: RWGeometryList = null
var atomics: Array[RWAtomic] = []
var extension_list: RWExtensionList = null


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	# read data section
	var data_header: Dictionary = stream.get_section_header()
	if data_header["type"] != RWSection.Type.DATA:
		return false
	
	var num_atomics: int = stream.get_u32()
	var num_lights: int = 0
	var num_cameras: int = 0
	
	if version > 0x33000:
		num_lights = stream.get_u32()
		num_cameras = stream.get_u32()
	
	# allocate
	atomics.resize(num_atomics)
	
	# read frame list section
	var frame_list_header: Dictionary = stream.get_section_header()
	if frame_list_header["type"] != RWSection.Type.FRAMELIST:
		return false
	
	frame_list = RWFrameList.new()
	if not frame_list._read(instance, self, stream,
			frame_list_header["size"], frame_list_header["version"]):
		return false
	
	# read geometry list section
	var geometry_list_header: Dictionary = stream.get_section_header()
	if geometry_list_header["type"] != RWSection.Type.GEOMETRYLIST:
		return false
	
	geometry_list = RWGeometryList.new()
	if not geometry_list._read(instance, self, stream,
			geometry_list_header["size"], geometry_list_header["version"]):
		return false

	# read atomic sections
	for i in num_atomics:
		var atomic_header: Dictionary = stream.get_section_header()
		if atomic_header["type"] != RWSection.Type.ATOMIC:
			return false
		
		var atomic := RWAtomic.new()
		if not atomic._read(instance, self, stream,
				atomic_header["size"], atomic_header["version"]):
			return false
		
		atomics[i] = atomic
	
	# TODO: read lights
	if num_lights > 0:
		return false
	
	# TODO: read cameras
	if num_cameras > 0:
		return false
	
	# read extension list section
	var extension_list_header: Dictionary = stream.get_section_header()
	if extension_list_header["type"] != RWSection.Type.EXTENSION_LIST:
		return false
	
	extension_list = RWExtensionList.new()
	if not extension_list._read(instance, self, stream,
			extension_list_header["size"], extension_list_header["version"]):
		return false
	
	return true
