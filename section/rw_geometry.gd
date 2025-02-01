class_name RWGeometry 
extends RWSection

enum Flags {
	TRISTRIP = 0x01,
	POSITIONS = 0x02,
	TEXTURED = 0x04,
	PRELIT = 0x08,
	NORMALS = 0x10,
	LIGHT = 0x20,
	MODULATE = 0x40,
	TEXTURED2 = 0x80
}

var flags: int = 0
var surface_properties: Dictionary = {}
var vertices: Array[Dictionary] = []
var triangles: Array[Dictionary] = []
var bounding_sphere: Dictionary = {}
var material_list : RWMaterialList = null
var extension_list: RWExtensionList = null


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	# read data section
	var data_header: Dictionary = stream.get_section_header()
	if data_header["type"] != RWSection.Type.DATA:
		return false
	
	flags = stream.get_u16()
	var num_texcoord_sets: int = stream.get_u8()
	stream.skip(1) # NATIVE flag ??
	var num_triangles: int = stream.get_u32()
	var num_vertices: int = stream.get_u32()
	var num_morph_targets: int = stream.get_u32()
	
	if num_texcoord_sets == 0:
		if flags & Flags.TEXTURED:
			num_texcoord_sets = 1
		elif flags & Flags.TEXTURED2:
			num_texcoord_sets = 2
	
	if version < 0x34000:
		surface_properties = stream.get_surface_properties()
	
	# allocate vertices
	vertices.resize(num_vertices)
	for i in vertices.size():
		vertices[i] = Dictionary()
	
	# allocate triangles
	triangles.resize(num_triangles)
	for i in triangles.size():
		triangles[i] = Dictionary()
	
	# init vertices uv's
		if num_texcoord_sets > 0:
			for vertex in vertices:
				var uvs := Array()
				uvs.resize(num_texcoord_sets)
				vertex["uvs"] = uvs
	
	# TODO: check 'NATIVE' flag
	
	# read vertices color's
	if (flags & Flags.PRELIT):
		for vertex in vertices:
			vertex["color"] = stream.get_rgba()
	
	# read vertices uv's
	for i in num_texcoord_sets:
		for vertex in vertices:
			vertex["uvs"][i] = stream.get_vector2()
	
	# read triangles
	for triangle in triangles:
		var indices := PackedInt32Array()
		indices.resize(3) # 3 indices per vertex
		indices[1] = stream.get_u16()
		indices[0] = stream.get_u16()
		triangle["material_index"] = stream.get_16()
		indices[2] = stream.get_u16()
		triangle["indices"] = indices
	
	# TODO: read multiple morph targets
	if num_morph_targets != 1:
		return false
	
	# read bounding sphere
	bounding_sphere["center"] = stream.get_vector3()
	bounding_sphere["radius"] = stream.get_float()
	
	var has_vertices: int = stream.get_u32()
	var has_normals: int = stream.get_u32()
	
	# read vertices
	if has_vertices:
		for vertex in vertices:
			vertex["position"] = stream.get_vector3()
	
	# read normals
	if has_normals:
		for vertex in vertices:
			vertex["normal"] = stream.get_vector3()
	
	# read material list section
	var material_list_header: Dictionary = stream.get_section_header()
	if material_list_header["type"] != RWSection.Type.MATLIST:
		return false
	
	material_list = RWMaterialList.new()
	if not material_list._read(instance, self, stream, 
			material_list_header["size"], material_list_header["version"]):
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
