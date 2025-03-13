class_name RWExtensionList
extends RWSection

var extensions: Dictionary = {}


func _read(instance: RWInstance, parent: RWSection, stream: RWStream, 
		size: int, version: int) -> bool:
	# get extension type
	var extension_type: RWInstance.ExtensionType
	if parent is RWClump:
		extension_type = RWInstance.ExtensionType.CLUMP
	elif parent is RWFrame:
		extension_type = RWInstance.ExtensionType.FRAME
	elif parent is RWGeometry:
		extension_type = RWInstance.ExtensionType.GEOMETRY
	elif parent is RWMaterial:
		extension_type = RWInstance.ExtensionType.MATERIAL
	elif parent is RWTexture:
		extension_type = RWInstance.ExtensionType.TEXTURE
	elif parent is RWAtomic:
		extension_type = RWInstance.ExtensionType.ATOMIC
	elif parent is RWNativeTexture:
		extension_type = RWInstance.ExtensionType.NATIVE_TEXTURE
	elif parent is RWTexDictionary:
		extension_type = RWInstance.ExtensionType.TEXTURE_DICTIONARY
	else:
		return false
	
	var read_bytes: int = 0
	while read_bytes < size:
		# read header
		var extension_header = stream.get_section_header()
		read_bytes += 12
		
		# read extension
		var extension: RWSection = instance.get_extension(extension_type, extension_header["type"])
		if extension != null:
			if not extension._read(instance, parent, stream, 
					extension_header["size"], extension_header["version"]):
				return false
			extensions[extension_header['type']] = extension
		else:
			stream.skip(extension_header["size"])
		
		read_bytes += extension_header["size"]
	
	return true


func get_extension(id: int) -> RWSection:
	return extensions.get(id)
