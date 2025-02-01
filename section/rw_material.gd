class_name RWMaterial
extends RWSection

var surface_properties := Dictionary()
var color := Color()
var texture: RWTexture = null
var extension_list: RWExtensionList = null


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	# read data section
	var data_header: Dictionary = stream.get_section_header()
	if data_header["type"] != RWSection.Type.DATA:
		return false
	
	stream.skip(4)
	color = stream.get_color()
	stream.skip(4)
	var textured: bool = stream.get_u32()
	
	if version >= 0x30400:
		surface_properties = stream.get_surface_properties()
	
	# read texture section
	if textured:
		var texture_header: Dictionary = stream.get_section_header()
		if texture_header["type"] != RWSection.Type.TEXTURE:
			return false
		
		texture = RWTexture.new()
		if not texture._read(instance, self, stream, 
				texture_header["size"], texture_header["version"]):
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
