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
@export var width: float = 50.0:
	set(value):
		width = value
		_update_hitboxes()
# the length of the top sprite
@export var length: float = 50.0:
	set(value):
		length = value
		_update_hitboxes()
# the length of the front sprite 
@export var height: float = 50.0:
	set(value): 
		height = value
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
		
	# begins checking if existing and creating assets
	if (collect_all_assets()): 
		print("creationary stage")
		
		create_sprites()
		
		create_hitboxes()
	

# creates sprite, one for the front, top, and then one specifically for the platform
func create_sprites():
	if (texture_top):
		# Creates sprite
		var top_sprite = Sprite3D.new()
		
		# add children
		add_child(top_sprite)
		_set_owner(top_sprite)
		
		top_sprite.texture = texture_top
		top_sprite.name = "TopSprite"
		top_sprite.pixel_size = pixel_size
		top_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		top_sprite.axis = Vector3.AXIS_Y # lays flat
		top_sprite.rotation_degrees.y = 0 # rotates top_sprite
		
		# assign top and front vectors with sizes compensating for pixel size
		var text_top_w = texture_top.get_width()
		var text_top_h = texture_top.get_height()
		
		# conversion for sprite cutoff
		var h_convert_temp = float(text_top_h) - top_t_cutoff - top_b_cutoff
		var w_convert_temp = float(text_top_w) - top_l_cutoff - top_r_cutoff
		
		
		if procedure == 'complex box' or procedure == 'simple box':
			# assign sizes depending on prior equations
			top_sprite.scale.x = width / (w_convert_temp * pixel_size)
			top_sprite.scale.z = length / (h_convert_temp * pixel_size)
			
			if check_any_cutoff(top_t_cutoff, top_b_cutoff, top_l_cutoff, top_r_cutoff):
				top_sprite.region_enabled = true
				top_sprite.region_rect = rect_2_creation(w_convert_temp, h_convert_temp, top_t_cutoff, top_b_cutoff, top_l_cutoff, top_r_cutoff)
			
			
			# assign positions (because I did the math after the x and y were assigned)
			top_sprite.position = Vector3(0, height + offset_top_box, length / 2.0 + offset_top_side)
			print('added top')
			
		if procedure == 'slant box':
			var hypo = sqrt(pow(length, 2.0) + pow(height, 2.0))
			var ang_rad = atan2(length, height)
			top_sprite.rotation_degrees.x = (90 - rad_to_deg(ang_rad))
			print('anngle calc')
			
			# assign sizes depending on prior equations
			top_sprite.scale.x = width / (text_top_w * pixel_size)
			top_sprite.scale.z = hypo / (text_top_h * pixel_size)
			
			# assign positions (because I did the math after the x and y were assigned)
			top_sprite.position = Vector3(0, height / 2.0 + offset_top_box, length / 2.0 + offset_top_side)
			print('added top')
	
	
	if (texture_front):
		# Creates front sprite
		var front_sprite = Sprite3D.new()
		
		# add children
		add_child(front_sprite)
		_set_owner(front_sprite)
		
		front_sprite.texture = texture_front
		front_sprite.name = "FrontSprite"
		front_sprite.pixel_size = pixel_size
		front_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		front_sprite.axis = Vector3.AXIS_Y # lays flat
		front_sprite.rotation_degrees.x =  90 # rotates sprite forward down
		
		# assign top and front vectors with sizes compensating for pixel size
		var text_front_w = texture_front.get_width()
		var text_front_h = texture_front.get_height()
		
		# conversion for sprite cutoff
		var h_convert_temp = float(text_front_h) - front_t_cutoff - front_b_cutoff
		var w_convert_temp = float(text_front_w) - front_l_cutoff - front_r_cutoff
		
		if (procedure == 'complex box' or procedure == 'simple box'):
			# assign sizes depending on prior equations
			front_sprite.scale.x = width / (w_convert_temp * pixel_size)
			front_sprite.scale.z = height / (h_convert_temp * pixel_size)
			
			# assign positions (because I did the math after the x and y were assigned)
			front_sprite.position = Vector3(0, height / 2.0 + offset_front_side, length + offset_front_box)
			if check_any_cutoff(front_t_cutoff, front_b_cutoff, front_l_cutoff, front_r_cutoff):
				front_sprite.region_enabled = true
				front_sprite.region_rect = rect_2_creation(w_convert_temp, h_convert_temp, front_t_cutoff, front_b_cutoff, front_l_cutoff, front_r_cutoff)
			
			print('added front')
		if (procedure == 'side box'):
			# ratio for cutoff
			var ratio_top = art_z_cutoff
			var ratio_front = 1 - art_z_cutoff
			
			var crop_h_top = text_front_h * ratio_top
			var crop_h_front = text_front_h * ratio_front
			
			# creates a top sprite
			if (texture_front and art_z_cutoff > 0):
				# Creates sprite
				var top_sprite = Sprite3D.new()
				
				# add children
				add_child(top_sprite)
				_set_owner(top_sprite)
				
				top_sprite.texture = texture_front
				top_sprite.name = "TopSprite"
				top_sprite.pixel_size = pixel_size
				top_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
				top_sprite.axis = Vector3.AXIS_Y # lays flat
				top_sprite.rotation_degrees.y = 0 # rotates top_sprite
				
				# assign top and front vectors with sizes compensating for pixel size
				var text_top_w = texture_front.get_width()
				var text_top_h = texture_front.get_height()
			
				top_sprite.region_enabled = true
				top_sprite.region_rect = Rect2(0, 0, text_top_w, crop_h_top)
				
				# assigns position, relative to the front of the sprite
				top_sprite.position = Vector3(0, height, (length * ratio_front / 2.0) + length / 2.0)
				
				# assign sizes depending on prior equations
				top_sprite.scale.x = width / (text_top_w * pixel_size)
				top_sprite.scale.z = (length * ratio_top) / (crop_h_top * pixel_size)
				print('added top')
			
			
			front_sprite.region_enabled = true
			print(ratio_top)
			print(ratio_front)
	
			front_sprite.region_rect = Rect2(0, crop_h_top, text_front_w, crop_h_front)
			# assign sizes depending on prior equations
			front_sprite.scale.x = width / (text_front_w * pixel_size)
			front_sprite.scale.z = height / (crop_h_front * pixel_size)
			
			# assign position
			# assigns position, relative to the front of the sprite
			front_sprite.position = Vector3(0, height / 2.0, length)
			print('added front')


	print("added sprites")
	
	# extra sprites
	
	# creates the extra sprites
	if (procedure == 'complex box'):
		
		if (texture_left):
			# Creates left sprite
			var left_sprite = Sprite3D.new()
			
			# add children
			add_child(left_sprite)
			_set_owner(left_sprite)
			
			left_sprite.texture = texture_left
			left_sprite.name = "LeftSprite"
			left_sprite.pixel_size = pixel_size
			left_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
			left_sprite.axis = Vector3.AXIS_X # lays sideways
			left_sprite.rotation_degrees.y =  180
			
			var text_left_w = texture_left.get_width()
			var text_left_h = texture_left.get_height()
			
			# conversion for sprite cutoff
			var h_convert_temp = float(text_left_h) - left_t_cutoff - left_b_cutoff
			var w_convert_temp = float(text_left_w) - left_l_cutoff - left_r_cutoff
			
			left_sprite.scale.y = height / (h_convert_temp * pixel_size)
			left_sprite.scale.z = length / (w_convert_temp * pixel_size)
			
			left_sprite.position = Vector3(-width / 2.0 - offset_left_box, height / 2.0 + offset_left_side, length / 2.0)
			
			
			if check_any_cutoff(left_t_cutoff, left_b_cutoff, left_l_cutoff, left_r_cutoff):
				left_sprite.region_enabled = true
				left_sprite.region_rect = rect_2_creation(w_convert_temp, h_convert_temp, left_t_cutoff, left_b_cutoff, left_l_cutoff, left_r_cutoff)
			
			print('added left')
			
		if (texture_right):
			# Creates left sprite
			var right_sprite = Sprite3D.new()
			
			# add children
			add_child(right_sprite)
			_set_owner(right_sprite)
			
			right_sprite.texture = texture_right
			right_sprite.name = "RightSprite"
			right_sprite.pixel_size = pixel_size
			right_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
			right_sprite.axis = Vector3.AXIS_X # lays sideways
			right_sprite.rotation_degrees.x =  0
			
			var text_right_w = texture_right.get_width()
			var text_right_h = texture_right.get_height()
			
			# conversion for sprite cutoff
			var h_convert_temp = float(text_right_h) - right_t_cutoff - right_b_cutoff
			var w_convert_temp = float(text_right_w) - right_l_cutoff - right_r_cutoff
			
			right_sprite.scale.y = height / (h_convert_temp * pixel_size)
			right_sprite.scale.z = length / (w_convert_temp * pixel_size)
			right_sprite.position = Vector3(width / 2.0 + offset_right_box, height / 2.0 + offset_right_side, length / 2.0)
			
			if check_any_cutoff(right_t_cutoff, right_b_cutoff, right_l_cutoff, right_r_cutoff):
				right_sprite.region_enabled = true
				right_sprite.region_rect = rect_2_creation(w_convert_temp, h_convert_temp, right_t_cutoff, right_b_cutoff, right_l_cutoff, right_r_cutoff)
			
			
			print('added right')
			
		if (texture_back):
			# Creates left sprite
			var back_sprite = Sprite3D.new()
			
			# add children
			add_child(back_sprite)
			_set_owner(back_sprite)
			
			back_sprite.texture = texture_back
			back_sprite.name = "BackSprite"
			back_sprite.pixel_size = pixel_size
			back_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
			back_sprite.axis = Vector3.AXIS_Y # lays forward
			back_sprite.rotation_degrees.x =  90 
			
			var text_back_w = texture_back.get_width()
			var text_back_h = texture_back.get_height()
			
			# conversion for sprite cutoff
			var h_convert_temp = float(text_back_h) - back_t_cutoff - back_b_cutoff
			var w_convert_temp = float(text_back_w) - back_l_cutoff - back_r_cutoff
			
			back_sprite.scale.z = height / (h_convert_temp * pixel_size)
			back_sprite.scale.x = width / (w_convert_temp * pixel_size)
			back_sprite.position = Vector3(0, height / 2.0 + offset_back_side, -offset_back_box)
			
			if check_any_cutoff(back_t_cutoff, back_b_cutoff, back_l_cutoff, back_r_cutoff):
				back_sprite.region_enabled = true
				back_sprite.region_rect = rect_2_creation(w_convert_temp, h_convert_temp, back_t_cutoff, back_b_cutoff, back_r_cutoff, back_l_cutoff)
			
			
			print('added back')
			
		if (texture_bottom):
			# Creates left sprite
			var bottom_sprite = Sprite3D.new()
			
			# add children
			add_child(bottom_sprite)
			_set_owner(bottom_sprite)
			
			bottom_sprite.texture = texture_bottom
			bottom_sprite.name = "BottomSprite"
			bottom_sprite.pixel_size = pixel_size
			bottom_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
			bottom_sprite.axis = Vector3.AXIS_Y # lays flat
			bottom_sprite.rotation_degrees.x =  0
			
			var text_bottom_w = texture_bottom.get_width()
			var text_bottom_h = texture_bottom.get_height()
			
			# conversion for sprite cutoff
			var h_convert_temp = float(text_bottom_h) - bottom_t_cutoff - bottom_b_cutoff
			var w_convert_temp = float(text_bottom_w) - bottom_l_cutoff - bottom_r_cutoff
			
			bottom_sprite.scale.z = length / (h_convert_temp * pixel_size)
			bottom_sprite.scale.x = width / (w_convert_temp * pixel_size)
			bottom_sprite.position = Vector3(0, 0 + offset_bottom_box, length / 2.0 + offset_bottom_side)
			
			if check_any_cutoff(bottom_t_cutoff, bottom_b_cutoff, bottom_l_cutoff, bottom_r_cutoff):
				bottom_sprite.region_enabled = true
				bottom_sprite.region_rect = rect_2_creation(w_convert_temp, h_convert_temp, bottom_t_cutoff, bottom_b_cutoff, bottom_r_cutoff, bottom_l_cutoff)
			
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
	return t > 0.0 or b > 0.0 or l > 0.0 or r > 0.0
	
func rect_2_creation(w_conv, h_conv, t, b, l, r) -> Rect2:
	if (not t): t = 0.0
	if (not b): b = 0.0
	if (not l): l = 0.0
	if (not r): r = 0.0
	
	return Rect2(l, t, w_conv, h_conv)
