function MapTracks_grpFibers(data_dir, subj, tracks_file_name )
phots
% This is copied from MaptTracks_individualFibers
% Requirements are 
% 1. Main Data Dir
% 2. TracksFileName
% 3. SubjectName

streamlinesFile=strcat(data_dir, '/', subj, '/Spherical_intersect/streamlines.mat');
load(streamlinesFile);

output_dir=strcat(data_dir, '/', subj, '/', 'Mapped_tracks')
mkdir(output_dir)

track_cell_file=strcat(data_dir, '/',  subj, '/', 'VolParam/' , tracks_file_name,'.mat');
combine_tracks_loaded=load(track_cell_file);
combine_tracks_cell=combine_tracks_loaded.tracks_cell; %%% look here

numOfVoxels=sx*sy*sz;
potVector=ones(numOfVoxels, 4);
count=1;

%% Create Pot Vector 
numStreamLines=length(streamlines_uniq_resampled);
NewStreamLinePoints=zeros(101*numStreamLines, 3);

PotVector=zeros(101*numStreamLines,1);

k_start=1;
for i=1:numStreamLines
    k_end=i*101;
    a=streamlines_uniq_resampled{i};
    PotVector(k_start:k_end,:)=1.01:-0.01:.01;
    NewStreamLinePoints(k_start:k_end,:)=a;
    k_start = k_end+1;
    
end

NewStreamLines_vector=[NewStreamLinePoints PotVector];
unique_newStreamlines=unique(NewStreamLines_vector, 'rows');
Y_temp=NewStreamLines_vector(:,1:3);

Mdl_PotVector = KDTreeSearcher(Y_temp);

% Build theta_phi vector

X_temp=thetaVector_unique(:,1:3);
Mdl_ThetaVector = KDTreeSearcher(X_temp);

Mapped_tracks=cell(length(combine_tracks_cell),1);

for i=1:length(combine_tracks_cell)
    a=combine_tracks_cell{i};
   % plot3(a(:,1), a(:,2), a(:,3)); hold on; grid on;

    for j=1:length(a)
        coordinate=a(j,:);
        [theta_interp, phi_interp] = interpolate_Weighted_matlab(Mdl_ThetaVector, coordinate, thetaVector_unique);
        [pot_interp] = interpolate_pot_Weighted_matlab(Mdl_PotVector, coordinate, NewStreamLines_vector);
        mapped_tracks_i(j,:) = [theta_interp, phi_interp, pot_interp];
    end
    Mapped_tracks{i}=mapped_tracks_i;
end

output_file=strcat(output_dir, '/', 'Mapped_tracks_', tracks_file_name,'.mat');
save(output_file, 'Mapped_tracks');
