class_name RWGeometryList
extends RWSection

var geometries: Array[RWGeometry] = []


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	# read data section
	var data_header: Dictionary = stream.get_section_header()
	if data_header["type"] != RWSection.Type.DATA:
		return false
	
	var num_geometries: int = stream.get_u32()
	
	# allocate geometries
	geometries.resize(num_geometries)
	
	# read geometry section's
	for i in num_geometries:
		var geometry_header: Dictionary = stream.get_section_header()
		
		var geometry := RWGeometry.new()
		if not geometry._read(instance, self, stream, 
				geometry_header["size"], geometry_header["version"]):
			return false
		
		geometries[i] = geometry
	
	return true
