class_name RWNativeTexture
extends RWSection

enum PlatformType {
	INVALID = 0,
	D3D8 = 8,
	D3D9 = 9,
}

enum RasterFormat {
	DEFAULT = 0x000,
	C1555 = 0x0100,
	C565 = 0x0200,
	C4444 = 0x0300,
	LUM8 = 0x0400,
	C8888 = 0x0500,
	C888 = 0x0600,
	D16 = 0x0700,
	D24 = 0x0800,
	D32 = 0x0900,
	C555 = 0x0A00,
	AUTOMIPMAP = 0x1000,
	PAL8 = 0x2000,
	PAL4 = 0x4000,
	MIPMAP = 0x8000
}

enum RasterType {
	NORMAL = 0,
	ZBUFFER = 1,
	CAMERA = 2,
	# 3 - unknown
	TEXTURE = 4,
	CAMERATEXTURE = 5,
}

enum DXTCompressionType {
	UNCOMPRESSED = 0,
	DXT1 = 1,
	DXT2 = 2,
	DXT3 = 3,
	DXT4 = 4,
	DXT5 = 5,
}

var name := String()
var mask_name := String()
var platform := PlatformType.INVALID
var filter_mode := RWTexture.FilterMode.INVALID
var addressing_u := RWTexture.Addressing.INVALID
var addressing_v := RWTexture.Addressing.INVALID
var raster_format := RasterFormat.DEFAULT
var raster_type := RasterType.NORMAL
var dxt_compression := DXTCompressionType.UNCOMPRESSED
var has_alpha: bool = false
var width: int = 0
var height: int = 0
var depth: int = 0
var palette := PackedColorArray()
var mipmaps: Array[PackedByteArray] = []
var extension_list: RWExtensionList = null


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	var data_header: Dictionary = stream.get_section_header()
	
	platform = stream.get_u32()
	
	var read_func := Callable()
	match platform:
		PlatformType.D3D8:
			read_func = Callable(self, "_read_d3d8")
		PlatformType.D3D9:
			read_func = Callable(self, "_read_d3d9")
	
	if not read_func.is_valid():
		return false
	
	if not read_func.call(instance, stream, size - 4, version):
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


func _read_d3d8(instance: RWInstance, stream: RWStream, size: int, version: int) -> bool:
	var filter_addressing = stream.get_u32()
	filter_mode = filter_addressing & 0xff
	addressing_u = (filter_addressing >> 8) & 0xf
	addressing_v = (filter_addressing >> 12) & 0xf
	
	name = stream.get_partial_data(32).get_string_from_ascii()
	mask_name = stream.get_partial_data(32).get_string_from_ascii()
	
	raster_format = stream.get_u32()
	has_alpha = stream.get_u32()
	width = stream.get_u16()
	height = stream.get_u16()
	depth = stream.get_u8()
	var num_mip_levels = stream.get_u8()
	raster_type = stream.get_u8()
	dxt_compression = stream.get_u8()
	
	# read palette colors
	
	if raster_format & RasterFormat.PAL4:
		palette.resize(32)
	elif raster_format & RasterFormat.PAL8:
		palette.resize(256)
	
	for color_idx in palette.size():
		palette[color_idx] = stream.get_color()
	
	# read mip-maps
	
	mipmaps.resize(num_mip_levels)
	
	for mip_level in mipmaps.size():
		var mip_size = stream.get_u32()
		mipmaps[mip_level] = stream.get_partial_data(mip_size)
	
	return true


func _read_d3d9(instance: RWInstance, stream: RWStream, size: int, version: int) -> bool:
	# TODO: implement '_read_d3d9' method
	return false
