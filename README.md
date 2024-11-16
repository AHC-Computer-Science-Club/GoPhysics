# GoPhysics
Simulations by AHC students made in Godot

I have not really manages a group project so I will take any advice or criticisim openly, so please be candid with your opinions.

Currently planning to create some tutorial videos for how to begin creating your simulations, as well as how to work with github for this project.

The only 'working' sim currently is the Simple Yo-Yo sim. You can control the shape of the yo yo to a degree with the sliders on the left side, and see values updated in real time on the right.
Start sim will begin the sim, pause will pause it - be warned that this setup is currently very 'hacky' for data collection so you have to be careful about the order of reseting the yo yo, pausing it, and exporting data
Speaking of exporting data, currently the csv folder actually holds a tsv file that gets overwritten each time the export call is made. Sorry, not sorry, had issues with csv and didn't rename things. I'll refactor it all later. 
