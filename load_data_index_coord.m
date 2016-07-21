%% load Data
clc; clear all;
subj='3101'
dir=strcat('/Users/vgupta/Documents/Data/PPMI/',subj,'/');
output_dir=strcat(dir, 'VolParam');
mkdir(output_dir);
% image=strcat(subj, '_DWI_EPI_3d_bin_mask.nii');
image=strcat(subj, '_FA.nii');

trk_file=strcat(subj,'_DWI_1_Hough_10k_Tractography.trk');
%% % Change above


trk_file_path=strcat(dir, trk_file);

FA_image_path=strcat(dir, image);
FAimage=load_nii(FA_image_path);
shapeCenter_woPad = [58, 58, 37];
Padding =[20, 20, 20];

shapeCenter=shapeCenter_woPad + Padding/2;

%% Make the point cloud
sizeFA=size(FAimage.img);
count=0;
for i=1:sizeFA(1)
    for j =1:sizeFA(2)
        for k=1:sizeFA(3)
            if (FAimage.img(i,j,k) > 0)
               count=count+1;
            end
        end
    end
end

tot_vox=count;
count=1;
vertices_idx = zeros(tot_vox, 3);
for i=1:sizeFA(1)
    for j =1:sizeFA(2)
        for k=1:sizeFA(3)
            if (FAimage.img(i,j,k) > 0)
                vertices_idx(count, :)=[i,j,k];
                count=count+1;
            end
        end
    end
end

vertices=vertices_idx;
delete vertices_idx;
%% Usual stuff
gridSize=size(FAimage.img);
potential_multiplier=1;
stepSizeforStreamLines=100;
stepSizeStreamLinesPlot=100;
stepSizeforTracks=1;
stepSizeforTracksPlot=10;
eps=1e-1;

