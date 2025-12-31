extends Node


func load_folder(path: String, file_extension: String) -> Array:
	var files: Array = []
	var loaded_files: Array = []
	files = _directory_contents(path, file_extension)
	for item in files:
		loaded_files.append(load(item))
	return loaded_files

func _directory_contents(directory: String, file_type: String) -> Array:
	var desired_files: Array
	for file in ResourceLoader.list_directory(directory):
		if file.ends_with(file_type):
			desired_files.append(directory + "/" + file)
	return desired_files

#func _directory_contents(directory: String, file_type: String) -> Array:
	#var paths: Array = []
	#var dir = DirAccess.open(directory)
	#dir.list_dir_begin()
	#var file_name = dir.get_next()
	#while file_name != "":
		#var file_type_change = file_name
		#if file_name.get_extension() == "remap":
			#file_type_change = file_name.replace(".remap", "")
		#if !file_type_change.ends_with(".import") and file_type_change.ends_with(file_type):
			#paths.append(directory + "/" + file_type_change)
		#file_name = dir.get_next()
	#dir.list_dir_end()
	#return paths
