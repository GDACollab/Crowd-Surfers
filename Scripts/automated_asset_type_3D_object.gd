@tool
extends StaticBody3D

# WARNINGS:
# 1. The x size of the sprites or width, must be the same
# 2. Whenever I refer to top and front, with following letters, x, y, or z,
#    it means the length relative to that dimension
# 3. The top.z - front.z must not be less than front.z alone

@export var active: bool = false:
	set(value): 
		active = value
		
		# saftey check, to make sure we are in the edtior
		if is_inside_tree() and Engine.is_editor_hint():
			_update_hitboxes()
			
@export_group("File References")
@export var top_filename: Texture2D:
	set(value):
		top_filename = value
		_update_hitboxes()
@export var front_filename: Texture2D:
	set(value):
		front_filename = value
		_update_hitboxes()
@export var left_filename: Texture2D:
	set(value):
		left_filename = value
		_update_hitboxes()
@export var right_filename: Texture2D:
	set(value):
		right_filename = value
		_update_hitboxes()
@export var back_filename: Texture2D:
	set(value):
		back_filename = value
		_update_hitboxes()
@export var bottom_filename: Texture2D:
	set(value):
		bottom_filename = value
		_update_hitboxes()

@export_group("Dimensions")
# different variables to edit the dimensions
# the width of the overall sprite
@export var width: float = 10.0:
	set(value):
		width = value
		_update_hitboxes()
# the length of the top sprite
@export var length: float = 10.0:
	set(value):
		length = value
		_update_hitboxes()
# the length of the front sprite 
@export var height: float = 10.0:
	set(value): 
		height = value
		_update_hitboxes()
		
@export_group("Rotating & Flipping")
# different variables to rotate or flip (mirror) the sprite
@export_range(0, 360, 45) var top_rot: float = 0.0:
	set(value):
		top_rot = value
		_update_hitboxes()
@export_range(0, 360, 45) var top_flip: float = 0.0:
	set(value):
		top_flip = value
		_update_hitboxes()
@export_range(0, 360, 45) var front_rot: float = 0.0:
	set(value):
		front_rot = value
		_update_hitboxes()
@export_range(0, 360, 45) var front_flip: float = 0.0:
	set(value):
		front_flip = value
		_update_hitboxes()
@export_range(0, 360, 45) var left_rot: float = 0.0:
	set(value): 
		left_rot = value
		_update_hitboxes()
@export_range(0, 360, 45) var left_flip: float = 0.0:
	set(value): 
		left_flip = value
		_update_hitboxes()
@export_range(0, 360, 45) var right_rot: float = 0.0:
	set(value): 
		right_rot = value
		_update_hitboxes()
@export_range(0, 360, 45) var right_flip: float = 0.0:
	set(value): 
		right_flip = value
		_update_hitboxes()
@export_range(0, 360, 45) var back_rot: float = 0.0:
	set(value): 
		back_rot = value
		_update_hitboxes()
@export_range(0, 360, 45) var back_flip: float = 0.0:
	set(value): 
		back_flip = value
		_update_hitboxes()
@export_range(0, 360, 45) var bottom_rot: float = 0.0:
	set(value): 
		bottom_rot = value
		_update_hitboxes()
@export_range(0, 360, 45) var bottom_flip: float = 0.0:
	set(value): 
		bottom_flip = value
		_update_hitboxes()
		
@export_group("Padding")
@export_subgroup("Main")
# padding relative to the z-axis from above (incase hitbox needs to decrease in size)
@export var z_pad_main_top: float = 0.0:
	set(value): 
		z_pad_main_top = value
		_update_hitboxes()
# padding relative to the z-axis from below (incase hitbox needs to decrease in size)
@export var z_pad_main_bottom: float = 0.0:
	set(value): 
		z_pad_main_bottom = value
		_update_hitboxes()
# padding relative to the x-axis for main hitbox (incase hitbox needs to decrease in size)
@export var x_pad_main_left: float = 0.0:
	set(value): 
		x_pad_main_left = value
		_update_hitboxes()
# padding relative to the x-axis for main hitbox (incase hitbox needs to decrease in size)
@export var x_pad_main_right: float = 0.0:
	set(value): 
		x_pad_main_right = value
		_update_hitboxes()

@export_subgroup("Platform")
# padding relative to the z-axis from above (incase hitbox needs to decrease in size)
@export var z_pad_plat_top: float = 0.0:
	set(value): 
		z_pad_plat_top = value
		_update_hitboxes()
