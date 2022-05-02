%run header first

source_path = '../CryoGridCommunity_source/source'; 
addpath(genpath(source_path));

%then load an output file produced by an OUT_all or OUT_all_lateral class
%%

%user-modified part

surface_altitude = 20; %in m a.s.l., should normally match the the parameter "altitude" in TILE_1D_standard 
start_height_above_ground = 1; %in m
end_depth_below_ground = 3; %in m

%end user-modified part

source_path = '../CryoGridCommunity_source/source'; 
source_path = '../CryoGrid/source'; 
addpath(genpath(source_path));

target_cell_size = 0.02;
new_grid = surface_altitude - [-start_height_above_ground:target_cell_size:end_depth_below_ground]';
threshold = target_cell_size/10;  

%define target variables
result.T = [];
result.waterIce =[];
result.water = [];
result.ice = [];
%result.Xice = [];
%result.Xwater = [];
%result.XwaterIce = [];
%result.waterPotential = [];
result.class_number = [];
%must all have the same dimensions in all fields

variableList = fieldnames(result);
numberOfVariables = size(variableList,1);


for i=1:size(out.STRATIGRAPHY,2)
    
    altitudeLowestCell = out.STRATIGRAPHY{1,i}{end,1}.STATVAR.lowerPos;
    
    
    %read out and accumulate over all classes
    
    layerThick=[];
    area=[];
    
    for j=1:size(out.STRATIGRAPHY{1,i},1)
        layerThick=[layerThick; out.STRATIGRAPHY{1,i}{j,1}.STATVAR.layerThick];
        area=[area; out.STRATIGRAPHY{1,i}{j,1}.STATVAR.area];
    end
    layerThick_temp = layerThick;
    layerThick = zeros(size(layerThick,1).*2, 1).* NaN;
    layerThick(1:2:size(layerThick,1),1) = threshold;
    layerThick(2:2:size(layerThick,1),1) = layerThick_temp - threshold;
    
    area_temp = area;
    area=[area; area].* NaN;
    area(1:2:size(layerThick,1),1) = area_temp;
    area(2:2:size(layerThick,1),1) = area_temp;
    
    %     depths = [0; cumsum(layerThick)];
    %     depths = -(depths-depths(end,1));
    %     depths = (depths(1:end-1,1)+depths(2:end,1))./2 + altitudeLowestCell;
    
    
    temp=repmat(NaN, size(layerThick_temp,1), numberOfVariables);
    pos=1;
    for j = 1:size(out.STRATIGRAPHY{1,i},1)
        fieldLength = size(out.STRATIGRAPHY{1,i}{j,1}.STATVAR.layerThick,1);
        for k=1:numberOfVariables-1
            if any(strcmp(fieldnames(out.STRATIGRAPHY{1,i}{j,1}.STATVAR), variableList{k,1}))
                temp(pos:pos+fieldLength-1,k) = out.STRATIGRAPHY{1,i}{j,1}.STATVAR.(variableList{k,1});
            end
        end
        temp(pos:pos+fieldLength-1,numberOfVariables) = zeros(fieldLength,1) + size(out.STRATIGRAPHY{1,i},1)+1-j; %assigna class number starting with 1 from the bottom
        pos = pos+fieldLength;
    end
    
    %compute targate variables
    for k=1:numberOfVariables
        if strcmp(variableList{k,1}, 'saltConc')
            pos_waterIce = find(strcmp(variableList, 'waterIce'));
            temp(:,k) = temp(:,k)./ (temp(:,pos_waterIce) ./layerThick_temp./area_temp);  %divide by total water content
        end
    end
    
    for k=1:numberOfVariables
        if strcmp(variableList{k,1}, 'water') || strcmp(variableList{k,1}, 'ice') || strcmp(variableList{k,1}, 'waterIce') || strcmp(variableList{k,1}, 'XwaterIce') || strcmp(variableList{k,1}, 'Xwater') || strcmp(variableList{k,1}, 'Xice') || strcmp(variableList{k,1}, 'saltConc')
            temp(:,k) = temp(:,k)./layerThick_temp./area_temp;
        end
        %result.(variableList{k,1}) = [result.(variableList{k,1}) interp1(depths, temp(:,k), new_grid)];
    end
    
    temp_temp = temp;
    temp=[temp; temp].* NaN;
    temp(1:2:size(layerThick,1),:) = temp_temp;
    temp(2:2:size(layerThick,1),:) = temp_temp;
    
    %interpolate to new grid    
    depths = cumsum(layerThick);
    depths = depths - threshold/2;
    depths(1) = 0;
    depths = -(depths-depths(end,1));
    depths = depths + altitudeLowestCell;

    for k=1:numberOfVariables
        result.(variableList{k,1}) = [result.(variableList{k,1}) interp1(depths, temp(:,k), new_grid, 'nearest')];
    end
    
end

%plot
for i=1:numberOfVariables
    figure
    imAlpha = result.(variableList{i,1}) .*0 +1;
    imAlpha(isnan(result.(variableList{i,1})))= 0;
    imagesc(out.TIMESTAMP, new_grid, result.(variableList{i,1}),'AlphaData',imAlpha);
    axis xy
    datetick
    title(variableList{i,1})
    colorbar
end
