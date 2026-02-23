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
@export var front_length: float = 50.0:
	set(value): 
		front_length = value
		_update_hitboxes()
# padding relative to the z-axis from above (incase hitbox needs to decrease in size)
@export var z_pad_top: float = 0.0:
	set(value): 
		z_pad_top = value
		_update_hitboxes()
# padding relative to the z-axis from below (incase hitbox needs to decrease in size)
@export var z_pad_bottom: float = 0.0:
	set(value): 
		z_pad_bottom = value
		_update_hitboxes()
# padding relative to the x-axis for main hitbox (incase hitbox needs to decrease in size)
@export var x_pad_hitbox: float = 0.0:
	set(value): 
		x_pad_hitbox = value
		_update_hitboxes()
# padding relative to the x-axis for plat hitbox(incase hitbox needs to decrease in size)
@export var x_pad_platform: float = 0.0:
	set(value): 
		x_pad_platform = value
		_update_hitboxes()
# offset for the platform's z or influence on the main hitbox
@export var offset_plat: float = 0.0:
	set(value): 
		offset_plat = value
		_update_hitboxes()
# offset for the sprite's cutoff, to help art out
@export var art_z_cutoff: float = 0.0:
	set(value): 
		art_z_cutoff = value
		_update_hitboxes()



@export_group("File Reference")
@export var filename: String = 'ex: AlphaSprites/...':
	set(value):
		filename = value
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
var texture: Texture2D

# reference of size of pixels for the art assets
var top = Vector2(0, 0)
var front = Vector2(0, 0)

# extra variables because issues of rendering
var offset_y: float = 0.01

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
	
	
	# Createsbsprite
	var top_sprite = Sprite3D.new()
	
	# add children
	add_child(top_sprite)
	_set_owner(top_sprite)
	
	top_sprite.texture = texture
	top_sprite.name = "TopSprite"
	top_sprite.pixel_size = pixel_size
	top_sprite.axis = Vector3.AXIS_Y # lays flat
	top_sprite.rotation_degrees.y = -180 # rotates top_sprite
	print('initial values')
	
	# Creates floor sprite
	var front_sprite = Sprite3D.new()
	
	# add children
	add_child(front_sprite)
	_set_owner(front_sprite)
	
	front_sprite.texture = texture
	front_sprite.name = "FrontSprite"
	front_sprite.pixel_size = pixel_size
	front_sprite.axis = Vector3.AXIS_Y # lays flat
	front_sprite.rotation_degrees.y = 180 # rotates sprite
	
	# ratio for cutoff
	var ratio_top = 1.0 - art_z_cutoff
	var ratio_front = art_z_cutoff
	
	# assign top and front vectors with sizes compensating for pixel size
	var text_w = texture.get_width()
	var text_h = texture.get_height()
	var crop_h_top = text_h * ratio_top
	var crop_h_front = text_h * ratio_front
	
	
	
	# calculates relative size of z of both front and top, and y as well (z is x in this case)
	top.x = top_length
	front.x = front_length
	top.y = (top_length / (top_length + front_length)) * front_length
	front.y = (front_length / (top_length + front_length)) * front_length
	#+ top_length * ratio_front
	
	# calculates angle
	# hypo top, has ratio_top * front_length is height, and the length is top_length
	# hypo front, has ratio_front * front_length is height, and the length is front_length
	var hypo_top = sqrt(pow(top.y, 2.0) + pow(top.x, 2.0))
	var hypo_front = sqrt(pow(front.y, 2.0) + pow(front.x, 2.0))
	var ang_rad = atan2(front.x + top.x, front.x)
	top_sprite.rotation_degrees.x = (90 - rad_to_deg(ang_rad))
	front_sprite.rotation_degrees.x = (90 - rad_to_deg(ang_rad))
	print('anngle calc')
	
	top_sprite.region_enabled = true
	front_sprite.region_enabled = true
	print(ratio_top)
	print(ratio_front)
	
	top_sprite.region_rect = Rect2(0, 0, text_w, crop_h_top)
	front_sprite.region_rect = Rect2(0, crop_h_top, text_w, crop_h_front)
	
	# assign sizes depending on prior equations
	top_sprite.scale.x = width / (text_w * pixel_size)
	top_sprite.scale.z = hypo_top / (crop_h_top * pixel_size)
	
	front_sprite.scale.x = width/ (text_w * pixel_size)
	front_sprite.scale.z = hypo_front / (crop_h_front * pixel_size)
	
	# assign positions (because I did the math after the x and y were assigned)
	top_sprite.position = Vector3(0, front.y + top.y/2.0, -top_length / 2.0)
	front_sprite.position = Vector3(0, front.y / 2.0, -top_length - front_length / 2.0)

	
	
	print("added sprites")

# Creates hitboxes for the main and platform, with customized padding, hopefully it works
func create_hitboxes():
	# Creates the main hitbox (relies on top image)
	# first creates shape which collision will refer to
	var main_box_shape = BoxShape3D.new()
	main_box_shape.size = Vector3(width - x_pad_hitbox, front_length, top_length - z_pad_bottom - offset_plat) # might need to divide front length by 2
	
	# next, creates the main collision shape, with all those nice looks
	var main_collision = CollisionShape3D.new()
	
	add_child(main_collision)
	_set_owner(main_collision)
	
	main_collision.shape = main_box_shape
	main_collision.name = "MainHitbox"
	main_collision.debug_color = Color("#ff0000")
	main_collision.debug_color.a = 1.0
	main_collision.debug_fill = true
	main_collision.position = Vector3(0, front_length / 2.0, -top_length / 2.0 -front_length + z_pad_bottom/2.0 - offset_plat/2.0)
	
	print("added main")
	
	# Creates the platform hitbox (relies on front image)
	# first creates shape which collision will refer to
	var plat_box_shape = BoxShape3D.new()
	plat_box_shape.size = Vector3(width - x_pad_platform, platform_thickness, front_length - z_pad_top + offset_plat)
	
	# next, creates the platform collision shape, with all those nice looks
	var platform_collision = CollisionShape3D.new()
	
	add_child(platform_collision)
	_set_owner(platform_collision)
	
	platform_collision.shape = plat_box_shape
	platform_collision.name = "PlatformHitbox"
	platform_collision.debug_color = Color("#da00e2")
	platform_collision.debug_color.a = 1.0
	platform_collision.debug_fill = true
	platform_collision.position = Vector3(0, front_length - platform_thickness/2.0, -front_length/2.0 - z_pad_top/2.0 - offset_plat/2.0)
	
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
		texture = load("res://Assets/Art/" + filename)

		print("res://Assets/Art" + filename)
		
		print('completed getting files')
		
		if texture:
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
		if child.name.begins_with("TopSprite") or child.name.begins_with("FrontSprite") or child.name.begins_with("PlatSprite") or child.name.begins_with("MainHitbox") or child.name.begins_with("PlatformHitbox"):
			child.free() # frees for instant removal in tool script
