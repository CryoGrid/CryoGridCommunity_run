clear all

source_path = '../CryoGridCommunity_source/source'; 
addpath(genpath(source_path));

%-----------------------------
% user-modified part

param_file_path = '../CryoGridCommunity_results/'; 
run_name = 'test_run';

mkdir([param_file_path run_name]);
copyfile('templates/CONSTANTS_excel.xlsx', [param_file_path run_name]);

% simple parameter file for a single TILE
class_name = {'RUN_1D_STANDARD'; 'TILE_1D_standard'; 'FORCING_seb'; 'OUT_all_lateral'; 'GRID_user_defined'; 'STRAT_classes'; 'STRAT_layers'; 'STRAT_linear'; ...
    'GROUND_freezeC_bucketW_seb_snow'; 'GROUND_freeW_seb_snow'; 'SNOW_crocus_bucketW_seb'; 'LATERAL_1D'; 'LAT_SEEPAGE_FACE_WATER'};
class_number = [1; 1; 1: 1;1: 1; 1; 1;1;1;1;1;1;1; 1];
option = {''; 'new_init'; ''; ''; ''; ''; ''; ''; '';'';'';''; ''};

% %simple spin-up case
% class_name = {'RUN_1D_SPINUP'; 'TILE_1D_standard'; 'TILE_1D_standard'; 'FORCING_seb'; ...
%      'OUT_do_nothing'; 'OUT_all_lateral'; 'GRID_user_defined'; 'STRAT_classes'; 'STRAT_layers'; ...
%     'GROUND_freezeC_RichardsEqW_seb_snow'; 'GROUND_freeW_seb'; 'SNOW_crocus_bucketW_seb'; 'LATERAL_1D'};
% class_number = [1; 1; 2; 1; 1; 1; 1; 1: 1; 1; 1; 1;  1; 1;1];
% option = {''; 'new_init'; 'update_forcing_out';  ''; ''; ''; ''; ''; ''; ''; ''; '';'';};

%accelerated spin-up
% class_name = {'RUN_1D_SPINUP'; 'TILE_1D_standard'; 'TILE_1D_standard';'TILE_1D_standard';'TILE_1D_standard'; 'FORCING_seb'; 'FORCING_seb'; 'INIT_TTOP_from_out'; 'INIT_TTOP_from_forcing'; ...
%     'OUT_FDD_TDD'; 'OUT_do_nothing'; 'OUT_all_lateral'; 'GRID_user_defined'; 'STRAT_classes'; 'STRAT_layers'; ...
%     'GROUND_freeW_bucketW_seb_snow'; 'GROUND_freeW_seb'; 'SNOW_simple_bucketW_seb'; 'LATERAL_1D'; 'LAT_SEEPAGE_FACE_WATER'; 'LAT_WATER_RESERVOIR'; 'LAT_OVERLAND_FLOW'};
% class_number = [1; 1; 2; 3; 4; 1; 2; 1; 1; 1: 1; 1: 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1];
% option = {''; 'new_init_steady_state'; 'update_forcing_out'; 'new_init_steady_state'; 'update_forcing_out'; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; ''; '';'';'';''; ''; ''};

assign_default = 1; %1: enter default values where available; 0: do not enter default values 

% end user-modified part
%------------------------
% do not change
%-----------------------


