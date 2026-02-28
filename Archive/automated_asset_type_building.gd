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
@export var height: float = 50.0:
	set(value): 
		height = value
		_update_hitboxes()
# the offset/length of the [axis][side] hitbox
@export var offsetZL: float = 0.0:
	set(value): 
		offsetZL = value
		_update_hitboxes()
# the offset/length of the [axis][side] hitbox
@export var offsetXL: float = 0.0:
	set(value): 
		offsetXL = value
		_update_hitboxes()
# the offset/length of the [axis][side] hitbox
@export var offsetZR: float = 0.0:
	set(value): 
		offsetZR = value
		_update_hitboxes()
# the offset/length of the [axis][side] hitbox
@export var offsetXR: float = 0.0:
	set(value): 
		offsetXR = value
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

# confirmation variables
var curr_offsetZL: float = 0.0
var curr_offsetXL: float = 0.0
var curr_offsetZR: float = 0.0
var curr_offsetXR: float = 0.0

# ready function catches when someone just enters the edtior scene, turning off the editor
func _ready():
	if Engine.is_editor_hint():
		active = false

# updates hitboxes upon every small change
func _update_hitboxes():
	if (!active) or !is_inside_tree(): return
	# initially makes sure all previous versions are destroyed, careful this will reset everything you worked on
	cleanup_generated_nodes()
		
	# safety variables to confirm changes
	if (offsetZL > 0 && offsetXL > 0):
		curr_offsetZL = offsetZL
		curr_offsetXL = offsetXL
	else:
		curr_offsetZL = 0
		curr_offsetXL = 0
	if (offsetZR > 0 && offsetXR > 0):
		curr_offsetZR = offsetZR
		curr_offsetXR = offsetXR
	else:
		curr_offsetZR = 0
		curr_offsetXR = 0
	
	# begins checking if existing and creating assets
	if (collect_all_assets()): 
		print("creationary stage")
		
		create_sprites()
		
		create_hitboxes()
	

# creates 3 sprites, one for the front, top, and then one specifically for the platform
func create_sprites():
	# Creates top sprite
	var top_sprite = Sprite3D.new()
	top_sprite.add_to_group("generated_assets") # tags
	
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
	plat_sprite.add_to_group("generated_assets") # tags
	
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
	var ratio = 2.0
	var crop_height_pixels = texture_top.get_height() / ratio
	print(ratio)
	print(crop_height_pixels)
	plat_sprite.region_rect = Rect2(0, 0, texture_top.get_width(), crop_height_pixels)
	
	# combines both the front and the top
	plat_sprite.scale.x = width / base_top_w
	plat_sprite.scale.z = top_length / (texture_top.get_height() * pixel_size)
	
	
	# assign sizes depending on prior equations
	top_sprite.scale.x = width / base_top_w
	top_sprite.scale.z = top_length / base_top_h
	
	# assign positions (because I did the math after the x and y were assigned)
	top_sprite.position = Vector3(0, 0 + offset_y, -top_length / 2.0)
	plat_sprite.position = Vector3(0, height, -top_length / 4.0) # opposite of front sprite
	
	
	
	print("added sprites")

