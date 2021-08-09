extends Spatial
class_name Chunk

var meshInstance
var noise
var x
var z
var chunkSize
var shouldRemove = false
var rng
var Rock = preload("res://Assets/BigRock.tscn")
var TreeLarge = preload("res://Assets/Tree.tscn")

func _init(noise, x, z, chunkSize):
	self.noise = noise
	self.x = x
	self.z = z
	self.chunkSize = chunkSize
	rng = RandomNumberGenerator.new()
	rng.seed = 0
	
func _ready():
	generateChunk()
	
func generateChunk():
	var planeMesh = PlaneMesh.new()
	planeMesh.size = Vector2(chunkSize, chunkSize)
	planeMesh.subdivide_depth = chunkSize * 0.3
	planeMesh.subdivide_width = chunkSize * 0.3
	
	#TODO Give the Mesh a Material
	var surfaceTool = SurfaceTool.new()
	var meshDataTool = MeshDataTool.new()
	surfaceTool.create_from(planeMesh, 0)
	var arrayPlane = surfaceTool.commit()
	var error = meshDataTool.create_from_surface(arrayPlane, 0)
	
	for i in range(meshDataTool.get_vertex_count()):
		var vertex = meshDataTool.get_vertex(i)
		
		noise.octaves = 4
		vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * 60
		noise.octaves = 3
		
		meshDataTool.set_vertex(i, vertex)
		var rand = rng.randi_range(0, 100)
		if rand == 5:
			var rock = Rock.instance()
			add_child(rock)
			rock.translation = vertex
		if rand == 10:
			var tree = TreeLarge.instance()
			add_child(tree)
			tree.translation = vertex
		
	for y in range(arrayPlane.get_surface_count()):
		arrayPlane.surface_remove(y)
		
	meshDataTool.commit_to_surface(arrayPlane)
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surfaceTool.create_from(arrayPlane, 0)
	surfaceTool.generate_normals()
	
	meshInstance = MeshInstance.new()
	meshInstance.mesh = surfaceTool.commit()
	meshInstance.create_trimesh_collision()
	meshInstance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_ON
	add_child(meshInstance)
