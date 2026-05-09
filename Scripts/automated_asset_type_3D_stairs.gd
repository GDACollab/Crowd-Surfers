@tool
extends StaticBody3D

@export var active: bool = false:
	set(value): 
		active = value
		
		# saftey check, to make sure we are in the edtior
		if is_inside_tree() and Engine.is_editor_hint():
			_update_hitboxes()
			
@export_group("File References")
@export var stairs_filename: Texture2D:
	set(value):
		stairs_filename = value
		_update_hitboxes()
@export var platform_filename: Texture2D:
	set(value):
		platform_filename = value
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

@export_group("Dimensions")
# different variables to edit the dimensions
# the width of the overall sprite/hitbox
@export var width: float = 10.0:
	set(value):
		width = value
		_update_hitboxes()
# the length of the overall sprite/hitbox
@export var length: float = 10.0:
	set(value):
		length = value
		_update_hitboxes()
# the length of the platform sprite/hitbox
@export_range(0, 1, 0.0001) var stairs_ratio: float = 1.0:
	set(value):
		stairs_ratio = value
		_update_hitboxes()
# the height of the overall sprite/hitbox
@export var height: float = 10.0:
	set(value): 
		height = value
		_update_hitboxes()
# the number of steps if applicable (0 = not a ramp)
@export var steps: float = 10:
	set(value): 
		steps = value
		_update_hitboxes()
# the split from the stairs (sprite/hitbox) and the top of the overall sprite, used for railings
@export_range(0, 1, 0.0001) var stairs_offset: float = 1.0:
	set(value): 
		stairs_offset = value
		_update_hitboxes()
# railngs toggle
@export var railings: bool = true:
	set(value): 
		railings = value
		_update_hitboxes()
# railings height
@export var railings_height: float = 0.0:
	set(value): 
		railings_height = value
		_update_hitboxes()
@export var platform_thickness: float = 0.1: # thickness of the platform (since not decided by art asset)
	set(value): 
		platform_thickness = value
		_update_hitboxes()
		
@export_group("Padding")
		
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
		

# how much to cut up on which side dictated
@export_group("Cutoff Sprites (if existing)")
# format: group
# subformat: (side of sprite, so top is top of sprite, how much sohuld be cutoff there)
# name_t_cutoff   (top)
# name_b_cutoff   (bottom)
# name_l_cutoff   (left)
# name_r_cutoff   (right)

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


var pixel_size = 0.01 # meters for pixel height (default: 0.01, maybe just never change this, it'll break everything)
# once again, you better not have changed pixel size

var main_hitbox_vec = Vector3(0, 0, 0)
var platform_hitbox_vec = Vector3(0, 0, 0)
# these are texture variables, they shall hold textures if they exist
var texture_stairs: Texture2D
var texture_platform: Texture2D
var texture_left: Texture2D
var texture_right: Texture2D
var texture_back: Texture2D

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
	#print('called')
	if (!active) or !is_inside_tree(): return
	# initially makes sure all previous versions are destroyed, careful this will reset everything you worked on
	cleanup_generated_nodes()
	
	# begins checking if existing and creating assets
	if (collect_all_assets()): 
		#print("creationary stage")
		
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
	sprite.shaded = true
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
	
