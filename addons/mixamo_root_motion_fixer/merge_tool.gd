class_name MixamoMergeTool extends EditorContextMenuPlugin

var editor_plugin: EditorPlugin;

func _popup_menu(paths: PackedStringArray):
	var has_animations = Array(paths).filter(func(p):return p.ends_with(".mixamo.tres")).size() > 0;
	var has_fbx = Array(paths).filter(func(p):return p.ends_with(".fbx")).size() > 0;

	if has_animations:
		add_context_menu_item("Fix root motion", open_root_motion_tool)

	if has_fbx: 
		add_context_menu_item("Merge animations", convert)
		return

func open_root_motion_tool(paths: PackedStringArray):
	var scene = editor_plugin.get_tree().edited_scene_root;

	var animations := Array(paths).filter(func(p):return p.ends_with(".mixamo.tres"));

	var root_motion_tool := MixamoRootMotionTool.new() \
		if not scene.has_node("RootMotionTool") \
		else scene.get_node("RootMotionTool");

	var libs := animations.map(func(p): return load(p) as AnimationLibrary);

	root_motion_tool.animations = libs;
	root_motion_tool.name = "RootMotionTool";

	scene.add_child(root_motion_tool);
	root_motion_tool.set_owner(scene);
	editor_plugin.get_editor_interface().edit_node(root_motion_tool);

func convert(paths: PackedStringArray):
	var fbxs = Array(paths).filter(func(p): return p.ends_with(".fbx"));

	var animations = AnimationLibrary.new();

	for fbx in fbxs:
		var ps := load(fbx) as PackedScene;
		var node := ps.instantiate();
		var animator := node.get_node_or_null("AnimationPlayer") as AnimationPlayer;
		var target_anim_name = fbx.get_file().get_basename();

		if animator == null: continue;

		for lib_name in animator.get_animation_library_list():
			var lib := animator.get_animation_library(lib_name);

			for anim_name in lib.get_animation_list():
				var anim = lib.get_animation(anim_name);
				animations.add_animation(target_anim_name, anim);

		node.free();

	var save_path = fbxs[0].get_base_dir() + "/" + fbxs[0].get_file().get_basename() + ".mixamo.tres";

	ResourceSaver.save(animations, save_path, ResourceSaver.FLAG_COMPRESS);