statvar_list = {};
strat_statvar_locations = [];
spreadsheet = {};
j=1;
for class_num = 1:size(class_name,1)
    class = str2func(class_name{class_num,1});
    class = class();
    if isempty(option{class_num,1})
        class = param_file_info(class);
    else
        class = param_file_info(class,option{class_num,1});
    end
        
    
    %make STATVAR list
    for i=1:size(class.PARA.STATVAR,2)
        take=1;
        for jj=1:size(statvar_list,2)
            if strcmp(statvar_list{1,jj}, class.PARA.STATVAR{1,i})
                take=0;
            end
        end
        if take %new variable
            statvar_list = [statvar_list class.PARA.STATVAR(1,i)];
            for jj=1:size(strat_statvar_locations,1) %append to all STRAT_STATVAR classes
                spreadsheet(strat_statvar_locations(jj,1), strat_statvar_locations(jj,2)+1:size(spreadsheet,2)+1) = spreadsheet(strat_statvar_locations(jj,1), strat_statvar_locations(jj,2):end);
                spreadsheet(strat_statvar_locations(jj,1), strat_statvar_locations(jj,2)) = class.PARA.STATVAR(1,i);
                strat_statvar_locations(jj,2) = strat_statvar_locations(jj,2)+1;
            end
        end
    end
    
    %------------write the spreadsheet----
    spreadsheet(j,1)= {'-------------------'};
    j=j+1;
    spreadsheet(j,1) = {class.PARA.class_category};
    spreadsheet(j,2) = {'index'};
    j=j+1;
    spreadsheet(j,1) = {class_name{class_num,1}};
    spreadsheet(j,2) = {class_number(class_num,1)};
    j=j+1;
    if ~isempty(class.PARA.default_value)
        spreadsheet(j,3) = {'default value'};
    end
    j=j+1;
    fn = fieldnames(class.PARA);
    for i=1:size(fn,1)
        if ~strcmp(fn{i,1},'class_category') && ~strcmp(fn{i,1},'default_value') && ~strcmp(fn{i,1},'options') && ~strcmp(fn{i,1},'comment') && ~strcmp(fn{i,1},'STATVAR')
            spreadsheet(j,1) = fn(i,1);
            spreadsheet(j,2) = {'assign value'};
            %default
            if ~isempty(class.PARA.default_value)
                fn2 = fieldnames(class.PARA.default_value);
                for ii=1:size(fn2,1)
                    if strcmp(fn2{ii,1}, fn{i,1})
                        %spreadsheet(j,3) = {class.PARA.default_value.(fn2{ii,1})};
                        spreadsheet(j,3) = class.PARA.default_value.(fn2{ii,1});
                        if assign_default && ~isempty(class.PARA.default_value.(fn2{ii,1}))
                            %spreadsheet(j,2) = {class.PARA.default_value.(fn2{ii,1})};
                            spreadsheet(j,2) = class.PARA.default_value.(fn2{ii,1});
                        end
                    end
                end
            end
            %comment
            if ~isempty(class.PARA.comment) && isfield(class.PARA.comment, fn{i,1}) && (isempty(class.PARA.options) || ~isfield(class.PARA.options, fn{i,1}))
                spreadsheet(j,4) = class.PARA.comment.(fn{i,1});
            end
            
            if ~isempty(class.PARA.options)
                %write STRAT_MATRIX
                if isfield(class.PARA.options, fn{i,1}) && isfield(class.PARA.options.(fn{i,1}), 'name') && strcmp(class.PARA.options.(fn{i,1}).name, 'STRAT_MATRIX')
                    spreadsheet(j,2) = {'STRAT_MATRIX'};
                    if isfield(class.PARA.options.(fn{i,1}), 'entries_x')
                        spreadsheet(j,3:3-1+size(class.PARA.options.(fn{i,1}).entries_x, 2)) = class.PARA.options.(fn{i,1}).entries_x;
                        spreadsheet(j,3+size(class.PARA.options.(fn{i,1}).entries_x, 2)) = {'END'};
                        if ~isempty(class.PARA.comment) && isfield(class.PARA.comment, fn{i,1})
                            spreadsheet(j,3+size(class.PARA.options.(fn{i,1}).entries_x, 2)+1) = class.PARA.comment.(fn{i,1});
                        end
                    elseif isfield(class.PARA.options.(fn{i,1}), 'is_statvar_matrix') && class.PARA.options.(fn{i,1}).is_statvar_matrix == 1
                        spreadsheet(j,3:3-1+size(statvar_list, 2)) = statvar_list;
                        strat_statvar_locations = [strat_statvar_locations; [j 3+size(statvar_list,2)]];
                        spreadsheet(j, 3+size(statvar_list, 2)) = {'END'};
                        if ~isempty(class.PARA.comment) && isfield(class.PARA.comment, fn{i,1})
                            spreadsheet(j,3+size(statvar_list, 2)+1) = class.PARA.comment.(fn{i,1});
                        end
                    else
                        spreadsheet(j,3) = {'END'};
                        if ~isempty(class.PARA.comment) && isfield(class.PARA.comment, fn{i,1})
                            spreadsheet(j,4) = class.PARA.comment.(fn{i,1});
                        end
                    end
                    
                    if isfield(class.PARA.options.(fn{i,1}), 'entries_y')
                        spreadsheet(j+1:j+size(class.PARA.options.(fn{i,1}).entries_y, 1), 2) = class.PARA.options.(fn{i,1}).entries_y;
                        j=j+size(class.PARA.options.(fn{i,1}).entries_y, 1)+1;
                        spreadsheet(j,2) = {'END'};
                    else
                        spreadsheet(j+2,2) = {'END'};
                        j=j+2;
                    end
                    
                    %write V_MATRIX
                elseif isfield(class.PARA.options, fn{i,1}) && isfield(class.PARA.options.(fn{i,1}), 'name') && strcmp(class.PARA.options.(fn{i,1}).name, 'V_MATRIX')
                    spreadsheet(j,2) = {'V_MATRIX'};
                    if isfield(class.PARA.options.(fn{i,1}), 'entries_x')
                        spreadsheet(j,3:3-1+size(class.PARA.options.(fn{i,1}).entries_x, 2)) = class.PARA.options.(fn{i,1}).entries_x;
                        spreadsheet(j,3+size(class.PARA.options.(fn{i,1}).entries_x, 2)) = {'END'};
                        if ~isempty(class.PARA.comment) && isfield(class.PARA.comment, fn{i,1})
                            spreadsheet(j,3+size(class.PARA.options.(fn{i,1}).entries_x, 2)+1) = class.PARA.comment.(fn{i,1});
                        end
                    end
                    if isfield(class.PARA.options.(fn{i,1}), 'entries_matrix')
                        spreadsheet(j+1:j+size(class.PARA.options.(fn{i,1}).entries_matrix, 1),3:3-1+size(class.PARA.options.(fn{i,1}).entries_matrix, 2)) = class.PARA.options.(fn{i,1}).entries_matrix;
                        spreadsheet(j,3+size(class.PARA.options.(fn{i,1}).entries_matrix, 2)) = {'END'};
                        if ~isempty(class.PARA.comment) && isfield(class.PARA.comment, fn{i,1})
                            spreadsheet(j,3+size(class.PARA.options.(fn{i,1}).entries_matrix, 2)+1) = class.PARA.comment.(fn{i,1});
                        end
                        j=j+size(class.PARA.options.(fn{i,1}).entries_matrix, 1)+1;
                        spreadsheet(j,2) = {'END'};
                    else
                        spreadsheet(j,3) = {'END'};
                        if ~isempty(class.PARA.comment) && isfield(class.PARA.comment, fn{i,1})
                            spreadsheet(j,4) = class.PARA.comment.(fn{i,1});
                        end
                        spreadsheet(j+2,2) = {'END'};
                        j=j+2;
                    end
                    
                    
                    %write MATRIX
                elseif isfield(class.PARA.options, fn{i,1}) && isfield(class.PARA.options.(fn{i,1}), 'name') && strcmp(class.PARA.options.(fn{i,1}).name, 'MATRIX')
                    spreadsheet(j,2) = {'MATRIX'};
                    if isfield(class.PARA.options.(fn{i,1}), 'entries_matrix')
                        spreadsheet(j+1:j+size(class.PARA.options.(fn{i,1}).entries_matrix, 1),3:3-1+size(class.PARA.options.(fn{i,1}).entries_matrix, 2)) = class.PARA.options.(fn{i,1}).entries_matrix;
                        spreadsheet(j,3+size(class.PARA.options.(fn{i,1}).entries_matrix, 2)) = {'END'};
                        if ~isempty(class.PARA.comment) && isfield(class.PARA.comment, fn{i,1})
                            spreadsheet(j,3+size(class.PARA.options.(fn{i,1}).entries_matrix, 2)+1) = class.PARA.comment.(fn{i,1});
                        end
                        j=j+size(class.PARA.options.(fn{i,1}).entries_matrix, 1)+1;
                        spreadsheet(j,2) = {'END'};
                    else
                        spreadsheet(j,3) = {'END'};
                        if ~isempty(class.PARA.comment) && isfield(class.PARA.comment, fn{i,1})
                            spreadsheet(j,4) = class.PARA.comment.(fn{i,1});
                        end
                        spreadsheet(j+2,2) = {'END'};
                        j=j+2;
                    end
                    
                    %write H_LIST
                elseif isfield(class.PARA.options, fn{i,1}) && isfield(class.PARA.options.(fn{i,1}), 'name') && strcmp(class.PARA.options.(fn{i,1}).name, 'H_LIST')
                    spreadsheet(j,2) = {'H_LIST'};
                    if isfield(class.PARA.options.(fn{i,1}), 'entries_x')
                        spreadsheet(j,3:3-1+size(class.PARA.options.(fn{i,1}).entries_x, 2)) = class.PARA.options.(fn{i,1}).entries_x;
                        spreadsheet(j,3+size(class.PARA.options.(fn{i,1}).entries_x, 2)) = {'END'};
                        if ~isempty(class.PARA.comment) && isfield(class.PARA.comment, fn{i,1})
                            spreadsheet(j, 3+size(class.PARA.options.(fn{i,1}).entries_x, 2)+1) = class.PARA.comment.(fn{i,1});
                        end
                    else
                        spreadsheet(j,3) = {'END'};
                        if ~isempty(class.PARA.comment) && isfield(class.PARA.comment, fn{i,1})
                            spreadsheet(j,4) = class.PARA.comment.(fn{i,1});
                        end
                    end
                    
                end
            end
            
            j=j+1;
        end
    end
    spreadsheet(j,1) = {'CLASS_END'};
    
    j=j+3;
    
end

if exist([param_file_path run_name '/' run_name '.xlsx'], 'file')
    delete([param_file_path run_name '/' run_name '.xlsx']);
end
    
xlswrite([param_file_path run_name '/' run_name '.xlsx'], spreadsheet)