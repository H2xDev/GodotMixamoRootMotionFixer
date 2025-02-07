# Mixamo Root Motion Fixer

## Installation

1. Copy `addons/mixamo_root_motion_fixer` into your project's folder.
2. Enable the plugin in the project settings.


## How to use
1. Download the animations from Mixamo.
2. Place the animations in a folder.
3. Select all exported FBX files and right-click -> Merge animations.  
It will create merged AnimationLibrary with all exported animations.  
From this point you can remove all exported animations. Leave only one as model source.

4. Select the AnimationLibrary file and right-click -> Fix root motion.  
It will create a tool in the current scene to fix root motion. Open the Inspector to see the tool's properties.  
Setup the weights you need and click "Fix root motion" button.  

5. Place the model on the scene and make it local. Right-click on Skeleton3D and click "Add root bone".
6. Add the converted AnimationLibrary into the AnimationPlayer.

That's it.

> [!IMPORTANT]
> The merged animation library that has converted via Root Motion Tool can't be converted again.  
> You need to remove it and recreate the merged animation library.
