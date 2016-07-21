%% Tracks  
clc; clear all;
load_data_index_coord;
track_sample_size=100;
number_of_points_per_track=100;
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

plot3(boundVox(:,1), boundVox(:,2), boundVox(:,3),'.')
xlabel('X'); ylabel('Y'); zlabel('Z');

%Find the mid-line along X
min_boun = min(boundVox); 
max_boun = max(boundVox);

midline_X=(min_boun(1) + max_boun(1))/2;

% Read the tracks 
length_threshold = 25;
trk_file=strcat(subj,'_DWI_1_Hough_10k_Tractography.trk');
trk_file_path=strcat(dir, trk_file);
[header, tracks ] = trk_read (trk_file_path);
voxDim = FAimage.hdr.dime.pixdim(2:4);


num_tracks = length(tracks);
count =0;
for i=1:num_tracks
    track_i = tracks(i);
    if ((track_i.nPoints) > 1)
    count = count+1;
    end
end

track_length_vector = zeros(count, 1);
for i=1:num_tracks
    track_i = tracks(i);
    if ((track_i.nPoints) > 1)
    track_length_vector(i) = TrackLength(track_i.matrix);
    end
end

idx = find(track_length_vector > length_threshold);

%% Convert Tracks and convert to cell
filtered_tracks={};
figure(); hold on; grid on; 
plot3(boundVox(:,1), boundVox(:,2), boundVox(:,3),'.');
for i=1:track_sample_size:length(idx)
    index_i=idx(i);
    track_i = tracks(index_i);
    
    % Pad and convert to voxel coordinates
    b=zeros(track_i.nPoints, 3);
    for j =1 : track_i.nPoints
        b(j, :)  = track_i.matrix(j,:)./voxDim + Padding/2;
    end
    filtered_tracks{i} = b;
end

%% Separation Logic
% If both end points are in the same hemisphere its L or R 
% If the end ponts are in different hemispheres they are different

X_left = min_boun(1); X_mid = midline_X; X_right = max_boun(1);

filtered_tracks_l={};
filtered_tracks_r={};
filtered_tracks_c={};
count_l=0; count_r=0; count_c=0;
for i=1:track_sample_size:length(filtered_tracks)
    tracks_fil_i = filtered_tracks{i};
    start_point = tracks_fil_i(1,:);
    end_point = tracks_fil_i(end,:);
    
    if (((start_point(1) > X_left) & (start_point(1) < X_mid)) & ...
            ((end_point(1) > X_left) & (end_point(1) < X_mid)))
        count_l = count_l+1;
        filtered_tracks_l{count_l} = tracks_fil_i;
    
    
    elseif (((start_point(1) > X_mid) & (start_point(1) < X_right)) & ...
            ((end_point(1) > X_mid) & (end_point(1) < X_right)))
        count_r = count_r+1;
        filtered_tracks_r{count_r} = tracks_fil_i;
        
    else
        count_c = count_c +1;
        filtered_tracks_c{count_c} = tracks_fil_i;
    end
    
end


%% Check By plotting tracks
figure(); hold on; grid on;
for i=1:length(filtered_tracks_l);
    a=filtered_tracks_l{i};
    plot3(a(:,1), a(:,2), a(:,3)); 
end
plot3(boundVox(:,1), boundVox(:,2), boundVox(:,3), '.');
tracks_l = ConvertCell2Trk(filtered_tracks_l, Padding, voxDim, header, [9000, 9000, 0], number_of_points_per_track);
tracks_r = ConvertCell2Trk(filtered_tracks_r, Padding, voxDim, header, [9000, 9000, 0], number_of_points_per_track);
tracks_c = ConvertCell2Trk(filtered_tracks_c, Padding, voxDim, header, [9000, 9000, 0], number_of_points_per_track);

tracks_cell_l = ConvertTrk2Cell(tracks_l, Padding, voxDim);
tracks_cell_r = ConvertTrk2Cell(tracks_r, Padding, voxDim);
tracks_cell_c = ConvertTrk2Cell(tracks_c, Padding, voxDim);

tracks_cell=tracks_cell_l;
left_fiber_filename = strcat(output_dir, '/', 'Left_fiber.mat');
save(left_fiber_filename, 'tracks_cell');

tracks_cell=tracks_cell_r;
right_fiber_filename = strcat(output_dir, '/', 'Right_fiber.mat');
save(right_fiber_filename, 'tracks_cell');

tracks_cell=tracks_cell_c;
center_fiber_filename = strcat(output_dir, '/', 'Center_fiber.mat');
save(center_fiber_filename, 'tracks_cell');