func create_mesh3D(given_name, texture_top, given_rot = Vector3(0, 0, 0), given_position = Vector3(0, 0, 0), given_axis = Vector3.AXIS_Y, t_cutoff = 0.0, b_cutoff = 0.0, l_cutoff = 0.0, r_cutoff = 0.0) -> Dictionary:
	# null check
	if (not t_cutoff): t_cutoff = 0.0
	if (not b_cutoff): b_cutoff = 0.0
	if (not l_cutoff): l_cutoff = 0.0
	if (not r_cutoff): r_cutoff = 0.0
	
	var mesh = CSGPolygon3D.new()
	
	# add children
	add_child(mesh)
	_set_owner(mesh)
	
	mesh.mode = CSGPolygon3D.MODE_DEPTH
	mesh.depth = width
	mesh.name = given_name
	mesh.rotation_degrees = given_rot # rotates mesh
	mesh.position = given_position
	
	# material
	var mat = StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.albedo_texture = texture_top
	mat.uv1_triplanar = false
	mat.uv1_world_triplanar = false
	mat.texture_repeat = true
	mesh.material = mat
	
	# points
	var step_height = (height * stairs_offset) / steps
	var step_length = (length * stairs_ratio) / steps
	var steps_distance = steps * (step_height + step_length)
	var points = PackedVector2Array()
	
	# mat scalars for uv1 and uv2 (mind need to consider pixel size)
	mat.uv1_scale = Vector3(1, -(steps) * 2 - 3, 1)
	mat.uv1_offset = Vector3(0, -0.005, 0)
	
	
	# assign positions (because I did the math after the x and y were assigned)
	mesh.position = Vector3(given_position.x, given_position.y, given_position.z)
	
	var x = 0
	var y = 0
	for i in range(steps + 1):
		x = i * step_length
		y = i * step_height 
		
		points.append(Vector2(x, y))
		if i < steps:
			points.append(Vector2(x, y + step_height))
	points.append(Vector2(x, y - platform_thickness))
	points.append(Vector2(step_length, 0))
	
	mesh.polygon = points
		
	return {
		"mesh": mesh,
	}

