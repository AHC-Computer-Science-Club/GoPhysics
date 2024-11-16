extends Panel

@export var yoyoRoot: YoYoRoot
@onready var omega = yoyoRoot.omega
@onready var torque = yoyoRoot.torque
@onready var stringLength = yoyoRoot.stringLength
@onready var inertia = yoyoRoot.moment_of_inertia
@onready var weight = yoyoRoot.total_weight
@onready var stringHeight = yoyoRoot.stringHeight
@onready var theta = yoyoRoot.theta
@onready var acceleration = yoyoRoot.acceleration
@onready var alpha = yoyoRoot.alpha

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	omega = yoyoRoot.omega
	torque = yoyoRoot.torque
	stringLength = yoyoRoot.stringLength
	inertia = yoyoRoot.moment_of_inertia
	weight = yoyoRoot.total_weight
	stringHeight = yoyoRoot.stringHeight
	theta = yoyoRoot.theta
	acceleration = yoyoRoot.acceleration
	alpha = yoyoRoot.alpha
	
	$GridContainer/OmegaNumber.text = String("%.5f" % omega)
	$GridContainer/TorqueNumber.text = String("%.5f" % torque)
	$GridContainer/InertiaNumber.text = String("%.5f" % inertia)
	$GridContainer/StringLengthNumber.text = String("%.5f" % stringLength)
	$GridContainer/WeightNumber.text = String("%.5f" % weight)
	$GridContainer/StringHeightNumber.text = String("%.5f" % stringHeight)
	$GridContainer/ThetaNumber.text = String("%.5f" % theta)
	$GridContainer/AccelerationNumber.text = String("%.5f" % acceleration)
	$GridContainer/AlphaNumber.text = String("%.5f" % alpha)