# padding relative to the z-axis from below (incase hitbox needs to decrease in size)
@export var z_pad_plat_bottom: float = 0.0:
	set(value): 
		z_pad_plat_bottom = value
		_update_hitboxes()
# padding relative to the x-axis for plat hitbox(incase hitbox needs to decrease in size)
@export var x_pad_plat_left: float = 0.0:
	set(value): 
		x_pad_plat_left = value
		_update_hitboxes()
# padding relative to the x-axis for plat hitbox(incase hitbox needs to decrease in size)
@export var x_pad_plat_right: float = 0.0:
	set(value): 
		x_pad_plat_right = value
		_update_hitboxes()
		
@export_subgroup("Top Sprite")
# padding to control top of sprite size
@export var top_spr_pad_top: float = 0.0:
	set(value): 
		top_spr_pad_top = value
		_update_hitboxes()
# padding to control bottom of sprite size
@export var top_spr_pad_bottom: float = 0.0:
	set(value): 
		top_spr_pad_bottom = value
		_update_hitboxes()
# padding to control left of sprite size
@export var top_spr_pad_left: float = 0.0:
	set(value): 
		top_spr_pad_left = value
		_update_hitboxes()
# padding to control right of sprite size
@export var top_spr_pad_right: float = 0.0:
	set(value): 
		top_spr_pad_right = value
		_update_hitboxes()
		
@export_subgroup("Front Sprite")
# padding to control top of sprite size
@export var front_spr_pad_top: float = 0.0:
	set(value): 
		front_spr_pad_top = value
		_update_hitboxes()
# padding to control bottom of sprite size
@export var front_spr_pad_bottom: float = 0.0:
	set(value): 
		front_spr_pad_bottom = value
		_update_hitboxes()
# padding to control left of sprite size
@export var front_spr_pad_left: float = 0.0:
	set(value): 
		front_spr_pad_left = value
		_update_hitboxes()
# padding to control right of sprite size
@export var front_spr_pad_right: float = 0.0:
	set(value): 
		front_spr_pad_right = value
		_update_hitboxes()
		
@export_subgroup("Left Sprite")
# padding to control top of sprite size
@export var left_spr_pad_top: float = 0.0:
	set(value): 
		left_spr_pad_top = value
		_update_hitboxes()
# padding to control bottom of sprite size
@export var left_spr_pad_bottom: float = 0.0:
	set(value): 
		left_spr_pad_bottom = value
		_update_hitboxes()
# padding to control left of sprite size
@export var left_spr_pad_left: float = 0.0:
	set(value): 
		left_spr_pad_left = value
		_update_hitboxes()
# padding to control right of sprite size
@export var left_spr_pad_right: float = 0.0:
	set(value): 
		left_spr_pad_right = value
		_update_hitboxes()

@export_subgroup("Right Sprite")
# padding to control top of sprite size
@export var right_spr_pad_top: float = 0.0:
	set(value): 
		right_spr_pad_top = value
		_update_hitboxes()
# padding to control bottom of sprite size
@export var right_spr_pad_bottom: float = 0.0:
	set(value): 
		right_spr_pad_bottom = value
		_update_hitboxes()
# padding to control left of sprite size
@export var right_spr_pad_left: float = 0.0:
	set(value): 
		right_spr_pad_left = value
		_update_hitboxes()
# padding to control right of sprite size
@export var right_spr_pad_right: float = 0.0:
	set(value): 
		right_spr_pad_right = value
		_update_hitboxes()
		
@export_subgroup("Back Sprite")
# padding to control top of sprite size
@export var back_spr_pad_top: float = 0.0:
	set(value): 
		back_spr_pad_top = value
		_update_hitboxes()
# padding to control bottom of sprite size
@export var back_spr_pad_bottom: float = 0.0:
	set(value): 
		back_spr_pad_bottom = value
		_update_hitboxes()
# padding to control left of sprite size
@export var back_spr_pad_left: float = 0.0:
	set(value): 
		back_spr_pad_left = value
		_update_hitboxes()
# padding to control right of sprite size
@export var back_spr_pad_right: float = 0.0:
	set(value): 
		back_spr_pad_right = value
		_update_hitboxes()
		
