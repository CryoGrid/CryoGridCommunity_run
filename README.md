# CryoGrid community model

This is the community version of *CryoGrid*, a numerical model to investigate land surface processes in the terrestrial cryosphere. This version of *CryoGrid* is implemented in MATLAB.

*Note: This is the latest development of the CryoGrid model family. It comprises the functionalities of previous versions including [CryoGrid3](https://github.com/CryoGrid/CryoGrid3), which is no longer encouraged to be used.*

## Documentation

A manuscript "The CryoGrid community model - a multi-physics toolbox for climate-driven simulations in the terrestrial cryosphere" has been submitted to the journal  Geoscientific Model Development (GMD) which contains a detailed description of the model and instructions to run it (Supplements 1, 3).

## Getting started

Both [CryoGridCommunity_source](https://github.com/CryoGrid/CryoGridCommunity_source) and [CryoGridCommunity_run](https://github.com/CryoGrid/CryoGridCommunity_run) are required and must be downloaded in the same folder. [CryoGridCommunity_source](https://github.com/CryoGrid/CryoGridCommunity_source) contains the model source code which users should not modify. [CryoGridCommunity_run](https://github.com/CryoGrid/CryoGridCommunity_run) contains the files that must be edited by the user. The script "run_CG.m" is used to start a simulation with the CryoGrid community model, and the user has to specify the name and location of a parameter file which controls all aspects of the model run (see GMD manuscript and Suppl. 1 for details). In addition, a script for displaying key variables of the model output (read_output_and_display.m), and a script to automatically create parameter files in spreadsheet format (create_parameter_file_EXCEL.m) are provided.

An instruction video on downloading the CryoGrid community model and running simple simulations is available here: https://www.youtube.com/watch?v=L1GIurc5_J4&t=372s
The parameter files and model forcing data for the simple simulations from the video can be downloaded here: http://files.artek.byg.dtu.dk/files/cryogrid/CryoGridExamples/CryoGrid_simpleExamples.zip 
