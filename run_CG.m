modules_path = 'CryoGrid/modules';
addpath(genpath(modules_path));

init_format = 'EXCEL'; %EXCEL or YAML
run_name = 'test'; %parameter file name and result directory 
constant_file = 'CONSTANTS_excel'; %file with constants
result_path = './results/';  %with trailing backslash
forcing_path = fullfile('./forcing/');

pprovider = PPROVIDER_EXCEL(run_name, result_path, constant_file, forcing_path);
pprovider = read_const(pprovider);
pprovider = read_parameters(pprovider);

%creates the RUN_INFO class
[run_info, pprovider] = run(pprovider);
[run_info, tile] = run(run_info);

