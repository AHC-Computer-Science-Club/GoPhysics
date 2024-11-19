extends Node3D

# Declare nodes and variables
var path : Path3D
var curve : Curve3D
var mesh_instances : Array = []
var tension_factor : float = 0.5
var gravity : Vector3 = Vector3(0, -9.8, 0)
var time_step : float = 0.016  # Assume 60 FPS for simplicity
var time_offset : float = 0.0  # To track time

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create and set up the Path3D node
	path = Path3D.new()
	add_child(path)

	# Create a Curve3D and assign it to the Path3D
	curve = Curve3D.new()
	path.curve = curve

	# Define the control points for the Bezier curve
	curve.add_point(Vector3(0, 0, 0))  # Start point
	curve.add_point(Vector3(2, 4, 0))  # First control point
	curve.add_point(Vector3(4, -2, 0))  # Second control point
	curve.add_point(Vector3(6, 0, 0))  # End point

	# Create MeshInstance3D nodes along the curve for string segments
	for i in range(1, curve.get_point_count()):
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = create_string_mesh()  # Create a small cylinder or rope mesh
		mesh_instance.position = curve.get_point_position(i)
		mesh_instances.append(mesh_instance)
		add_child(mesh_instance)

# Create a simple cylinder mesh for the string segments
func create_string_mesh() -> Mesh:
	var cylinder = CylinderMesh.new()
	cylinder.bottom_radius = 0.05
	cylinder.top_radius = 0.05
	cylinder.height = 0.2
	return cylinder

# Called every frame
func _process(delta):
	# Update control points dynamically to simulate slack or tension
	update_control_points()

	# Update MeshInstances for string segments
	for i in range(1, curve.get_point_count()):
		mesh_instances[i - 1].position = curve.get_point_position(i)

# Update control points to simulate dynamic movement (slack, tension, gravity)
func update_control_points():
	# Get current time in milliseconds
	time_offset += Time.get_ticks_usec()*0.00001  # Convert to milliseconds

	# Modify the control points dynamically (e.g., oscillate or apply forces)
	curve.set_point_position(1, Vector3(2, 5 * sin(time_offset / 1000.0), 0))  # Update control point 1
	curve.set_point_position(2, Vector3(4, -2 + sin(time_offset / 800.0), 0))  # Update control point 2

	# Simulate slack and tension using gravity
	for i in range(1, curve.get_point_count() - 1):
		var control_point = curve.get_point_position(i)
		control_point += gravity * time_step * tension_factor
		curve.set_point_position(i, control_point)
