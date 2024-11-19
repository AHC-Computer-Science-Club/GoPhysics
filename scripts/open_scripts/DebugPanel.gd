extends Control

# This will hold the labels for parameter names and their corresponding value labels
var parameter_labels: Dictionary = {}

# This will hold the passed dictionary of parameters (the callable references)
var parameters: Dictionary = {}

func setup_parameters(passed_parameters: Dictionary):
	parameters = passed_parameters  # Store the passed dictionary
	# Create labels for each parameter
	for param_name in parameters.keys():
		if not parameters[param_name] is Callable:
			push_error("Value for '%s' must be a Callable." % param_name)
			continue

		# Create the label for the parameter name
		var name_label = Label.new()
		name_label.text = param_name.capitalize()
		$Panel/GridContainer.add_child(name_label)

		# Create the label for the parameter value (initially set to 0.0000)
		var value_label = Label.new()
		value_label.text = "0.0000"
		$Panel/GridContainer.add_child(value_label)

		# Store the value label in the dictionary for later updates
		parameter_labels[param_name] = value_label


# This method updates the labels with the actual parameter values every frame
func _process(delta):
	$Panel.size.x = $Panel/GridContainer.size.x
	$Panel.size.y = $Panel/GridContainer.size.y
	for param_name in parameter_labels.keys():
		var callable = parameters.get(param_name)
		if callable and callable.is_valid():
			var value = callable.call()  # Call the function to get the current value
			parameter_labels[param_name].text = String("%.5f" % value)
