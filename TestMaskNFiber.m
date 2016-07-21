data_dir='/Users/vgupta/Documents/Data/PPMI/3101_007_Baseline/';
maskimage=strcat(data_dir, '3101_007_Baseline_connectSubCort_labels.nii');

FAimage = load_nii(maskimage);

trk_file_path = strcat(data_dir, '3101_track.trk');
[header, tracks ] = trk_read (trk_file_path);

voxDim = img.hdr.dime.pixdim(2:4);
Padding=[20, 20, 20];
track_cell = ConvertTrk2Cell(tracks, Padding, voxDim);

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

vertices_idx_ROIs =zeros(tot_vox, 4);
count=1;
for i=1:sizeFA(1)
    for j=1:sizeFA(2)
        for k=1:sizeFA(3)
            if (FAimage.img(i,j,k) > 0)
                roi_number=FAimage.img(i,j,k);
                vertices_idx_ROIs(count, :) = [i,j,k, roi_number];
                count=count+1;
            end
        end
    end
end

roi_1=find(vertices_idx_ROIs(:,4)==2);
roi_1_vertices = zeros(length(roi_1), 3);

for i =1:length(roi_1)
    roi_1_vertices(i,:) = vertices_idx_ROIs(roi_1(i), 1:3);
end

hold on; grid on; 
plot3(roi_1_vertices(:,1), roi_1_vertices(:,2), roi_1_vertices(:,3), '.');

% 
% for i=1:3
% vertices(:,i) = vertices_idx(:,i) + Padding(1)/2;
% end
% figure(); hold on; grid on;
% plot3(vertices(:,1), vertices(:,2), vertices(:,3), '.');
% for i=1:100:length(track_cell)
%     a=track_cell{i};
%     plot3(a(:,1), a(:,2), a(:,3));
% end
% axis equal
% 
