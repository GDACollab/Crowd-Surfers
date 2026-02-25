@tool
extends EditorScript

# ── CONFIG ────────────────────────────────────────────────────────────────────
# Folder containing your generated .tscn asset files
const ASSETS_PATH    := "res://Scenes/Level Components/Objects/"

# Where to save the finished reference scene
const OUTPUT_SCENE   := "res://Scenes/Levels/reference_scene.tscn"

# The road tile to use as the ground (must live in ASSETS_PATH)
const ROAD_SCENE     := "road-horizontal.tscn"

# Any filename stem that STARTS WITH one of these strings is excluded from the grid
const ROAD_PREFIXES  := ["road"]

# Size of one road tile in world units (matches your 100x100 art asset)
const ROAD_TILE_SIZE := 100.0

# Grid spacing between each asset (in Godot world units)
const GRID_SPACING_X := 150.0
const GRID_SPACING_Z := 150.0

# How many columns before wrapping to the next row
const COLUMNS        := 4

# Set true to rebuild even if the scene already exists
const OVERWRITE      := true
# ─────────────────────────────────────────────────────────────────────────────


func _run() -> void:
	if not OVERWRITE and ResourceLoader.exists(OUTPUT_SCENE):
		print("build_reference_scene: scene already exists (set OVERWRITE=true to rebuild)")
		return

	# ── collect .tscn files, filtering out roads ───────────────────────────
	var asset_paths: Array[String] = []

	var dir := DirAccess.open(ASSETS_PATH)
	if not dir:
		push_error("build_reference_scene: cannot open " + ASSETS_PATH)
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if not dir.current_is_dir() and entry.get_extension() == "tscn":
			if ASSETS_PATH + entry != OUTPUT_SCENE:
				var stem := entry.get_basename()
				var is_road := false
				for prefix in ROAD_PREFIXES:
					if stem.begins_with(prefix):
						is_road = true
						break
				if not is_road:
					asset_paths.append(ASSETS_PATH + entry)
		entry = dir.get_next()
	dir.list_dir_end()

	if asset_paths.is_empty():
		push_warning("build_reference_scene: no non-road .tscn files found in " + ASSETS_PATH)
		return

	asset_paths.sort()

	# ── calculate grid extents to know how many road tiles are needed ──────
	var total_cols := mini(asset_paths.size(), COLUMNS)
	var total_rows := ceili(float(asset_paths.size()) / float(COLUMNS))

	var grid_width := (total_cols - 1) * GRID_SPACING_X
	var grid_depth := (total_rows - 1) * GRID_SPACING_Z

	# One tile of padding around the whole grid
	var pad         := ROAD_TILE_SIZE
	var road_origin := Vector2(-pad, -pad)
	var road_end    := Vector2(grid_width + pad, grid_depth + pad)

	var tiles_x := ceili((road_end.x - road_origin.x) / ROAD_TILE_SIZE)
	var tiles_z := ceili((road_end.y - road_origin.y) / ROAD_TILE_SIZE)

	# ── build root node ────────────────────────────────────────────────────
	var root := Node3D.new()
	root.name = "ReferenceScene"

	# WorldEnvironment so the scene isn't black when opened
	var env_node := WorldEnvironment.new()
	env_node.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.15, 0.15, 0.15)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1, 1, 1)
	env.ambient_light_energy = 1.0
	env_node.environment = env
	root.add_child(env_node)
	env_node.owner = root

	# Directional light
	var light := DirectionalLight3D.new()
	light.name = "Sun"
	light.rotation_degrees = Vector3(-45, 45, 0)
	light.shadow_enabled = true
	root.add_child(light)
	light.owner = root

	# ── road ground layer (placed first / lowest in the tree) ──────────────
	var road_packed := load(ASSETS_PATH + ROAD_SCENE) as PackedScene

	if not road_packed:
		push_warning("build_reference_scene: could not load '%s' — skipping ground" % (ASSETS_PATH + ROAD_SCENE))
	else:
		var road_parent := Node3D.new()
		road_parent.name = "RoadGround"
		root.add_child(road_parent)
		road_parent.owner = root

		for tz in range(tiles_z):
			for tx in range(tiles_x):
				var tile := road_packed.instantiate()
				if not tile:
					continue
				tile.name = "Road_%d_%d" % [tx, tz]
				# Centre each tile within its cell
				var tile_x := road_origin.x + tx * ROAD_TILE_SIZE + ROAD_TILE_SIZE / 2.0
				var tile_z := road_origin.y + tz * ROAD_TILE_SIZE + ROAD_TILE_SIZE / 2.0
				if tile is Node3D:
					tile.position = Vector3(tile_x, 0.0, tile_z)
				road_parent.add_child(tile)
				# Only set owner on the instance root — NOT its children.
				# This keeps it as a scene reference instead of embedding all child nodes.
				tile.owner = root

		print("  tiled road ground: %dx%d tiles" % [tiles_x, tiles_z])

	# ── asset grid ─────────────────────────────────────────────────────────
	var grid_parent := Node3D.new()
	grid_parent.name = "AssetGrid"
	root.add_child(grid_parent)
	grid_parent.owner = root

	var col := 0
	var row := 0

	for path in asset_paths:
		var packed := load(path) as PackedScene
		if not packed:
			push_warning("build_reference_scene: could not load " + path)
			continue

		var instance := packed.instantiate()
		if not instance:
			push_warning("build_reference_scene: could not instantiate " + path)
			continue

		var file_stem := path.get_file().get_basename()
		instance.name = file_stem

		if instance is Node3D:
			instance.position = Vector3(col * GRID_SPACING_X, 0.0, row * GRID_SPACING_Z)

		grid_parent.add_child(instance)
		# Only set owner on the instance root — NOT its children.
		# This keeps it as a scene reference instead of embedding all child nodes.
		instance.owner = root

		print("  placed [%d,%d]: %s" % [col, row, file_stem])

		col += 1
		if col >= COLUMNS:
			col = 0
			row += 1

	# ── pack & save ────────────────────────────────────────────────────────
	var packed_scene := PackedScene.new()
	var err := packed_scene.pack(root)
	if err != OK:
		push_error("build_reference_scene: pack failed (%d)" % err)
		root.free()
		return

	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(OUTPUT_SCENE.get_base_dir())
	)

	var save_err := ResourceSaver.save(packed_scene, OUTPUT_SCENE)
	if save_err == OK:
		print("✅  build_reference_scene: saved → ", OUTPUT_SCENE)
	else:
		push_error("build_reference_scene: save failed (%d)" % save_err)

	root.free()
	EditorInterface.get_resource_filesystem().scan()