# creates sprite, one for the front, top, and then one specifically for the platform
func create_sprites():
	var length_stairs = length * stairs_ratio
	var length_platform = length * (1.0 - stairs_ratio)
	
	# create identical top/front stairs with steps
	if (texture_stairs and steps > 0): 
		var sprite_info = create_mesh3D("StairsSprite", texture_stairs, Vector3(0, 90, 0), 
		Vector3(width/2.0, 0, length_stairs + length_platform), # dedicated to position
		Vector3.AXIS_Y, right_t_cutoff, right_b_cutoff, right_l_cutoff, right_r_cutoff)
		var mesh = sprite_info["mesh"]
	
	# create flat sprite stairs with platform
	if (texture_stairs and texture_platform and steps <= 0):
		if (stairs_ratio > 0.0):
			var sprite_stairs_info = create_sprite3D("StairsSprite", texture_stairs, Vector3(0, 0, 0), 
			Vector3(0, (height * stairs_offset) / 2.0, length_platform + (length_stairs) / 2.0), # dedicated to position
			Vector3.AXIS_Y)
			var stairs_sprite = sprite_stairs_info["sprite"]
			
			var temp_ratio = (length_stairs * stairs_ratio)/height
			
			# assign positions (because I did the math after the x and y were assigned)
			stairs_sprite.position = Vector3(0, (height * stairs_offset) /2.0, length_platform + (length_stairs) / 2.0)
			
			
			var ang_rad = atan2((length_stairs), (height * stairs_offset))
			var hypo = sqrt(pow((length_stairs), 2.0) + pow(height * stairs_offset, 2.0))
			stairs_sprite.rotation_degrees.x = (90 - rad_to_deg(ang_rad))
			
			# assign sizes depending on prior equations for sprites
			stairs_sprite.scale.x = (width) / (sprite_stairs_info["w_conv"] * pixel_size)
			stairs_sprite.scale.z = (hypo) / (sprite_stairs_info["h_conv"] * pixel_size)
			
		if (stairs_ratio < 1.0): 
			platform_sprite_create(length_platform, true)
		
		print('added stairs')
	# create flat sprite stairs without platform (will create its own platform from conversion if ratio dictates)
	if (texture_stairs and !texture_platform and steps <= 0):
		if (stairs_ratio > 0):
			var sprite_stairs_info = create_sprite3D("StairsSprite", texture_stairs, Vector3(0, 0, 0), 
			Vector3(0, (height * stairs_offset) /2.0, length_platform + (length_stairs) / 2.0), # dedicated to position
			Vector3.AXIS_Y)
			var stairs_sprite = sprite_stairs_info["sprite"]
			var temp_ratio = (length_stairs * stairs_ratio)/height
			# IMPORTANT: Temp_ratio is also important for padding
			# assign positions (because I did the math after the x and y were assigned) (not really, fix this)
			stairs_sprite.position = Vector3(0, (height * stairs_offset) /2.0, length_platform + (length_stairs) / 2.0)
			
			
			var ang_rad = atan2((length_stairs), (height * stairs_offset))
			var hypo = sqrt(pow((length_stairs), 2.0) + pow(height * stairs_offset, 2.0))
			stairs_sprite.rotation_degrees.x = (90 - rad_to_deg(ang_rad))
			# print('angle calc')
			
			stairs_sprite.region_enabled = true
			stairs_sprite.region_rect = Rect2(0, sprite_stairs_info["text_h"] * (1.0 - stairs_ratio), sprite_stairs_info["text_w"], sprite_stairs_info["text_h"] * stairs_ratio)
			
			
			# assign sizes depending on prior equations
			stairs_sprite.scale.x = width / (sprite_stairs_info["text_w"] * pixel_size)
			stairs_sprite.scale.z = hypo / (sprite_stairs_info["text_h"] * stairs_ratio * pixel_size)
		
		if (stairs_ratio < 1.0):
			platform_sprite_create(length_platform, false)
		
		# assign sizes depending on prior equations for sprites
		#stairs_sprite.scale.x = (width + top_spr_pad_left + top_spr_pad_right) / (sprite_stairs_info["w_conv"] * pixel_size)
		#stairs_sprite.scale.z = (hypo + top_spr_pad_bottom + top_spr_pad_top) / (sprite_stairs_info["h_conv"] * pixel_size)
		
		print('added stairs')
		
	if (steps > 0 and texture_platform):
		platform_sprite_create(length_platform, true)
	
	if (texture_right):
		var sprite_info = create_sprite3D("RightSprite", texture_right, Vector3(90, 180, 90), 
		Vector3((width + 0.001)/2.0, (height + right_spr_pad_top - right_spr_pad_bottom) /2.0, (length + right_spr_pad_left - right_spr_pad_right) / 2.0), # dedicated to position
		Vector3.AXIS_Y, right_t_cutoff, right_b_cutoff, right_l_cutoff, right_r_cutoff)
		var sprite = sprite_info["sprite"]
		
		# assign sizes depending on prior equations
		sprite.scale.z = (height + right_spr_pad_bottom + right_spr_pad_top) / ((sprite_info["h_conv"]) * pixel_size)
		sprite.scale.x = (length + right_spr_pad_left + right_spr_pad_right) / ((sprite_info["w_conv"]) * pixel_size)
		
		if check_any_cutoff(right_t_cutoff, right_b_cutoff, right_l_cutoff, right_r_cutoff):
			sprite.region_enabled = true
			sprite.region_rect = rect_2_creation(sprite_info["w_conv"], sprite_info["h_conv"], right_t_cutoff, right_b_cutoff, right_l_cutoff, right_r_cutoff)
		
		print('added right')
		
	if (texture_left):
		var sprite_info = create_sprite3D("LeftSprite", texture_left, Vector3(90, 180, 90), 
		Vector3((-(width + 0.001))/2.0, (height + left_spr_pad_top - left_spr_pad_bottom) /2.0, (length - left_spr_pad_left + left_spr_pad_right) / 2.0), # dedicated to position
		Vector3.AXIS_Y, left_t_cutoff, left_b_cutoff, left_l_cutoff, left_r_cutoff)
		var sprite = sprite_info["sprite"]
		
		# assign sizes depending on prior equations
		sprite.scale.z = (height + left_spr_pad_bottom + left_spr_pad_top) / (sprite_info["h_conv"] * pixel_size)
		sprite.scale.x = (length + left_spr_pad_left + left_spr_pad_right) / (sprite_info["w_conv"] * pixel_size)
		
		if check_any_cutoff(left_t_cutoff, left_b_cutoff, left_l_cutoff, left_r_cutoff):
			sprite.region_enabled = true
			sprite.region_rect = rect_2_creation(sprite_info["w_conv"], sprite_info["h_conv"], left_t_cutoff, left_b_cutoff, left_l_cutoff, left_r_cutoff)
		
		print('added left')
	
	if (texture_back):
		var sprite_info = create_sprite3D("BackSprite", texture_back, Vector3(90, 180, 0), 
		Vector3((-back_spr_pad_right + back_spr_pad_left) / 2.0, (height * stairs_offset -back_spr_pad_bottom + back_spr_pad_top) / 2.0, 0), # dedicated to position
		Vector3.AXIS_Y, back_t_cutoff, back_b_cutoff, back_l_cutoff, back_r_cutoff)
		var sprite = sprite_info["sprite"]
		
		# assign sizes depending on prior equations
		sprite.scale.z = ((height * stairs_offset) + back_spr_pad_bottom + back_spr_pad_top) / (sprite_info["h_conv"] * pixel_size)
		sprite.scale.x = (width + back_spr_pad_left + back_spr_pad_right) / (sprite_info["w_conv"] * pixel_size)
		
		if check_any_cutoff(back_t_cutoff, back_b_cutoff, back_l_cutoff, back_r_cutoff):
			sprite.region_enabled = true
			sprite.region_rect = rect_2_creation(sprite_info["w_conv"], sprite_info["h_conv"], back_t_cutoff, back_b_cutoff, back_l_cutoff, back_r_cutoff)
		
		
		print('added back')

