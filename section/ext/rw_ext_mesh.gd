class_name RWExtMesh
extends RWSection

enum Flags {
	TRILIST = 0x0,
	TRISTRIP = 0x1,
	TRIFAN = 0x2,
	LINELIST = 0x4,
	POLYLINE = 0x8,
	POINTLIST = 0x10,
}

const SECTION_ID = 0x50e

var flags: Flags = Flags.TRILIST
var meshes: Array[Dictionary] = []


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	var flags: int = stream.get_u32()
	var num_meshes: int = stream.get_u32()
	var num_indices: int = stream.get_u32()
	
	# allocate meshes
	meshes.resize(num_meshes)
	
	for mesh in meshes:
		var num_mesh_indices: int = stream.get_u32()
		mesh["material_index"] = stream.get_u32()
		
		# allocate indices array
		var indices := PackedInt32Array()
		indices.resize(num_indices)
		
		# read indices array
		for i in num_mesh_indices:
			indices[i] = stream.get_u32()
		
		mesh["indices"] = indices
	
	return true
