class_name RWSection
extends RefCounted

enum Type {
	DATA = 1,
	STRING = 2,
	EXTENSION_LIST = 3,
	TEXTURE = 6,
	MATERIAL = 7,
	MATLIST = 8,
	FRAMELIST = 14,
	GEOMETRY = 15,
	CLUMP = 16,
	LIGHT = 18,
	ATOMIC = 20,
	TEXTURENATIVE = 21,
	TEXDICTIONARY = 22,
	GEOMETRYLIST = 26,
}

func _read(instance: RWInstance, parent: RWSection, stream: RWStream, size: int, version: int) -> bool:
	return false
