class_name RWTexture
extends RWSection

enum FilterMode {
	INVALID = 0,
	NEAREST = 1,
	LINEAR = 2,
	MIPNEAREST = 3,
	MIPLINEAR = 4,
	LINEARMIPNEAREST = 5,
	LINEARMIPLINEAR = 6,
}

enum Addressing {
	INVALID = 0,
	WRAP = 1,
	MIRROR = 2,
	CLAMP = 3,
	BORDER = 4,
}

var filter_mode := FilterMode.INVALID
var addressing_u := Addressing.INVALID
var addressing_v := Addressing.INVALID

var name: String = ""
var mask_name: String = ""
var extension_list: RWExtensionList = null


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	# read data section
	var data_header: Dictionary = stream.get_section_header()
	if data_header["type"] != RWSection.Type.DATA:
		return false
	
	var filter_addressing: int = stream.get_u32()
	# if V addressing is 0, copy U
	if (filter_addressing & 0xf000) == 0:
		filter_addressing |= (filter_addressing & 0xf00) << 4
	# unpack filter mode & addressing
	filter_mode = filter_addressing & 0xff
	addressing_u = (filter_addressing >> 8) & 0xf
	addressing_v = (filter_addressing >> 12) & 0xf
	
	var string_header: Dictionary = {}
	
	# read name
	string_header = stream.get_section_header()
	if string_header["type"] != RWSection.Type.STRING:
		return false
	
	name = stream.get_partial_data(string_header["size"]).get_string_from_ascii()
	
	# read mask
	string_header = stream.get_section_header()
	if string_header["type"] != RWSection.Type.STRING:
		return false
	
	mask_name = stream.get_partial_data(string_header["size"]).get_string_from_ascii()
	
	# read extension list
	var extension_list_header: Dictionary = stream.get_section_header()
	if extension_list_header["type"] != RWSection.Type.EXTENSION_LIST:
		return false
	
	extension_list = RWExtensionList.new()
	if not extension_list._read(instance, self, stream, 
			extension_list_header["size"], extension_list_header["version"]):
		return false
	
	return true
