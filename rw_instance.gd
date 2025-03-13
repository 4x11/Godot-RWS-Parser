class_name RWInstance
extends RefCounted

enum ExtensionType {
	CLUMP = 0,
	FRAME = 1,
	GEOMETRY = 2,
	MATERIAL = 3,
	TEXTURE = 4,
	ATOMIC = 5,
	NATIVE_TEXTURE = 6,
	TEXTURE_DICTIONARY = 7,
}

var extensions: Array[Dictionary] = []


func _init():
	extensions.resize(ExtensionType.size())


func register_extension(type: ExtensionType, id: int, extension_class: Object) -> bool:
	# TODO: validate extension_class
	extensions[type][id] = extension_class
	return true


func unregister_extension(type: ExtensionType, id: int) -> bool:
	return extensions[type].erase(id)


func get_extension(type: ExtensionType, id: int) -> RWSection:
	var extension_class: Object = extensions[type].get(id, null)
	if extension_class == null:
		return null
	
	return extension_class.new()
