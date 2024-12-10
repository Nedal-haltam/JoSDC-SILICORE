Our submission contains the following:
	- Folders:
		- PipeLine
		- SingleCycle
		- MIPSAssembler
		- CycleAccurateSimulator
		- RealTimeCAS
		- CommonLibraries
		- BenchMarkFolder
	- Files:
		- Development Phase Report
		- And this README
		- A recording explains the flow of the system built:


FOR THE HARDWARE PART

The PipeLine folder (or the SingleCycle folder) contains the hardware design of the CPU (Verilog)
- Simulation, and for simulation there are two approaches could be taken:

	- Using Visual Studio Code (VS Code)
		NOTE: you should run the commands from inside the PipeLine folder (or the SingleCycle folder with specifying instead of "PipeLine_sim.v" you replace it with "SingleCycle_sim.v")
		- you can run the simulation by running the required command using iverilog refer to the example below
			- Example: 
				- Run this command first: iverilog -o NAME_TO_OUTPUT_VVP_FILE -D vscode -D VCD_OUT=\""NAME_TO_OUTPUT_WAVEFORM"\" "PipeLine_sim.v"
				- and then run this command to start simulating: vvp NAME_TO_OUTPUT_VVP_FILE
			the advantage you get is that running the simulation through VS Code is mush faster that ModelSim
			you can read the Run.sh script in the BenchMarkFolder to see how we utilized the commands in order to automate the validation and testing process

	- Using Quartus and get redirected to ModelSim:
		- Points to check before compiling and running the RTL simulation:
			- make sure to specify the comrrect path to ModelSim
			- make sure to set the PipeLine_sim.v (or SingleCycle_sim.v) as the top level entity so it simulates the correct testbench
		- Then, you can start the Analysis and Elaboration process in quartus. After that you can go to Tools -> Run Simulation Tool -> RTL Simulation
		it will open a ModelSim Window and run the simulation. It will ask you if you want to finish press `No` so you proceed to the waveforms displayed.
		If you want more signals to display you can add them to the waveform tab and run the simulation again from ModelSim.

FOR THE SOFTWARE PART

In terms of software we have the following Architecture: TODO: complete steps on how to use these things

Three Application:
	- MIPSAssembler
	- Cycle Accurate Simulator (CAS)
	- Real Time CAS
Three Libraries:
	- MIPSASSEMBLER
	- LibCPU
	- LibAN