@export_subgroup("Bottom Sprite")
# padding to control top of sprite size
@export var bottom_spr_pad_top: float = 0.0:
	set(value): 
		bottom_spr_pad_top = value
		_update_hitboxes()
# padding to control bottom of sprite size
@export var bottom_spr_pad_bottom: float = 0.0:
	set(value): 
		bottom_spr_pad_bottom = value
		_update_hitboxes()
# padding to control left of sprite size
@export var bottom_spr_pad_left: float = 0.0:
	set(value): 
		bottom_spr_pad_left = value
		_update_hitboxes()
# padding to control right of sprite size
@export var bottom_spr_pad_right: float = 0.0:
	set(value): 
		bottom_spr_pad_right = value
		_update_hitboxes()
		
@export_group("Offsets")
# offset for the platform's z or influence on the main hitbox
@export var offset_plat: float = 0.0:
	set(value): 
		offset_plat = value
		_update_hitboxes()


# offset for the sprites texture relative to the hitbox distance or hitbox side
@export_subgroup("Top Offset in Relation to")
@export var offset_top_box: float = 0.0:
	set(value): 
		offset_top_box = value
		_update_hitboxes()
@export var offset_top_side: float = 0.0:
	set(value): 
		offset_top_side = value
		_update_hitboxes()

@export_subgroup("Front Offset in Relation to")
@export var offset_front_box: float = 0.0:
	set(value): 
		offset_front_box = value
		_update_hitboxes()
@export var offset_front_side: float = 0.0:
	set(value): 
		offset_front_side = value
		_update_hitboxes()

@export_subgroup("Left Offset in Relation to")
@export var offset_left_box: float = 0.0:
	set(value): 
		offset_left_box = value
		_update_hitboxes()
@export var offset_left_side: float = 0.0:
	set(value): 
		offset_left_side = value
		_update_hitboxes()

@export_subgroup("Right Offset in Relation to")
@export var offset_right_box: float = 0.0:
	set(value): 
		offset_right_box = value
		_update_hitboxes()
@export var offset_right_side: float = 0.0:
	set(value): 
		offset_right_side = value
		_update_hitboxes()

@export_subgroup("Back Offset in Relation to")
@export var offset_back_box: float = 0.0:
	set(value): 
		offset_back_box = value
		_update_hitboxes()
@export var offset_back_side: float = 0.0:
	set(value): 
		offset_back_side = value
		_update_hitboxes()

@export_subgroup("Bottom Offset in Relation to")
@export var offset_bottom_box: float = 0.0:
	set(value): 
		offset_bottom_box = value
		_update_hitboxes()
@export var offset_bottom_side: float = 0.0:
	set(value): 
		offset_bottom_side = value
		_update_hitboxes()

# how much to cut up on which side dictated
@export_group("Cutoff Sprites (Not below 0) (2+)")
# format: group
# subformat: (side of sprite, so top is top of sprite, how much sohuld be cutoff there)
# name_t_cutoff   (top)
# name_b_cutoff   (bottom)
# name_l_cutoff   (left)
# name_r_cutoff   (right)
@export_subgroup("Front Sprite")
@export var front_t_cutoff: float = 0.0:
	set(value): 
		front_t_cutoff = value
		_update_hitboxes()
@export var front_b_cutoff: float = 0.0:
	set(value): 
		front_b_cutoff = value
		_update_hitboxes()
@export var front_l_cutoff: float = 0.0:
	set(value): 
		front_l_cutoff = value
		_update_hitboxes()
@export var front_r_cutoff: float = 0.0:
	set(value): 
		front_r_cutoff = value
		_update_hitboxes()

@export_subgroup("Top Sprite")
@export var top_t_cutoff: float = 0.0:
	set(value): 
		top_t_cutoff = value
		_update_hitboxes()
@export var top_b_cutoff: float = 0.0:
	set(value): 
		top_b_cutoff = value
		_update_hitboxes()
@export var top_l_cutoff: float = 0.0:
	set(value): 
		top_l_cutoff = value
		_update_hitboxes()
@export var top_r_cutoff: float = 0.0:
	set(value): 
		top_r_cutoff = value
		_update_hitboxes()

@export_subgroup("Left Sprite")
@export var left_t_cutoff: float = 0.0:
	set(value): 
		left_t_cutoff = value
		_update_hitboxes()
@export var left_b_cutoff: float = 0.0:
	set(value): 
		left_b_cutoff = value
		_update_hitboxes()
