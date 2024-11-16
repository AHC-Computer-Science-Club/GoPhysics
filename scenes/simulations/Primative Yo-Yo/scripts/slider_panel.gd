extends Panel

# Export to specify yoyo
@export var yoyoRoot: YoYoRoot

# I dont know why these are here
@onready var time_scale = yoyoRoot.time_scale
@onready var disk_radius = yoyoRoot.disk_radius

# Signals for sliders
signal slider_time_value_change(value) 
signal slider_radius_value_change(value)
signal slider_disk_mass_value_change(value)
signal slider_axle_height_value_change(value)
signal slider_axle_radius_value_change(value)
signal slider_axle_mass_value_change(value)

# Intialized values for representing the sliders
@onready var time_value = $TimeSlider/SliderTime.value
@onready var disk_radius_value = $DiskRadius/SliderDiskRadius.value
@onready var disk_mass_value = $DiskMass/SliderDiskMass.value
@onready var axle_height_value = $AxleHeight/SliderAxleHeight.value
@onready var axle_radius_value = $AxleRadius/SliderAxleRadius.value
@onready var axle_mass_value = $AxleMass/SliderAxleMass.value
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Keep track of dynamic values
	time_value = $TimeSlider/SliderTime.value
	disk_radius_value = $DiskRadius/SliderDiskRadius.value 
	disk_mass_value = $DiskMass/SliderDiskMass.value
	axle_height_value = $AxleHeight/SliderAxleHeight.value
	axle_radius_value = $AxleRadius/SliderAxleRadius.value
	axle_mass_value = $AxleMass/SliderAxleMass.value
	
	# Set text values for labels for each slider
	$TimeSlider/SliderTime/Label.text = String("Time Value %.5f" % time_value + "(s)")
	$DiskRadius/SliderDiskRadius/Label.text = String("Disk Radius %.5f" % disk_radius_value + "(m)")
	$DiskMass/SliderDiskMass/Label.text = String("Disk Mass %.5f" % disk_mass_value + "(kg)")
	$AxleHeight/SliderAxleHeight/Label.text = String("Axle Height %.5f" % axle_height_value + "(m)")
	$AxleRadius/SliderAxleRadius/Label.text= String("Axle Radius %.5f" % axle_radius_value + "(m)")
	$AxleMass/SliderAxleMass/Label.text = String("Axle Mass %.5f" % axle_mass_value + "(kg)")



func _on_slider_time_value_changed(time_value):
	emit_signal("slider_time_value_change", time_value)


func _on_slider_disk_radius_value_changed(disk_radius_value):
	emit_signal("slider_radius_value_change", disk_radius_value)


func _on_slider_disk_mass_value_changed(value):
	emit_signal("slider_disk_mass_value_change", value)


func _on_slider_axle_height_value_changed(axle_height_value):
	emit_signal("slider_axle_height_value_change", axle_height_value)


func _on_slider_axle_radius_value_changed(value):
	emit_signal("slider_axle_radius_value_change", value)


func _on_slider_axle_mass_value_changed(value):
	emit_signal("slider_axle_mass_value_change", value)
