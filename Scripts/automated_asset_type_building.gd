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
		_update_hitboxes()

@export_group("Dimensions")
# different variables to edit the dimensions
# the width of the overall sprite
@export var width: float = 50.0:
	set(value):
		width = value
		_update_hitboxes()
# the length of the top sprite
@export var top_length: float = 50.0:
	set(value):
		top_length = value
		_update_hitboxes()
# the length of the front sprite 
@export var front_length: float = 50.0:
	set(value): 
		front_length = value
		_update_hitboxes()
# padding relative to the z-axis (incase hitbox needs to decrease in size)
@export var z_pad: float = 0.0:
	set(value): 
		z_pad = value
		_update_hitboxes()
# padding relative to the x-axis (incase hitbox needs to decrease in size)
@export var x_pad: float = 0.0:
	set(value): 
		x_pad = value
		_update_hitboxes()


@export_group("File Reference")
@export var top_filename: String = 'unknown':
	set(value):
		top_filename = value
		_update_hitboxes()

@export_group("Additional Settings")
@export var platform_thickness: float = 1.0: # thickness of the platform (since not decided by art asset)
	set(value): 
		platform_thickness = value
		_update_hitboxes()
var pixel_size = 0.01 # meters for pixel height (default: 0.01, maybe just never change this, it'll break everything)
# once again, you better not have changed pixel size

var main_hitbox_vec = Vector3(0, 0, 0)
var platform_hitbox_vec = Vector3(0, 0, 0)
# these are texture variables, they shall hold textures if they exist
var texture_top: Texture2D

# reference of size of pixels for the art assets
var top = Vector2(0, 0)
var front = Vector2(0, 0)

# extra variables because issues of rendering
var offset_y: float = 0.01

# updates hitboxes upon every small change
func _update_hitboxes():
	if (!active): return
	# initially makes sure all previous versions are destroyed, careful this will reset everything you worked on
	var child_list = []
	for child in get_children():
		if child is CollisionShape3D or child is Sprite3D:
			child_list.append(child)
	for child in child_list:
		child.queue_free()
		
	# begins checking if existing and creating assets
	if (collect_all_assets()): 
		print("creationary stage")
		
		create_sprites()
		
		create_hitboxes()
	

# creates 3 sprites, one for the front, top, and then one specifically for the platform
func create_sprites():
	# Creates top sprite
	var top_sprite = Sprite3D.new()
	
	# add children
	add_child(top_sprite)
	_set_owner(top_sprite)
	
	top_sprite.texture = texture_top
	top_sprite.name = "TopSprite"
	top_sprite.pixel_size = pixel_size
	top_sprite.axis = Vector3.AXIS_Y # lays flat
	top_sprite.rotation_degrees.y = 180 # rotates sprite
	
	# Creates platform sprite
	var plat_sprite = Sprite3D.new()
	
	# add children
	add_child(plat_sprite)
	_set_owner(plat_sprite)
	
	plat_sprite.texture = texture_top
	plat_sprite.name = "PlatSprite"
	plat_sprite.pixel_size = pixel_size
	plat_sprite.axis = Vector3.AXIS_Y # lays flat
	plat_sprite.rotation_degrees.y = 180 # rotates sprite
	
	# assign top and front vectors with sizes compensating for pixel size
	var base_top_w = texture_top.get_width() * pixel_size
	var base_top_h = texture_top.get_height() * pixel_size
	top = Vector2(base_top_w, base_top_h)
	
	# additional code for cropping the top art
	plat_sprite.region_enabled = true
	var ratio = top_length / front_length
	var crop_height_pixels = texture_top.get_height() / ratio
	print(ratio)
	print(crop_height_pixels)
	plat_sprite.region_rect = Rect2(0, 0, texture_top.get_width(), crop_height_pixels)
	
	# combines both the front and the top
	plat_sprite.scale.x = width / base_top_w
	plat_sprite.scale.z = (front_length / base_front_h) * ratio
	
	
	# assign sizes depending on prior equations
	top_sprite.scale.x = width / base_top_w
	top_sprite.scale.z = top_length / base_top_h
	
	# assign positions (because I did the math after the x and y were assigned)
	top_sprite.position = Vector3(0, 0 + offset_y, front_length/2)
	plat_sprite.position = Vector3(0, front_length, (top_length/4)) # opposite of front sprite
	
	
	
	print("added sprites")

# Creates hitboxes for the main and platform, with customized padding, hopefully it works
func create_hitboxes():
	# Creates the main hitbox (relies on top image)
	# first creates shape which collision will refer to
	var main_box_shape = BoxShape3D.new()
	main_box_shape.size = Vector3(width - x_pad, front_length, top_length - front_length - z_pad) # might need to divide front length by 2
	
	# next, creates the main collision shape, with all those nice looks
	var main_collision = CollisionShape3D.new()
	
	add_child(main_collision)
	_set_owner(main_collision)
	
	main_collision.shape = main_box_shape
	main_collision.name = "MainHitbox"
	main_collision.debug_color = Color("#ff0000")
	main_collision.debug_color.a = 1.0
	main_collision.debug_fill = true
	main_collision.position = Vector3(0, front_length / 2.0, z_pad / 2.0)
	
	print("added main")
	
	# Creates the platform hitbox (relies on front image)
	# first creates shape which collision will refer to
	var plat_box_shape = BoxShape3D.new()
	plat_box_shape.size = Vector3(width - x_pad, platform_thickness, front_length - z_pad)
	
	# next, creates the platform collision shape, with all those nice looks
	var platform_collision = CollisionShape3D.new()
	
	add_child(platform_collision)
	_set_owner(platform_collision)
	
	platform_collision.shape = plat_box_shape
	platform_collision.name = "PlatformHitbox"
	platform_collision.debug_color = Color("#da00e2")
	platform_collision.debug_color.a = 1.0
	platform_collision.debug_fill = true
	platform_collision.position = Vector3(0, front_length - platform_thickness/2, (top_length/2 - z_pad/2))
	
	print("added platform")
	

# might switch to getting them within, but for streamlining purposes, lets make it quicker
# type in in the top name or front name the assets you want, it will get them
# example: "AlphaSprites/Bus 1 Down S3.png"
func collect_all_assets() -> bool:
	var dir = DirAccess.open("res://Assets/Art")
	print('completed directory open')
	if dir:
		#var target_top_dir = dir_exists(top_name)
		#var target_front_dir = dir_exists(front_name)
		texture_top = load("res://Assets/Art/" + top_filename)
		texture_front = load("res://Assets/Art/" + front_filename)

		print("res://Assets/Art" + front_filename)
		
		print('completed getting files')
		
		if texture_top and texture_front:
			print('completed verification')
			
			return true
	return false
	
# sets the owner of the current node, to make sure the node appears in the scene
func _set_owner(node):
	if get_tree():
		node.owner = get_tree().edited_scene_root