@export var left_l_cutoff: float = 0.0:
	set(value): 
		left_l_cutoff = value
		_update_hitboxes()
@export var left_r_cutoff: float = 0.0:
	set(value): 
		left_r_cutoff = value
		_update_hitboxes()
		
@export_subgroup("Right Sprite")
@export var right_t_cutoff: float = 0.0:
	set(value): 
		right_t_cutoff = value
		_update_hitboxes()
@export var right_b_cutoff: float = 0.0:
	set(value): 
		right_b_cutoff = value
		_update_hitboxes()
@export var right_l_cutoff: float = 0.0:
	set(value): 
		right_l_cutoff = value
		_update_hitboxes()
@export var right_r_cutoff: float = 0.0:
	set(value): 
		right_r_cutoff = value
		_update_hitboxes()
		
@export_subgroup("Back Sprite")
@export var back_t_cutoff: float = 0.0:
	set(value): 
		back_t_cutoff = value
		_update_hitboxes()
@export var back_b_cutoff: float = 0.0:
	set(value): 
		back_b_cutoff = value
		_update_hitboxes()
@export var back_l_cutoff: float = 0.0:
	set(value): 
		back_l_cutoff = value
		_update_hitboxes()
@export var back_r_cutoff: float = 0.0:
	set(value): 
		back_r_cutoff = value
		_update_hitboxes()
		
@export_subgroup("Bottom Sprite")
@export var bottom_t_cutoff: float = 0.0:
	set(value): 
		bottom_t_cutoff = value
		_update_hitboxes()
@export var bottom_b_cutoff: float = 0.0:
	set(value): 
		bottom_b_cutoff = value
		_update_hitboxes()
@export var bottom_l_cutoff: float = 0.0:
	set(value): 
		bottom_l_cutoff = value
		_update_hitboxes()
@export var bottom_r_cutoff: float = 0.0:
	set(value): 
		bottom_r_cutoff = value
		_update_hitboxes()


@export_group("Cutoff (only for single sprites)")
# offset for the sprite's cutoff, to help art out
@export_range(0, 1, 0.0001) var art_z_cutoff: float = 0.0:
	set(value): 
		art_z_cutoff = value
		_update_hitboxes()

@export_group("Additional Settings")
@export_range(0, 1, 0.0001) var platform_thickness: float = 0.1: # thickness of the platform (since not decided by art asset)
	set(value): 
		platform_thickness = value
		_update_hitboxes()
var pixel_size = 0.01 # meters for pixel height (default: 0.01, maybe just never change this, it'll break everything)
# once again, you better not have changed pixel size

var main_hitbox_vec = Vector3(0, 0, 0)
var platform_hitbox_vec = Vector3(0, 0, 0)
# these are texture variables, they shall hold textures if they exist
var texture_top: Texture2D
var texture_front: Texture2D
var texture_left: Texture2D
var texture_right: Texture2D
var texture_back: Texture2D
var texture_bottom: Texture2D

# procedure currently in use
var procedure: String = 'none'
# complex box = 3 or more sides
# simple box = 2 sides
# slant box = top side only
# side box = front side only (of course offset allows for it to be moved in priority to top)

# ready function catches when someone just enters the edtior scene, turning off the editor
func _ready():
	if Engine.is_editor_hint():
		active = false

# updates hitboxes upon every small change
func _update_hitboxes():
	if (!active) or !is_inside_tree(): return
	# initially makes sure all previous versions are destroyed, careful this will reset everything you worked on
	cleanup_generated_nodes()
	
	print("procedure: ")
	print(procedure)
	
	# begins checking if existing and creating assets
	if (collect_all_assets()): 
		print("creationary stage")
		
		create_sprites()
		
		create_hitboxes()
	

