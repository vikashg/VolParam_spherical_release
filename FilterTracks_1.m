%% Filter the tracks based on distances 
clc; clear all;
subj='3165';
dir=strcat('/Users/vgupta/Documents/Data/PPMI/VolParam/',subj,'/');
image=strcat(subj, '_DWI_EPI_3d_bin_mask.nii');
FAimage = load_nii(strcat(dir, image));
num_points=100;
point_tracks=[9000, 9000, 000];
voxDim = FAimage.hdr.dime.pixdim(2:4);

length_threshold = 25;
trk_file=strcat(subj,'_EC_dwi_pico_tracts.trk');
trk_file_path=strcat(dir, trk_file);

[header, tracks ] = trk_read (trk_file_path);
tracks_interp = trk_interp(tracks, num_points);
tracks_interp_str = trk_restruc(tracks_interp);
tracks_interp     = trk_flip(header, tracks_interp, point_tracks);
tracks_interp_str_flipped = trk_restruc(tracks_interp);
sample_track_size=header.n_count;



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
for i=1:100:length(idx)
    index_i=idx(i);
    track_i = tracks(index_i);
    
    % Pad and convert to voxel coordinates
    b=zeros(track_i.nPoints, 3);
    for j =1 : track_i.nPoints
        b(j, :)  = track_i.matrix(j,:)./voxDim + Padding/2;
    end
    filtered_tracks{i} = b;
    plot3(b(:,1), b(:,2), b(:,3)); 
end

