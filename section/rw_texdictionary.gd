class_name RWTexDictionary
extends RWSection

var native_textures: Array[RWNativeTexture] = []
var extension_list: RWExtensionList = null


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	# read data section
	var data_header: Dictionary = stream.get_section_header()
	if data_header["type"] != RWSection.Type.DATA:
		return false
	
	var num_textures: int = stream.get_u16()
	stream.skip(2)
	
	# allocate native textures
	native_textures.resize(num_textures)
	
	for i in num_textures:
		var native_texture_header: Dictionary = stream.get_section_header()
		if(native_texture_header["type"] != RWSection.Type.TEXTURENATIVE):
			return false
		
		var native_texture := RWNativeTexture.new()
		if not native_texture._read(instance, self, stream, 
				native_texture_header["size"], native_texture_header["version"]):
			return false
		
		native_textures[i] = native_texture
	
	# read extension list section
	var extension_list_header: Dictionary = stream.get_section_header()
	if extension_list_header["type "] != RWSection.Type.EXTENSION_LIST:
		return false
	
	extension_list = RWExtensionList.new()
	if not extension_list._read(instance, self, stream,
			extension_list_header["size"], extension_list_header["version"]):
		return false
	
	return true