# creates sprite3D, taking in variables for customization
# given_name = String
# texture = Texture2D
# give_rotation = Vector3
# given_position = Vector3
# returns: sprite3D, h_convert_temp, w_convert_temp
# usage: result["sprite"]
func create_sprite3D(given_name, texture, given_rot = Vector3(0, 0, 0), given_position = Vector3(0, 0, 0), given_axis = Vector3.AXIS_Y, t_cutoff = 0.0, b_cutoff = 0.0, l_cutoff = 0.0, r_cutoff = 0.0) -> Dictionary:
	# null check
	if (not t_cutoff): t_cutoff = 0.0
	if (not b_cutoff): b_cutoff = 0.0
	if (not l_cutoff): l_cutoff = 0.0
	if (not r_cutoff): r_cutoff = 0.0
	
	var sprite = Sprite3D.new()
	
	# add children
	add_child(sprite)
	_set_owner(sprite)
	
	sprite.texture = texture
	sprite.name = given_name
	sprite.pixel_size = pixel_size
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.axis = given_axis # lays flat on given axis
	sprite.rotation_degrees = given_rot # rotates sprite
	
	# assign top and front vectors with sizes compensating for pixel size
	var text_w = texture.get_width()
	var text_h = texture.get_height()
	
	# conversion for sprite cutoff
	var h_convert_temp = float(text_h) - t_cutoff - b_cutoff
	var w_convert_temp = float(text_w) - l_cutoff - r_cutoff
	
	# assign positions (because I did the math after the x and y were assigned)
	sprite.position = Vector3(given_position.x, given_position.y, given_position.z)
	
	return {
		"sprite": sprite,
		"text_w" : text_w,
		"text_h" : text_h,
		"h_conv": h_convert_temp,
		"w_conv": w_convert_temp
	}