# Creates hitboxes for the main and platform, with customized padding, hopefully it works
func create_hitboxes():
	var length_stairs = length * stairs_ratio
	var length_platform = length * (1.0 - stairs_ratio)
	
	# platform thickness size
	var actual_thickness = platform_thickness * height
	
	# Creates the main hitbox (relies on top image)
	# first creates shape which collision will refer to
	
	# next, creates the main collision shape, with all those nice looks
	var main_collision = CollisionPolygon3D.new()
	add_child(main_collision)
	_set_owner(main_collision)
	
	#main_collision.shape = main_box_shape
	main_collision.name = "MainHitbox"
	main_collision.debug_color = Color("#ff0000")
	main_collision.debug_color.a = 1.0
	main_collision.debug_fill = true
	main_collision.disabled = false
	main_collision.rotation_degrees = Vector3(0, -90, 0)
	main_collision.position = Vector3(0, 0, 0)
	main_collision.depth = width
	
	var temp_steps
	if (steps == 0): temp_steps = 1
	else: temp_steps = steps
	var step_height = (height * stairs_offset) / temp_steps
	var step_length = (length * stairs_ratio) / temp_steps
	var points = PackedVector2Array()
	points.append(Vector2(0, height * stairs_offset)) # initial point

	# platform hitbox
	if (stairs_ratio < 1.0):
		points.append(Vector2(length_platform, height * stairs_offset))
	# stairs hitbox
	if (stairs_ratio > 0.0):
		points.append(Vector2(length, 0))
	# case when there is a complex stair asset
	if (platform_thickness > 0.0):
		if (steps != 0): points.append(Vector2(length - step_length, 0))
		else: points.append(Vector2(length - platform_thickness, 0))
		points.append(Vector2(length_platform, height * stairs_offset - platform_thickness))
		points.append(Vector2(0, height * stairs_offset - platform_thickness))
		
		print("added platform")
	else:
		# only append if closed off, noncomplex stairs
		points.append(Vector2(0, 0))
	
	main_collision.polygon = points
	
	print('added main')
	#create railings
	if (railings and railings_height > 0 and stairs_ratio != 0):
		var left_array = PackedVector2Array([
		Vector2(0,height * stairs_offset + railings_height), # Point A
		Vector2(length_platform + step_length,height * stairs_offset + railings_height), # Point B
		Vector2(length, railings_height + step_height), # Point C
		Vector2(length,0), # Point D
		Vector2(length - step_length,0), # Point E
		Vector2(length_platform,height * stairs_offset - platform_thickness), # Point F
		Vector2(0,height * stairs_offset - platform_thickness), # Point F
		])
		
		var railing_left = CollisionPolygon3D.new()
		
		add_child(railing_left)
		_set_owner(railing_left)
		
		#railing_left.shape = main_box_shape
		railing_left.name = "RailingLeftHitbox"
		railing_left.debug_color = Color("#ff0000")
		railing_left.debug_color.a = 1.0
		railing_left.debug_fill = true
		railing_left.disabled = false
		railing_left.position = Vector3(-width/2.0 - 0.01, 0, 0)
		railing_left.rotation_degrees = Vector3(0, -90, 0)
		railing_left.depth = 0.01
		railing_left.polygon = left_array
		print("added left railing")
		
		var right_array = PackedVector2Array([
		Vector2(0,height * stairs_offset + railings_height), # Point A
		Vector2(length_platform + step_length,height * stairs_offset + railings_height), # Point B
		Vector2(length, railings_height + step_height), # Point C
		Vector2(length,0), # Point D
		Vector2(length - step_length,0), # Point E
		Vector2(length_platform,height * stairs_offset - platform_thickness), # Point F
		Vector2(0,height * stairs_offset - platform_thickness), # Point F
		])
		
		var railing_right = CollisionPolygon3D.new()
		
		add_child(railing_right)
		_set_owner(railing_right)
		
		#railing_right.shape = main_box_shape
		railing_right.name = "RailingRightHitbox"
		railing_right.debug_color = Color("#ff0000")
		railing_right.debug_color.a = 1.0
		railing_right.debug_fill = true
		railing_right.disabled = false
		railing_right.position = Vector3(width/2.0 + 0.01, 0, 0)
		railing_right.rotation_degrees = Vector3(0, -90, 0)
		railing_right.depth = 0.01
		railing_right.polygon = right_array
		print("added right railing")
	
	


