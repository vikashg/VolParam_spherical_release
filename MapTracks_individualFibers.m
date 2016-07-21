
function MapTracks_individualFibers(tracks_name_indiv)

%subj='0011813'
%subj='0012310'
subj='0035019'
%subj='0079847'
%subj='0112920'

data_dir='/ifs/loni/faculty/thompson/adni2/scan_1/Vikash_process/Softwares/VolParameterization_matlab/ExampleData/AD_DOD/'
sub_dir='/Geom/Spherical_intersect/'

streamlinesFile=strcat(data_dir, subj, sub_dir, 'streamlines.mat');

load(streamlinesFile);

tracks_name{1}='atr_l';
tracks_name{2}='atr_r';
tracks_name{3}='cc_frontal';
tracks_name{4}='cc_temporal';
tracks_name{5}='ifo_l';
tracks_name{6}='ifo_r';
tracks_name{7}='phc_r';
tracks_name{8}='unc_r';
tracks_name{9}='cc_prcg';

tracks_name{1}='atr_l';
tracks_name{2}='atr_r';
tracks_name{3}='cc_frontal';
tracks_name{4}='cc_occipital';
tracks_name{5}='cc_parietal';
tracks_name{6}='cc_pocg';
tracks_name{7}='cc_prcg';
tracks_name{8}='cc_temporal';
tracks_name{9}='cgc_l';
tracks_name{10}='cgc_r';

tracks_name{11}='cst_l';
tracks_name{12}='cst_r';
tracks_name{13}='ifo_l';
tracks_name{14}='ifo_r';
tracks_name{15}='ilf_l';
tracks_name{16}='ilf_r';
tracks_name{17}='phc_l';
tracks_name{18}='phc_r';
tracks_name{19}='slf_l';
tracks_name{20}='unc_l';
tracks_name{21}='unc_r';

output_dir=strcat(data_dir, subj, sub_dir, 'Mapped_tracks')
mkdir(output_dir)

track_cell_file=strcat(data_dir, subj, sub_dir, 'Indiv_fiber_set/', tracks_name_indiv,'.mat');
combine_tracks_loaded=load(track_cell_file);
combine_tracks_cell=combine_tracks_loaded.individual_track_cell;

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

output_file=strcat(output_dir, '/', 'Mapped_tracks_', tracks_name_indiv,'.mat');
save(output_file, 'Mapped_tracks');
