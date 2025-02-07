## This script is used to generate a root bone for animations imported from Mixamo.
## @author: Radik "H2x" Khamatdinov

@tool
class_name MixamoRootMotionTool
extends Node

@export()
var bone_to_track := "mixamorig_Hips";

@export()
var root_bone_name := "root_bone";

@export()
var skeleton_node := "Skeleton3D";

@export()
var animations: Array;

@export_category("Root bone weight settings")
@export()
var position_weight := Vector3(1, 0, 1);

@export()
var rotation_weight := Vector3.UP;

## If you have specific animations that require different weights, you can specify them here.
@export()
var specific_animation_weights: Array[MixamoRootWeightConfig];

@export_tool_button("Fix root motion")
var _regenerate_animations = regenerate_animations;

func regenerate_animations():
	for animlib in animations:
		regenerate_animlib(animlib);
	
	queue_free();

func regenerate_animlib(animation_library: AnimationLibrary):
	var anilist := animation_library.get_animation_list();

	for anim in anilist:
		var animation = convert_animation(animation_library.get_animation(anim));
		animation_library.remove_animation(anim);
		animation_library.add_animation(anim, animation);
	
	ResourceSaver.save(animation_library, animation_library.resource_path, ResourceSaver.FLAG_COMPRESS);

func get_weights_for_animation(animation_name: String) -> Array[Vector3]:
	for weight in specific_animation_weights:
		if weight.animation_name == animation_name:
			return [weight.position_weight, weight.rotation_weight];

	return [position_weight, rotation_weight] as Array[Vector3];

func convert_animation(animation: Animation):
	animation = animation.duplicate();
	var tracks := animation.get_track_count();

	var weights := get_weights_for_animation(animation.get_name());
	var pos_weight := weights[0];
	var rot_weight := weights[1];

	var ref_track_position := -1;
	var ref_track_rotation := -1;

	for track_idx in range(tracks):
		var path = str(animation.track_get_path(track_idx)).replace(skeleton_node + ":", "");

		if path == bone_to_track:
			if animation.track_get_type(track_idx) == Animation.TrackType.TYPE_POSITION_3D:
				ref_track_position = track_idx;
			if animation.track_get_type(track_idx) == Animation.TrackType.TYPE_ROTATION_3D:
				ref_track_rotation = track_idx;

	if ref_track_position == -1:
		push_error("Could not find bone to track");
		return;

	var position_track := animation.add_track(Animation.TrackType.TYPE_POSITION_3D);
	animation.track_set_path(position_track, NodePath(skeleton_node + ":" + root_bone_name));

	var corrected_track := animation.add_track(Animation.TrackType.TYPE_POSITION_3D);
	animation.track_set_path(corrected_track, NodePath(skeleton_node + ":" + bone_to_track));

	var keys_count := animation.track_get_key_count(ref_track_position);
	for key in range(keys_count):
		var key_value := animation.track_get_key_value(ref_track_position, key) as Vector3;
		var key_time := animation.track_get_key_time(ref_track_position, key);
		var target_value := key_value * pos_weight;
		var replace_value := key_value * (Vector3.ONE - pos_weight);

		animation.track_insert_key(position_track, key_time, target_value);
		animation.track_insert_key(corrected_track, key_time, replace_value);

	var rotation_track := animation.add_track(Animation.TrackType.TYPE_ROTATION_3D);
	animation.track_set_path(rotation_track, NodePath(skeleton_node + ":" + root_bone_name));

	var corrected_rotation_track := animation.add_track(Animation.TrackType.TYPE_ROTATION_3D);
	animation.track_set_path(corrected_rotation_track, NodePath(skeleton_node + ":" + bone_to_track));
	
	keys_count = animation.track_get_key_count(ref_track_rotation);
	for key in range(keys_count):
		var key_value := animation.track_get_key_value(ref_track_rotation, key) as Quaternion;
		var key_time := animation.track_get_key_time(ref_track_rotation, key);
		var euler_value = key_value.get_euler();
		var target_value := Quaternion.from_euler(euler_value * rot_weight);
		var replace_value := target_value.inverse() * key_value;

		animation.track_insert_key(rotation_track, key_time, target_value);
		animation.track_insert_key(corrected_rotation_track, key_time, replace_value);

	animation.remove_track(ref_track_position);
	animation.remove_track(ref_track_rotation - 1);

	return animation;