# creates sprite, one for the front, top, and then one specifically for the platform
func create_sprites():
	if (texture_top):
		# Creates top sprite
		var sprite_info = create_sprite3D("TopSprite", texture_top, Vector3(top_flip, top_rot, 0), 
		Vector3((top_spr_pad_right - top_spr_pad_left)/2.0, height + offset_top_box, (length - top_spr_pad_top + top_spr_pad_bottom) / 2.0 + offset_top_side), # dedicated to position
		Vector3.AXIS_Y, top_t_cutoff, top_b_cutoff, top_l_cutoff, top_r_cutoff)
		var top_sprite = sprite_info["sprite"]
		
		if procedure == 'complex box' or procedure == 'simple box':
			# assign sizes depending on prior equations
			top_sprite.scale.x = (width + top_spr_pad_left + top_spr_pad_right) / (sprite_info["w_conv"] * pixel_size)
			top_sprite.scale.z = (length + top_spr_pad_bottom + top_spr_pad_top) / (sprite_info["h_conv"] * pixel_size)
			
			if check_any_cutoff(top_t_cutoff, top_b_cutoff, top_l_cutoff, top_r_cutoff):
				top_sprite.region_enabled = true
				top_sprite.region_rect = rect_2_creation(sprite_info["w_conv"], sprite_info["h_conv"], top_t_cutoff, top_b_cutoff, top_l_cutoff, top_r_cutoff)
			
			print('added top')
			
		if procedure == 'slant box':
			var ang_rad = atan2(length , height)
			var hypo = sqrt(pow(length + top_spr_pad_bottom * ang_rad + top_spr_pad_top * ang_rad, 2.0) + pow(height + top_spr_pad_bottom + top_spr_pad_top, 2.0))
			top_sprite.rotation_degrees.x = (90 - rad_to_deg(ang_rad))
			print('anngle calc')
			
			# assign sizes depending on prior equations
			top_sprite.scale.x = (width + top_spr_pad_left + top_spr_pad_right) / (sprite_info["text_w"] * pixel_size)
			top_sprite.scale.z = (hypo + top_spr_pad_bottom + top_spr_pad_top) / (sprite_info["text_h"] * pixel_size)
			
			# assign positions (because I did the math after the x and y were assigned)
			top_sprite.position = Vector3((top_spr_pad_right - top_spr_pad_left)/2.0, (height + top_spr_pad_top - top_spr_pad_bottom) /2.0 + offset_top_box, (length - top_spr_pad_top * (length/height) + top_spr_pad_bottom * (length/height)) / 2.0 + offset_top_side)
			print('added top')
	
	if (texture_front):
		# Creates front sprite
		var sprite_info = create_sprite3D("FrontSprite", texture_front, Vector3(90 + front_rot, -90 + front_flip, -90), 
		Vector3((front_spr_pad_right - front_spr_pad_left)/2.0, (height + front_spr_pad_top - front_spr_pad_bottom) / 2.0 + offset_front_side, length + offset_front_box), # dedicated to position
		Vector3.AXIS_Y, front_t_cutoff, front_b_cutoff, front_l_cutoff, front_r_cutoff)
		var front_sprite = sprite_info["sprite"]
		
		if (procedure == 'complex box' or procedure == 'simple box'):
			# assign sizes depending on prior equations
			front_sprite.scale.x = (width + front_spr_pad_left + front_spr_pad_right) / (sprite_info["w_conv"] * pixel_size)
			front_sprite.scale.z = (height + front_spr_pad_bottom + front_spr_pad_top) / (sprite_info["h_conv"] * pixel_size)
			
			if check_any_cutoff(front_t_cutoff, front_b_cutoff, front_l_cutoff, front_r_cutoff):
				front_sprite.region_enabled = true
				front_sprite.region_rect = rect_2_creation(sprite_info["w_conv"], sprite_info["h_conv"], front_t_cutoff, front_b_cutoff, front_l_cutoff, front_r_cutoff)
			
			print('added front')
		if (procedure == 'side box'):
			# ratio for cutoff
			var ratio_top = art_z_cutoff
			var ratio_front = 1 - art_z_cutoff
			
			var crop_h_top = sprite_info["h_conv"] * ratio_top
			var crop_h_front = sprite_info["h_conv"] * ratio_front
			
			# creates a top sprite
			if (texture_front and art_z_cutoff > 0):
				# Creates sprite
				var sprite_info_zcut = create_sprite3D("TopSprite", texture_front, Vector3(top_flip, top_rot, 0), 
				Vector3((top_spr_pad_right - top_spr_pad_left)/2.0, height + offset_top_box, (length * ratio_front) / 2.0 + offset_top_side + ((length - top_spr_pad_top + top_spr_pad_bottom) / 2.0)), # dedicated to position
		 		Vector3.AXIS_Y, top_t_cutoff, top_b_cutoff, top_l_cutoff, top_r_cutoff)
				
				var top_sprite = sprite_info_zcut["sprite"]
				
				top_sprite.region_enabled = true
				top_sprite.region_rect = Rect2(0, 0, sprite_info_zcut["text_w"], crop_h_top)
				
				# assign sizes depending on prior equations
				top_sprite.scale.x = (width + top_spr_pad_left + top_spr_pad_right) / (sprite_info_zcut["text_w"] * pixel_size)
				top_sprite.scale.z = ((length + top_spr_pad_bottom + top_spr_pad_top) * ratio_top) / (crop_h_top * pixel_size)
				print('added top')
			
			front_sprite.region_enabled = true
			print(ratio_top)
			print(ratio_front)
	
			front_sprite.region_rect = Rect2(0, crop_h_top, sprite_info["w_conv"], crop_h_front)
			# assign sizes depending on prior equations
			front_sprite.scale.x = (width + front_spr_pad_left + front_spr_pad_right) / (sprite_info["w_conv"] * pixel_size)
			front_sprite.scale.z = (height + front_spr_pad_bottom + front_spr_pad_top) / (crop_h_front * pixel_size)
			
			print('added front')
	
	
	print("added sprites")
	
	# extra sprites
	
	# creates the extra sprites
	if (procedure == 'complex box'):
		
		if (texture_left):
			# Creates left sprite
			var sprite_info = create_sprite3D("LeftSprite", texture_left, Vector3(left_rot, 180 + left_flip, 0), 
			Vector3((-width)/2.0 - offset_left_box, (height + left_spr_pad_top - left_spr_pad_bottom) / 2.0 + offset_left_side, (length + left_spr_pad_right - left_spr_pad_left) / 2.0), # dedicated to position
			Vector3.AXIS_X,  left_t_cutoff, left_b_cutoff, left_l_cutoff, left_r_cutoff)
			var left_sprite = sprite_info["sprite"]
			
			left_sprite.scale.z = (length + left_spr_pad_right + left_spr_pad_left) / (sprite_info["w_conv"] * pixel_size)
			left_sprite.scale.y = (height + left_spr_pad_top + left_spr_pad_bottom) / (sprite_info["h_conv"] * pixel_size)
			if check_any_cutoff(left_t_cutoff, left_b_cutoff, left_l_cutoff, left_r_cutoff):
				left_sprite.region_enabled = true
				left_sprite.region_rect = rect_2_creation(sprite_info["w_conv"], sprite_info["h_conv"], left_t_cutoff, left_b_cutoff, left_l_cutoff, left_r_cutoff)
			
			print('added left')
			
		if (texture_right):
			# Creates right sprite
			var sprite_info = create_sprite3D("RightSprite", texture_right, Vector3(right_rot, right_flip, 0), 
			Vector3((width)/2.0 + offset_right_box, (height + right_spr_pad_top - right_spr_pad_bottom) / 2.0 + offset_right_side, (length + right_spr_pad_left - right_spr_pad_right) / 2.0), # dedicated to position
			Vector3.AXIS_X,  right_t_cutoff, right_b_cutoff, right_l_cutoff, right_r_cutoff)
			var right_sprite = sprite_info["sprite"]
			
			right_sprite.scale.y = (height + right_spr_pad_top + right_spr_pad_bottom) / (sprite_info["h_conv"] * pixel_size)
			right_sprite.scale.z = (length + right_spr_pad_left + right_spr_pad_right) / (sprite_info["w_conv"] * pixel_size)
			
			if check_any_cutoff(right_t_cutoff, right_b_cutoff, right_l_cutoff, right_r_cutoff):
				right_sprite.region_enabled = true
				right_sprite.region_rect = rect_2_creation(sprite_info["w_conv"], sprite_info["h_conv"], right_t_cutoff, right_b_cutoff, right_l_cutoff, right_r_cutoff)
			
			
			print('added right')
			
		if (texture_back):
			# Creates back sprite
			var sprite_info = create_sprite3D("BackSprite", texture_back, Vector3(90 + back_rot, back_flip, 0), 
			Vector3((back_spr_pad_left - back_spr_pad_right)/2.0, (height + back_spr_pad_top - back_spr_pad_bottom) / 2.0 + offset_back_side, -offset_back_box ), # dedicated to position
			Vector3.AXIS_Y,  back_t_cutoff, back_b_cutoff, back_l_cutoff, back_r_cutoff)
			var back_sprite = sprite_info["sprite"]
			
			back_sprite.scale.z = (height + back_spr_pad_top + back_spr_pad_bottom) / (sprite_info["h_conv"] * pixel_size)
			back_sprite.scale.x = (width + back_spr_pad_left + back_spr_pad_right) / (sprite_info["w_conv"] * pixel_size)
			
			if check_any_cutoff(back_t_cutoff, back_b_cutoff, back_l_cutoff, back_r_cutoff):
				back_sprite.region_enabled = true
				back_sprite.region_rect = rect_2_creation(sprite_info["w_conv"], sprite_info["h_conv"], back_t_cutoff, back_b_cutoff, back_r_cutoff, back_l_cutoff)
			
			print('added back')
			
		if (texture_bottom):
			# Creates bottom sprite
			var sprite_info = create_sprite3D("BottomSprite", texture_bottom, Vector3(bottom_flip, bottom_rot, 0), 
			Vector3((-bottom_spr_pad_left + bottom_spr_pad_right)/2.0, offset_bottom_box, (length + bottom_spr_pad_top - bottom_spr_pad_bottom) / 2.0 -offset_bottom_side), # dedicated to position
			Vector3.AXIS_Y,  bottom_t_cutoff, bottom_b_cutoff, bottom_l_cutoff, bottom_r_cutoff)
			var bottom_sprite = sprite_info["sprite"]
			
			bottom_sprite.scale.z = (length + bottom_spr_pad_top + bottom_spr_pad_bottom) / (sprite_info["h_conv"] * pixel_size)
			bottom_sprite.scale.x = (width + bottom_spr_pad_left + bottom_spr_pad_right) / (sprite_info["w_conv"] * pixel_size)
			
			if check_any_cutoff(bottom_t_cutoff, bottom_b_cutoff, bottom_l_cutoff, bottom_r_cutoff):
				bottom_sprite.region_enabled = true
				bottom_sprite.region_rect = rect_2_creation(sprite_info["w_conv"], sprite_info["h_conv"], bottom_t_cutoff, bottom_b_cutoff, bottom_r_cutoff, bottom_l_cutoff)
			
			print('added bottom')
			
			

