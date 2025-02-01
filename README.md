# Godot-RWS-Parser

A GDScript library for parsing **RenderWare Binary Stream (RWS)** files in **Godot 4**.
This project provides tools to read data from RenderWare binary stream formats which were used in many old popular games.

## Features

- **RWS File Parsing**: Read and decode RenderWare Binary Stream files.
- **GDScript Implementation**: Written entirely in GDScript for seamless integration with Godot 4.
- **Modular Design**: Easy to extend and adapt for specific use cases.

## Use Cases

- Game modding and asset extraction.
- Importing custom 3D models or assets into Godot.
- Research and analysis of RenderWare-based game files.

## Usage

Copy files to your Godot project and use the library in your code:

```gdscript
# Create an RWInstance
var rw_instance := RWInstance.new()

# Register necessary extensions
rw_instance.register_extension(RWInstance.ExtensionType.GEOMETRY, RWExtMesh.SECTION_ID, RWExtMesh)
# Register other extensions if needed
# rw_instance.register_extension(...)

# Create an RWStream and open the file
var dff_path := GTA3_PATH.path_join("models/Generic/arrow.DFF")
var stream := RWStream.new()
if not stream.open_from_file(dff_path):
    printerr("Failed to open RWS file: ", dff_path)
    return

# Read the section header and get its type
var header = stream.get_section_header()
if header["type"] != RWSection.Type.CLUMP:
    printerr("The RWS file is not a clump!")
    return

# Read the RWClump section
var clump := RWClump.new()
if not clump._read(rw_instance, null, stream, header["size"], header["version"]):
    printerr("Failed to read the RWS file!")
    return

# Now you can work with the parsed data
print("RWClump frames count: %d" % [clump.frame_list.frames.size()])
