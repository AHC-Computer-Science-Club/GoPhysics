extends Node3D

# Notes from UP by Young and Freedman for 'primative' yoyo under the condition the string does not slip on the cylinder
# Sum of forces would be Mg - T = Ma(subcm-y); Where M is mass of yoyo system, g is downward accel due to gravity near earth, T is tension, and a(subcm) is acceleration
# The sum of torques would be I(subcm)alpha(subz) = 1/2MR^2alpha(subz) where I is inertia and R is Radus from edge to center
# Because the string undwinds without slipping, v(subcm-z) = Romega(subz)
# Solving for a(subcm-y) we get that is equals 2/3 * g 
# Solving for Tension we get that it equals 1/3 * Mg
# After is has fallen a distance h we should expect the final speed to be (4/3 * gh)^1/2 where h is the distance fallen


class_name YoYoRoot


# Initialize values needed at ready time
@onready var disk_radius = $YoYoBody/RoundDiskFront.mesh.top_radius         # Radius of each disk (m)
@onready var axle_radius = $YoYoBody/Axle.mesh.top_radius          # Radius of the axle (m)
@onready var axle_length = $YoYoBody/Axle.mesh.height           # Length of the axle (m)
@onready var frontDisk = $YoYoBody/RoundDiskFront
@onready var backDisk = $YoYoBody/RoundDiskBack
@onready var axle = $YoYoBody/Axle
@onready var connectionPoint = $YoYoBody/AxleConnectionPoint
@onready var yoyoBody = $YoYoBody
@onready var startPoint = $String/StartPoint
@onready var endPoint = $String/EndPoint
@onready var stringBody = $String/stringMesh
@onready var stringHeight = stringBody.mesh.height
@onready var scaleFactor = $".".scale.y
@onready var cameraLockedPosition = $"../Camera3D".global_position


# Initialize undynamic values
# After sliders this sections does not do as much, but still handy visual aid!... short on time to refactor 
var disk_thickness # Thickness of each disk (m)
var disk_mass = .121 # Mass of each disk (kg)
var axle_mass = .0035  # Mass of the axle (kg)
var g = 9.8 # Acceleration due to gravity (m/s^2)
var h_max = 10  # Maximum height (m)
var time_scale = 1 # Finer control over time

# Boolean variables
var paused = true
var current_sim_finished = false
var camera_locked = true

# Setup for different shapes to calculate Inertia later
enum ShapeType {
	DISK,
	SQUARE,
	RING
}
# Temp Var for hold current shape 
var current_shape = ShapeType.DISK

# A bunch of initializations
var theta = 0.0                 # Initial angle in radians
var omega = 0.0                 # Initial angular velocity (rad/s)
var alpha = 0.0                 # Initial angular acceleration (rad/s^2)
var torque = 0.0                # Initial torque (N*m)
var vy = 0.0                    # Initial vertical velocity of the system
var axis_initial_global_position_y = 0.0            # Initial vertical position of the system
var tension_force = 0           # Upward tension force applied to one side of the axle (N)
var total_weight = 0
var weight_force = 0
var net_force = 0
var stringLength = 0
var moment_of_inertia = 0 
var acceleration = 0

## Mucking about with csv variables
#var omega_values = []  # Array to hold omega values
#var time_scale_values = [] # Array to hold time scale values
#var speed_values = [] # Array to hold speed values
#var height_fall_values = []
#var frame_counter = 0  # Counter to track frames
#var frame_constraint = 1 # Use this to change at what rate data is recorded into

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()
	
	init_physics()
	var tracked_keys = ["theta", "omega", "vy", "tension_force", "acceleration"]
	DataCollection.init_tracking(tracked_keys)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	# Control time steps
	delta = delta * time_scale
	
	# Update the motion of the yoyo
	update_yoyo_motion(delta)
	# Update the strings information
	update_string()
	# If not paused then update arrays holding simulation data
	if !paused && !current_sim_finished:
		DataCollection.capture_data({
			"theta": theta,
			"omega": omega,
			"vy": vy,
			"tension_force": tension_force,
			"acceleration": acceleration
		})

# Set up basic values for the Yo-Yo and the string
# This along with update_string() took a lot of messing up
# Essentially positions an endpoint and start point based on the axle position, calculates a mid point 
# to place the string, and ensures the others parts are correctly placed
func setup():
	# Set y position of system to axle y position
	axis_initial_global_position_y = axle.global_position.y
	startPoint.global_position.y += (stringHeight * scaleFactor * 0.5)
	startPoint.global_position.x = axle.global_position.x + axle_radius
	stringBody.position.x = axle.global_position.x + axle_radius
	endPoint.global_position.x = axle.global_position.x + axle_radius
	
	$YoYoBody/RoundDiskFront.global_position.y = axis_initial_global_position_y
	$YoYoBody/RoundDiskFront.global_position.z = axle.global_position.z - $YoYoBody/Axle.mesh.height * 0.5 
	$YoYoBody/RoundDiskBack.global_position.y = axis_initial_global_position_y
	$YoYoBody/RoundDiskBack.global_position.z = axle.global_position.z + $YoYoBody/Axle.mesh.height * 0.5

