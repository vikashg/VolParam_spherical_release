%% Read files from DTISearch
clc; clear all;

%loadData_interpolated_ADNI_DOD;
load_data_index_coord;
gridSize_wPadding = gridSize + Padding;
sx=gridSize_wPadding(1); sy = gridSize_wPadding(2); sz = gridSize_wPadding(3);
numOfVoxels=sx*sy*sz;
TotalNumberOfPoints=length(vertices);
points=zeros(TotalNumberOfPoints, 3);
for i=1:TotalNumberOfPoints
    points(i,:) = vertices(i,:) + Padding/2;
end

%% Create Data Structure
voxData=ones(sx,sy,sz,5);

for i = 1:TotalNumberOfPoints
    x=points(i,1); y=points(i,2); z= points(i,3);
    voxData(x,y,z,1)=2;
    voxData(x,y,z,2)=10;
    voxData(x,y,z,3)=rand()*potential_multiplier;
    
end

%% Mark Boundary Voxels
%plot3(test(:,1), test(:,2), test(:,3),'.')
temp_flag_val=10;
voxData = MarkBoundaryVer4(voxData, sx, sy,sz, temp_flag_val);
count_BoundVox=0;
boundVox=[];
for i = 1:gridSize_wPadding(1)
    for j = 1: gridSize_wPadding(2)
        for k = 1: gridSize_wPadding(3)
            if (voxData(i,j,k,2) == 100)
                 voxData(i,j,k,1) = 3;
                voxData(i,j,k,2) = 10;
                voxData(i,j,k,3) = 1.0*potential_multiplier;
                 count_BoundVox = count_BoundVox+1;
                 boundVox=[boundVox; [i,j,k]];
            end
        end
    end
end

% % For the moment not layering the potentials 

flag = 3;
temp_flag_val=10;
voxData = MarkBoundaryVer4(voxData, sx, sy,sz, temp_flag_val);

for i = 1:gridSize_wPadding(1)
    for j = 1: gridSize_wPadding(2)
        for k = 1: gridSize_wPadding(3)
            if (voxData(i,j,k,2) == 100)
                voxData(i,j,k,1) = 4;
                voxData(i,j,k,2) = 10;
                voxData(i,j,k,3) = 1.5*potential_multiplier;
            end
        end
    end
end


flag = 4;
temp_flag_val=10;
voxData = MarkBoundaryVer4(voxData, sx, sy,sz,temp_flag_val );
test3=[];
for i = 1:gridSize_wPadding(1)
    for j = 1: gridSize_wPadding(2)
        for k = 1: gridSize_wPadding(3)
            if (voxData(i,j,k,2) == 100)
                voxData(i,j,k,1) = 5;
                voxData(i,j,k,2) = 10;
                voxData(i,j,k,3) = 2.0*potential_multiplier;
                test3=[test3; [i,j,k]];
            end
        end
    end
end

% Assign potential to outSidePoints

for i=1:sx
    for j =1:sy
        for k=1:sz
            if (voxData(i,j,k, 1) ==1)
                voxData(i,j,k,3)=5*potential_multiplier;
            end
        end
    end
end

% Dont change anything so far all good


 %% Laplace Comptation
 voxData = LaplaceSolver(voxData, shapeCenter, gridSize_wPadding, eps);
[streamlines] = odeSolver(voxData, boundVox, count_BoundVox, stepSizeforStreamLines, shapeCenter);
ComputePointsonSphere;

ResampleStreamLines_1;
thetaVector=ComputeTheta(streamlines_uniq_resampled, stepSizeforStreamLines, shapeCenter);
thetaVector_unique=unique(thetaVector, 'rows');

output_dir=strcat(dir, 'Spherical_intersect');
mkdir(output_dir);
cd output_dir
save streamlines;
