@tool
class_name MixamoRootMotionConverter extends EditorPlugin

var merge_tool: MixamoMergeTool = null;
var skeleton_tool: MixamoSkeletonTool = null;

func _enter_tree():
	merge_tool = MixamoMergeTool.new();
	merge_tool.editor_plugin = self;

	skeleton_tool = MixamoSkeletonTool.new();
	skeleton_tool.editor_plugin = self;

	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, merge_tool);
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, skeleton_tool);

func _exit_tree():
	remove_context_menu_plugin(merge_tool);
	remove_context_menu_plugin(skeleton_tool);
	merge_tool = null;
	skeleton_tool = null;