# Used to update disk parts 
func update_yoyo_body():
	$YoYoBody/RoundDiskFront.global_position.z = axle.global_position.z - $YoYoBody/Axle.mesh.height * 0.5 
	$YoYoBody/RoundDiskBack.global_position.z = axle.global_position.z + $YoYoBody/Axle.mesh.height * 0.5

# Update the position of the String 
# This was the most time consuming part, well the string in general. 
# There were times when the string shrinked into oblivion, or streched into oblivion
# So many bugs with the string
func update_string():
	# Calculate string positions
	endPoint.global_position.y = axle.global_position.y
	stringLength = (startPoint.global_position.y - endPoint.global_position.y)
	stringBody.mesh.height = stringLength 
	stringHeight = stringBody.mesh.height
	# Calculate midpoint between start and end points
	var midpoint = (startPoint.position.y + endPoint.position.y * scaleFactor) * 0.5 
	stringBody.position.y = midpoint

# Move the model of the Yo-Yo based onthe calculated values for acceleration and Rotate baed on omega
func update_yoyo_motion(delta):
	# Calculate vertical displacement from the initial y position
	var displacement = abs(axle.global_position.y - axis_initial_global_position_y)
	
	# Check for maximum height
	if displacement < h_max && !paused:
		# Update vertical motion due to gravity with slight reduction due to tension
		vy += -acceleration*delta
		# Update the position of the system 
		yoyoBody.position.y += vy * delta
		if camera_locked:
			$"../Camera3D".global_position.y += vy * delta
		# Update angular velocity and the total theta change
		omega += alpha * delta                         # New angular velocity
		theta += omega * delta                         # New angle (theta) based on updated angular velocity
	elif displacement > h_max:
		current_sim_finished = true
	# Rotate the axle and both disks based on the updated angle
	yoyoBody.rotate(Vector3(0, 0, 1), deg_to_rad(theta) )    

# Reset the simulation to the base values
func reset_simulation():
	# Reset position and angular variables
	theta = 0.0                   # Reset angle
	omega = 0.0                   # Reset angular velocity
	alpha = 0.0                   # Reset angular acceleration
	vy = 0.0                      # Reset vertical velocity
	
	
	# Reset sim finished boolean
	current_sim_finished = false
	
	# Reset camera position
	$"../Camera3D".global_position = cameraLockedPosition
	# Re-init the base values and calculations
	init_physics()

	# Reset yoyo body position and rotation
	yoyoBody.global_position = Vector3(yoyoBody.global_position.x, axis_initial_global_position_y, yoyoBody.global_position.z)
	yoyoBody.rotation_degrees = Vector3(0, 0, 0)  # Reset rotation

	# Reset string and connection point positions
	startPoint.global_position.y = axis_initial_global_position_y + 0.25
	endPoint.global_position = axle.global_position
	stringBody.global_position = yoyoBody.global_position
	
	# Reset string length and midpoint
	stringLength = endPoint.global_position.distance_to(startPoint.global_position)
	stringBody.mesh.height = stringLength
	stringBody.position = (startPoint.position + endPoint.position) * 0.5

# Inertia calculation functions, making sure they are floats because I passed in a constant and debugged it for a while 
# TODO - Might update rest of functions later to be type specific if I have time 
func calculate_disk_inertia(mass: float, radius: float) -> float:
	return mass * radius**2
func calculate_square_inertia(mass: float, side_length: float) -> float:
	return (2/6) * mass * side_length**2
func calculate_ring_inertia(mass: float, inner_radius: float, outer_radius: float) -> float:
	return 2* 0.5 * mass * (inner_radius**2+ outer_radius**2)

# Final Moment of Inertia calculation function
# Based on the input shape the axle inertia is added tot he shapes inertia value
# Due to how my calculations are basing this as a primitive yo-yo, I really shouldnt be adding this inertia value. Might change it out, but it doesn't change a lot. Running out of time
func calculate_moment_of_inertia(shape):
	
	var I_axle = (1/2) * axle_mass * axle_radius**2 
	
	if shape == ShapeType.DISK:
		return calculate_disk_inertia(disk_mass, disk_radius) + I_axle
	elif shape == ShapeType.SQUARE:
		return calculate_square_inertia(disk_mass, axle_length) + I_axle # Using axle length as temp var while shape changing is not working
	elif shape == ShapeType.RING:
		var inner_radius
		var outer_radius 
		return calculate_ring_inertia(disk_mass, inner_radius, outer_radius) + I_axle
	else:
		return 0  # Default if shape does not match

