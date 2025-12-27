extends Node


func load_folder(path: String, file_extension: String) -> Array:
	var files: Array = []
	var loaded_files: Array = []
	files = _directory_contents(path, file_extension)
	for item in files:
		loaded_files.append(load(item))
	return loaded_files


func _directory_contents(directory: String, file_type: String) -> Array:
	var paths: Array = []
	var dir = DirAccess.open(directory)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if !file_name.ends_with(".import") and file_name.ends_with(file_type):
			paths.append(directory + "/" + file_name)
		
		file_name = dir.get_next()
	dir.list_dir_end()
	return paths
