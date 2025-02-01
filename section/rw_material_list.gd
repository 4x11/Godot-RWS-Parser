class_name RWMaterialList
extends RWSection

# material or material index
var materials: Array = []


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	# read data section
	var data_header = stream.get_section_header()
	if data_header["type"] != RWSection.Type.DATA:
		return false
	
	var num_materials = stream.get_u32()
	# nothing to read - just return
	if num_materials == 0:
		return true
	
	# allocate materials
	materials.resize(num_materials)
	
	# read material indices
	var material_indices := Array()
	material_indices.resize(num_materials)
	for i in num_materials:
		material_indices[i] = stream.get_32()
	
	# read materials
	for i in materials.size():
		if material_indices[i] >= 0:
			materials[i] = material_indices[i]
		else:
			var material_header: Dictionary = stream.get_section_header()
			if material_header["type"] != RWSection.Type.MATERIAL:
				return false
			
			var material := RWMaterial.new()
			if not material._read(instance, self, stream, 
					material_header["size"], material_header["version"]):
				return false
			
			materials[i] = material
	
	return true
