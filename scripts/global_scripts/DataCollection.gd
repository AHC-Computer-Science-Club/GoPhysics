extends Node

# Globals for data collection, parseing, etc

# TSV (Tab seperated values) section
var tracked_data = {} # Dictionary to store arrays of tracked values
var frames = [] # Array to track frames, used to determine row length of file
var tracker = 0

# Initialize data tracking with whatever 'keys', or tags/names things you are tracking
func init_tracking(keys: Array) -> void:
	for key in keys:
		tracked_data[key] = [] # Create empty arrays for each key
	frames.clear() # Empty the frame array for refresh

func capture_data(values: Dictionary) -> void:
	
	GlobalVariables.frame_counter += 1
	if GlobalVariables.frame_counter >= GlobalVariables.frame_constraint:
		# Track frames data is captured on 
		frames.append(GlobalVariables.frame_counter)
		
		for key in values.keys():
			if tracked_data.has(key):
				tracked_data[key].append(values[key])
				
		GlobalVariables.frame_counter = 0

func export_data_to_tsv(file_path: String, headers: Array) -> void:
	
	var file = FileAccess.open(file_path, FileAccess.ModeFlags.WRITE)
	if file:
		# First create a new string by splitting up the headers array
		# Then replace commas with tabs (Note to do csv exports just keep the commas
		var header_line = String("\t".join(headers.map(str)))
		file.store_line(header_line)
		
		# Now we write the rest of the data to file
		var row_count = frames.size()
		for i in range(row_count):
			var frame = i * GlobalVariables.frame_constraint
			var row = [str(frame)] 
			
			for key in tracked_data.keys():
				if tracked_data.has(key):
					row.append(str(tracked_data[key][i]))
					
			var row_line = String("\t".join(row.map(str)))
			file.store_line(row_line)
			
		file.close()
	else:
		print("File failed to open for writing")
