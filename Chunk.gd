extends Spatial
class_name Chunk


var noise : OpenSimplexNoise
var x : float
var z : float
var size : int
var shouldRemove : bool = false
var rng : RandomNumberGenerator
var noiseObj : OpenSimplexNoise

var Rock : PackedScene = preload("res://Assets/RockLarge.tscn")
var TreeOak : PackedScene = preload("res://Assets/TreeOak.tscn")
var TreeFir : PackedScene = preload("res://Assets/TreeFir.tscn")
var Grass : PackedScene = preload("res://Assets/Grass.tscn")
var RawIronRock : PackedScene = preload("res://Assets/IronRock.tscn")
var RawCoalRock : PackedScene = preload("res://Assets/CoalRock.tscn")
var RockSmall : PackedScene = preload("res://Assets/RockSmall.tscn")

func _init(terrainNoise, objectNoise, chunkX, chunkZ, chunkSize):
	self.noise = terrainNoise
	self.noiseObj = objectNoise
	self.x = chunkX
	self.z = chunkZ
	self.size = chunkSize
	rng = RandomNumberGenerator.new()
	
func _ready():
	generateWater()
	generateChunk()
	
"""Create a Chunk. Form the Terrain and add Objects on top of it"""
func generateChunk() -> void:
	var planeMesh = PlaneMesh.new()
	planeMesh.size = Vector2(size, size)
	planeMesh.subdivide_depth = size * 0.25
	planeMesh.subdivide_width = size * 0.25
	
	planeMesh.material = preload("res://Assets/Terrain.tres")
	
	var surfaceTool = SurfaceTool.new()
	var meshDataTool = MeshDataTool.new()
	surfaceTool.create_from(planeMesh, 0)
	var arrayPlane = surfaceTool.commit()
	var _error = meshDataTool.create_from_surface(arrayPlane, 0)
	
	for i in range(meshDataTool.get_vertex_count()):
		var vertex = meshDataTool.get_vertex(i)
		
		vertex.y = noise.get_noise_2d(vertex.x + x, vertex.z + z) * 30
		
		meshDataTool.set_vertex(i, vertex)
		if i % 2 == 0:
			var objSpawns = noiseObj.get_noise_2d(vertex.x + x, vertex.z + z) * 6 + 3
			if vertex.y > 2:
				if objSpawns < 1 and objSpawns > 0.8:
					instanceObject(TreeOak, vertex, Vector3(0, rng.randf_range(0, 360), 0))
				elif objSpawns < 2 and objSpawns > 1.8:
					instanceObject(TreeFir, Vector3(vertex.x, vertex.y + 3, vertex.z), Vector3(0, rng.randf_range(0, 360), 0))
			elif vertex.y > -2 and vertex.y < 0:
				if objSpawns < 1 and objSpawns > 0.8:
					instanceObject(Rock, vertex, Vector3(rng.randf_range(0, 30), rng.randf_range(0, 90), 0))
				elif objSpawns < 2 and objSpawns > 1.8:
					instanceObject(RawIronRock, vertex, Vector3(0, rng.randf_range(0, 360), 0))
				elif objSpawns < 3 and objSpawns > 2.8:
					instanceObject(RawCoalRock, vertex, Vector3(0, rng.randf_range(0, 360), 0))
				elif objSpawns < 4 and objSpawns > 3.6:
					instanceObject(RockSmall, vertex, Vector3(0, rng.randf_range(0, 360), 0))
			
	for y in range(arrayPlane.get_surface_count()):
		arrayPlane.surface_remove(y)
		
	meshDataTool.commit_to_surface(arrayPlane)
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surfaceTool.create_from(arrayPlane, 0)
	surfaceTool.generate_normals()
	
	var meshInstance = MeshInstance.new()
	meshInstance.mesh = surfaceTool.commit()
	meshInstance.create_trimesh_collision()
	meshInstance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_ON
	add_child(meshInstance)
	
func generateWater():
	var planeMesh = PlaneMesh.new()
	planeMesh.size = Vector2(size, size)
	
	planeMesh.material = preload("res://Assets/Water.tres")
	
	var meshInstance = MeshInstance.new()
	meshInstance.mesh = planeMesh
	meshInstance.translation = Vector3(0, -7, 0)
	
	add_child(meshInstance)
	
func instanceObject(Instance, position, rotation):
	var inst = Instance.instance()
	inst.translation = position
	inst.rotation_degrees = rotation
	add_child(inst)