# Creates hitboxes for the main and platform, with customized padding, hopefully it works
func create_hitboxes():
	# platform thickness size
	var actual_thickness = platform_thickness * height
	
	# Creates the main hitbox (relies on top image)
	# first creates shape which collision will refer to
	var main_box_shape = BoxShape3D.new()
	main_box_shape.size = Vector3(width - x_pad_main_left - x_pad_main_right, height - actual_thickness, length - z_pad_main_top - z_pad_main_bottom) # might need to divide front length by 2
	
	# next, creates the main collision shape, with all those nice looks
	var main_collision = CollisionShape3D.new()
	
	add_child(main_collision)
	_set_owner(main_collision)
	
	main_collision.shape = main_box_shape
	main_collision.name = "MainHitbox"
	main_collision.debug_color = Color("#ff0000")
	main_collision.debug_color.a = 1.0
	main_collision.debug_fill = true
	main_collision.position = Vector3(x_pad_main_left / 2.0 - x_pad_main_right / 2.0, height / 2.0 - (actual_thickness / 2.0), length / 2.0 + z_pad_main_top/2.0 - z_pad_main_bottom/2.0)
	
	print("added main")
	
	if (platform_thickness > 0.0):
		# Creates the platform hitbox (relies on front image)
		# first creates shape which collision will refer to
		var plat_box_shape = BoxShape3D.new()
		plat_box_shape.size = Vector3(width - x_pad_plat_left - x_pad_plat_right, actual_thickness, length - z_pad_plat_top - z_pad_plat_bottom)
		
		# next, creates the platform collision shape, with all those nice looks
		var platform_collision = CollisionShape3D.new()
		
		add_child(platform_collision)
		_set_owner(platform_collision)
		
		platform_collision.shape = plat_box_shape
		platform_collision.name = "PlatformHitbox"
		platform_collision.debug_color = Color("f841ffff")
		platform_collision.debug_color.a = 1.0
		platform_collision.debug_fill = true
		platform_collision.position = Vector3(x_pad_plat_left / 2.0 - x_pad_plat_right / 2.0, height - (actual_thickness / 2.0), length / 2.0 + z_pad_plat_top/2.0 - z_pad_plat_bottom/2.0 + offset_plat)
		
		print("added platform")
	
	# extra optional
	
	

