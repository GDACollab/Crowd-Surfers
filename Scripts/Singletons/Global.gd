extends Node

#################################
#### DO NOT EDIT THIS SCRIPT ####
#################################

# Referencable via Global.current_scene
#     returns the current scene
var current_scene : PackedScene = null

# Referencable via Global.current_root
#     returns the current scene's root node
var current_root : Node = null

# Referencable via Global.FMOD
#     returns the Crowd Surfer's FMOD Project
#     once the fmod project is introduced into the filesystem
const FMOD = null ##TODO: reassign with FMOD Project access 

# Referencable via Global.current_inky
#     returns the current inky file
var current_inky = null

# Referencable via Global.save_path
#     will be altered for save/load functionality 
#     if we get there
const save_path : String = ""