# Creates hitboxes for the main and platform, with customized padding, hopefully it works
func create_hitboxes():
	# Creates the main hitbox (relies on top image)
	# first creates shape which collision will refer to
	var main_box_shape = BoxShape3D.new()
	main_box_shape.size = Vector3(width - curr_offsetXL - curr_offsetXR - x_pad, height, top_length - z_pad) # might need to divide front length by 2
	print(main_box_shape.size)
	
	# next, creates the main collision shape, with all those nice looks
	var main_collision = CollisionShape3D.new()
	main_collision.add_to_group("generated_assets") # tags
	
	add_child(main_collision)
	_set_owner(main_collision)
	
	main_collision.shape = main_box_shape
	main_collision.name = "MainHitbox"
	main_collision.debug_color = Color("#ff0000")
	main_collision.debug_color.a = 1.0
	main_collision.debug_fill = true
	main_collision.position = Vector3(0 - curr_offsetXL / 2.0 + curr_offsetXR / 2.0, height / 2.0, -top_length / 2.0)
	
	print("added main")
	
	# next, will create left collision shape, hopefully with the right details, and only if there exists an offsetXL && offsetZL
	if (offsetXL > 0.0 and offsetZL > 0.0):
		# creates left hitbox
		var left_box_shape = BoxShape3D.new()
		left_box_shape.size = Vector3(curr_offsetXL, height, top_length - z_pad - curr_offsetZL) # might need to divide front length by 2
		
		# creates the left hitbox itself
		var left_collision = CollisionShape3D.new()
		left_collision.add_to_group("generated_assets") # tags
		
		add_child(left_collision)
		_set_owner(left_collision)
		
		left_collision.shape = left_box_shape
		left_collision.name = "LeftHitbox"
		left_collision.debug_color = Color("#ff0000")
		left_collision.debug_color.a = 1.0
		left_collision.debug_fill = true
		left_collision.position = Vector3(width/2.0 - (curr_offsetXL / 2.0) - x_pad / 2.0, height / 2.0, curr_offsetZL / 2.0 - top_length / 2.0 )
		
		print("added left")
		
		# creates the unique triangle/poly shape (good luck reading this lol)
		var left_tri_shape = ConvexPolygonShape3D.new()
		var left_tri_array = PackedVector3Array([
		Vector3(-curr_offsetXL / 2.0, 0, curr_offsetZL / 2.0), # Point A
		Vector3(-curr_offsetXL / 2.0, height, curr_offsetZL / 2.0), # Point B
		Vector3(-curr_offsetXL / 2.0, 0, -curr_offsetZL / 2.0), # Point C
		Vector3(-curr_offsetXL / 2.0, height, -curr_offsetZL / 2.0), # Point D
		Vector3(curr_offsetXL / 2.0, 0, curr_offsetZL / 2.0), # Point E
		Vector3(curr_offsetXL / 2.0, height, curr_offsetZL / 2.0) # Point F
		])
		left_tri_shape.set_points(left_tri_array)
		
		var left_tri_collision = CollisionShape3D.new()
		left_tri_collision.add_to_group("generated_assets") # tags
		
		add_child(left_tri_collision)
		_set_owner(left_tri_collision)
		
		left_tri_collision.shape = left_tri_shape
		left_tri_collision.name = "LeftTriHitbox"
		left_tri_collision.debug_color = Color("#ff0000")
		left_tri_collision.debug_color.a = 1.0
		left_tri_collision.debug_fill = true
		left_tri_collision.position = Vector3(width / 2.0 - curr_offsetXL / 2.0 - x_pad / 2.0, 0, -top_length + curr_offsetZL / 2.0 + z_pad / 2.0)
		
		print("added left tri")
	
	# next, will create right collision shape, hopefully with the right details, and only if there exists an offsetXR && offsetZR
	if (offsetXR > 0.0 and offsetZR > 0.0):
		# creates right hitbox
		var right_box_shape = BoxShape3D.new()
		right_box_shape.size = Vector3(curr_offsetXR, height, top_length - z_pad - curr_offsetZR) # might need to divide front length by 2
		
		var right_collision = CollisionShape3D.new()
		right_collision.add_to_group("generated_assets") # tags
		
		add_child(right_collision)
		_set_owner(right_collision)
		print(right_box_shape.size)
		right_collision.shape = right_box_shape
		right_collision.name = "RightHitbox"
		right_collision.debug_color = Color("#ff0000")
		right_collision.debug_color.a = 1.0
		right_collision.debug_fill = true
		right_collision.position = Vector3(-width/2.0 + (curr_offsetXR / 2.0) + x_pad / 2.0, height / 2.0, curr_offsetZR / 2.0 - top_length / 2.0 )
		print(right_collision.position)
		print("added right")
		
		# creates the unique triangle/poly shape (good luck reading this lol)
		var right_tri_shape = ConvexPolygonShape3D.new()
		var right_tri_array = PackedVector3Array([
		Vector3(curr_offsetXR / 2.0, 0, curr_offsetZR / 2.0), # Point A
		Vector3(curr_offsetXR / 2.0, height, curr_offsetZR / 2.0), # Point B
		Vector3(curr_offsetXR / 2.0, 0, -curr_offsetZR / 2.0), # Point C
		Vector3(curr_offsetXR / 2.0, height, -curr_offsetZR / 2.0), # Point D
		Vector3(-curr_offsetXR / 2.0, 0, curr_offsetZR / 2.0), # Point E
		Vector3(-curr_offsetXR / 2.0, height, curr_offsetZR / 2.0) # Point F
		])
		right_tri_shape.set_points(right_tri_array)
		
		var right_tri_collision = CollisionShape3D.new()
		right_tri_collision.add_to_group("generated_assets") # tags
		
		add_child(right_tri_collision)
		_set_owner(right_tri_collision)
		
		right_tri_collision.shape = right_tri_shape
		right_tri_collision.name = "RightTriHitbox"
		right_tri_collision.debug_color = Color("#ff0000")
		right_tri_collision.debug_color.a = 1.0
		right_tri_collision.debug_fill = true
		right_tri_collision.position = Vector3(-width / 2.0 + curr_offsetXR / 2.0 + x_pad / 2.0, 0, -top_length + curr_offsetZR / 2.0 + z_pad / 2.0)
		
		print("added right tri")
	

# might switch to getting them within, but for streamlining purposes, lets make it quicker
# type in in the top name or front name the assets you want, it will get them
# example: "AlphaSprites/Bus 1 Down S3.png"
func collect_all_assets() -> bool:
	var dir = DirAccess.open("res://Assets/Art")
	print('completed directory open')
	if dir:
		texture_top = load("res://Assets/Art/" + top_filename)

		print("res://Assets/Art" + top_filename)
		
		print('completed getting files')
		
		if texture_top:
			print('completed verification')
			
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
	# iterates through, double checking to make sure it doesn't accidentally delete something
	for child in children:
		if child.name.begins_with("TopSprite") or child.name.begins_with("PlatSprite") or child.name.begins_with("MainHitbox") or child.name.begins_with("LeftHitbox") or child.name.begins_with("LeftTriHitbox") or child.name.begins_with("RightHitbox") or child.name.begins_with("RightTriHitbox"):
			child.free() # frees for instant removal in tool script
