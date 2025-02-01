class_name RWFrameList
extends RWSection

var frames: Array[RWFrame] = []


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	# read data section
	var data_header: Dictionary = stream.get_section_header()
	if data_header["type"] != RWSection.Type.DATA:
		return false
	
	var num_frames: int = stream.get_u32()
	frames.resize(num_frames)
	
	# read frames
	for i in num_frames:
		var frame := RWFrame.new()
		if not frame._read(instance, self, stream, -1, data_header["version"]):
			return false
		frames[i] = frame
	
	# read extension list section
	for frame in frames:
		var extension_list_header: Dictionary = stream.get_section_header()
		if extension_list_header["type"] != RWSection.Type.EXTENSION_LIST:
			return false
		
		var extension_list := RWExtensionList.new()
		if not extension_list._read(instance, frame, stream, 
				extension_list_header["size"], extension_list_header["version"]):
			return false
		
		frame.extension_list = extension_list
	
	return true