func platform_sprite_create(length_platform, plat = false):
	if (!plat): 
		var sprite_platform_info = create_sprite3D("PlatformSprite", texture_stairs, Vector3(0, 0, 0), 
		Vector3(0, height * stairs_offset, length_platform / 2.0), # dedicated to position
		Vector3.AXIS_Y)
		var platform_sprite = sprite_platform_info["sprite"]
			
		platform_sprite.region_enabled = true
		platform_sprite.region_rect = Rect2(0, 0, sprite_platform_info["text_w"], sprite_platform_info["text_h"] * (1.0 - stairs_ratio))
			
		platform_sprite.scale.x = width / (sprite_platform_info["text_w"] * pixel_size)
		platform_sprite.scale.z = length / (sprite_platform_info["text_h"] * pixel_size)
		
	# with plat
	if (plat):
		var sprite_platform_info = create_sprite3D("PlatformSprite", texture_platform, Vector3(0, 0, 0), 
		Vector3(0, height * stairs_offset, length_platform / 2.0), # dedicated to position
		Vector3.AXIS_Y)
		var platform_sprite = sprite_platform_info["sprite"]
			
		platform_sprite.scale.x = width / (sprite_platform_info["text_w"] * pixel_size)
		platform_sprite.scale.z = length_platform / (sprite_platform_info["text_h"] * pixel_size)
	

# might switch to getting them within, but for streamlining purposes, lets make it quicker
# type in in the top name or front name the assets you want, it will get them
# example: "AlphaSprites/Bus 1 Down S3.png"
func collect_all_assets() -> bool:
	var dir = DirAccess.open("res://Assets/Art")
	print('completed directory open')
	if dir:
		texture_stairs = stairs_filename
		texture_platform = platform_filename
		texture_left = left_filename
		texture_right = right_filename
		texture_back = back_filename
		
		# excludes front and top
		var textures = [ texture_left, texture_right, texture_back ]
		
		# context again
		# complex box = 3 or more sides
		# simple box = 2 sides
		# slant box = top side only
		# side box = front side only
	
		
		print('completed getting files')
		
		if texture_stairs and texture_platform and textures.any(func(v): return v):
			print('completed verification complex')
			procedure = 'complex stairs'
			
			return true
		if texture_stairs and texture_platform:
			print('completed verification simple')
			procedure = 'semi-complex stairs'
			
			return true
		if texture_stairs:
			print('completed verification slant')
			procedure = 'simple stairs'
			
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
	var list_names = ["StairsSprite", "RailingLeftHitbox", "RailingRightHitbox", "PlatformSprite", "LeftSprite", "RightSprite", "BackSprite", "PlatSprite", "MainHitbox", "PlatformHitbox"]

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
