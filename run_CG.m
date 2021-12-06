set_CryoGridPath;

%-----------------------------
% modified by user
%init_format = 'EXCEL3D'; %EXCEL or YAML
init_format = 'EXCEL';

run_name = 'example3';

constant_file = 'CONSTANTS_excel'; %file with constants
result_path = './results/';  %with trailing backslash

% end modified by user
%------------------------

%providers
provider = PROVIDER;
provider = assign_paths(provider, init_format, run_name, result_path, constant_file);
provider = read_const(provider);
provider = read_parameters(provider);


% %creates the RUN_INFO class
 [run_info, provider] = run_model(provider);

 [run_info, tile] = run_model(run_info);


