%-----------------------------
% user-modified part

%init_format = 'EXCEL'; 
%init_format = 'YAML';
init_format = 'EXCEL3D'; %choose the option corresponding to the parameter file format

result_path = '../CryoGridCommunity_results/';  

run_name = 'reference_run'; %run_name = name of parameter file (without file extension) and name of subfolder (in result_path) within which it is located

constant_file = 'CONSTANTS_excel'; %filename of file storing constants

% end user-modified part
%------------------------
% do not change
%-----------------------
%add source code path
source_path = '../CryoGridCommunity_source/source'; 
addpath(genpath(source_path));

%create and load PROVIDER
provider = PROVIDER;
provider = assign_paths(provider, init_format, run_name, result_path, constant_file);
provider = read_const(provider);
provider = read_parameters(provider);


% create RUN_INFO class
 [run_info, provider] = run_model(provider);
% run model
 [run_info, tile] = run_model(run_info);