# might switch to getting them within, but for streamlining purposes, lets make it quicker
# type in in the top name or front name the assets you want, it will get them
# example: "AlphaSprites/Bus 1 Down S3.png"
func collect_all_assets() -> bool:
	var dir = DirAccess.open("res://Assets/Art")
	print('completed directory open')
	if dir:
		texture_top = top_filename
		texture_front = front_filename
		texture_left = left_filename
		texture_right = right_filename
		texture_back = back_filename
		texture_bottom = bottom_filename
		
		# excludes front and top
		var textures = [ texture_left, texture_right, texture_back, texture_bottom ]
		
		# context again
		# complex box = 3 or more sides
		# simple box = 2 sides
		# slant box = top side only
		# side box = front side only
	
		
		print('completed getting files')
		
		if texture_top and texture_front and textures.any(func(v): return v):
			print('completed verification complex')
			procedure = 'complex box'
			
			return true
		if texture_front and texture_top:
			print('completed verification simple')
			procedure = 'simple box'
			
			return true
		if texture_top:
			print('completed verification slant')
			procedure = 'slant box'
			
			return true
		if texture_front:
			print('completed verification side')
			procedure = 'side box'
			
			return true
	return false
	
# sets the owner of the current node, to make sure the node appears in the scene
func _set_owner(node):
	if get_tree():
		if (Engine.is_editor_hint() and is_inside_tree()):
			var root = get_tree().edited_scene_root
			if root:
				node.owner = root
				
# cleanup "nuclear" process
func cleanup_generated_nodes():
	# finds all nodes in the scene with a tag to delete it
	var children = get_children()
	
	# list of potentially named sprites
	var list_names = ["TopSprite", "FrontSprite", "LeftSprite", "RightSprite", "BackSprite", "BottomSprite", "PlatSprite", "MainHitbox", "PlatformHitbox"]

	# iterates through, double checking to make sure it doesn't accidentally delete something
	for child in children:
		if list_names.any(func(prefix): return child.name.begins_with(prefix)):
			child.free() # frees for instant removal in tool script
			
func check_any_cutoff(t, b, l, r) -> bool:
	# null check
	if (not t): t = 0.0
	if (not b): b = 0.0
	if (not l): l = 0.0
	if (not r): r = 0.0
	
	return t > 0.0 or b > 0.0 or l > 0.0 or r > 0.0
	
func rect_2_creation(w_conv, h_conv, t, b, l, r) -> Rect2:
	# null check
	if (not t): t = 0.0
	if (not b): b = 0.0
	if (not l): l = 0.0
	if (not r): r = 0.0
	
	return Rect2(l, t, w_conv, h_conv)
