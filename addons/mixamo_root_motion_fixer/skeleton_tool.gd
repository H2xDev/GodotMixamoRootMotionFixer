class_name MixamoSkeletonTool extends EditorContextMenuPlugin

var editor_plugin: EditorPlugin;

func _popup_menu(paths: PackedStringArray) -> void:
	var scene = editor_plugin.get_tree().edited_scene_root;
	if paths.size() > 1: return;
	
	var node = scene.get_node(paths[0]);
	if node is not Skeleton3D: return;

	add_context_menu_item("Add root bone", add_root_bone);

func add_root_bone(paths: Array):
	var node = paths[0];

	if node.find_bone("root_bone") != -1: return;
	node.add_bone("root_bone");