## Called to export data to a TSV file (Tab Separated Values), tried the CSV, for some reason not working well. Using TSV as alt. The String is where you want the file.
#func export_data_to_tsv(file_path: String):
	#var file = FileAccess.open(file_path, FileAccess.ModeFlags.WRITE)
	#if file:
		## Write headers 
		#file.store_line("Frame\tTimeScale (s)\tOmega (rad/s)\tSpeed (m/s)\tHeightFallen (m)")
		#
		## Write data to file
		#for i in range(omega_values.size()):
			#var frame = i * frame_constraint
			#var omega = omega_values[i]
			#var time_scale_value = time_scale_values[i]
			#var speed = speed_values[i]
			#var height_fallen = height_fall_values[i]
			#file.store_line(str(frame) + "\t" + str(time_scale_value) + "\t" + str(omega) + "\t" + str(speed) + "\t" + str(height_fallen))
		#
		#file.close()  # Don't forget to close the file after writing
	#else:
		#print("Failed to open file for writing.")

# Function to initialize physics calculations for the yo-yo simulation
func init_physics():
	
	# Calculate inertia based on shape
	moment_of_inertia = calculate_moment_of_inertia(current_shape)
	# Calculate weight 
	total_weight = 2 * disk_mass + axle_mass
	# Calculate weight force (N)
	weight_force = total_weight * g                   
	# Calculate tesion (N)
	tension_force = weight_force/3
	# Calculate net force (N)
	net_force = weight_force - tension_force          
	# Calculate acceleration of system (m/s)
	acceleration = net_force/total_weight
	# Calculate torque (N*m)
	torque = tension_force * disk_radius              
	
	# Update angular acceleration using torque and moment of inertia (rad/s^2)
	alpha = torque / moment_of_inertia             

func toggle_pause():
	paused = !paused

# Pause button connection
func _on_check_button_toggled(button_pressed):
	toggle_pause()

# Start button connection
func _on_start_pressed():
	if paused:
		toggle_pause()

# Reset button connection
func _on_reset_pressed():
	reset_simulation()

# Time Scale Slider connection
func _on_slider_panel_slider_time_value_change(value):
	time_scale = value

# Disk radius slider connection
func _on_slider_panel_slider_radius_value_change(value):
	$YoYoBody/RoundDiskFront.mesh.top_radius = value
	$YoYoBody/RoundDiskFront.mesh.bottom_radius = value
	disk_radius = value
	init_physics()

## Trying to figure out data export
## Should get called every frame
#func tsv_test():
	## Rate of saving data by the frames passed
	#frame_counter += 1
	#if frame_counter >= frame_constraint:
		## Append data to relevant arrays
		#omega_values.append(omega)
		#time_scale_values.append(time_scale)
		#speed_values.append(abs(vy))
		#height_fall_values.append(stringLength - 0.25)
		#frame_counter = 0  # Reset frame counter
		#print("Omega tracked: ", omega, " TimeScale tracked: ", time_scale, " Speed tracked: ", abs(vy), " Height Fallen tacked: ", String("%.5f" % stringLength))

# Disk mass slider connection
func _on_slider_panel_slider_disk_mass_value_change(value):
	disk_mass = value
	# Recalculate physics
	init_physics()

# Axle 'height' (or length) slider connection
func _on_slider_panel_slider_axle_height_value_change(value):
	$YoYoBody/Axle.mesh.height = value
	# Recalculate phyics
	init_physics()
	# Reposition parts
	update_yoyo_body()


func _on_export_data_pressed():
	var headers = ["Frame", "Theta", "Omega", "Vy", "Tension Force", "Acceleration"]  # Add headers for each tracked variable
	var file_path = "E:/Godot Projects/Yo-Yo/csv/data_values.tsv"  # Choose your file path
	DataCollection.export_data_to_tsv(file_path, headers)


func _on_slider_panel_slider_axle_radius_value_change(value):
	$YoYoBody/Axle.mesh.top_radius = value
	$YoYoBody/Axle.mesh.bottom_radius = value
	axle_radius = value
	init_physics()


func _on_slider_panel_slider_axle_mass_value_change(value):
	axle_mass = value
	# Recalculate physics
	init_physics()
