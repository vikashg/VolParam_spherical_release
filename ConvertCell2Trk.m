function tracks_interp_flipped = ConvertCell2Trk(tracks_cell, Padding, voxDim, header, points_origin, number_of_points)

num_tracks = length(tracks_cell);

for i=1:1:num_tracks
    a= tracks_cell{i};
    a_tmp=zeros(length(a), 3);
    for j=1:3
      a_tmp(:,j) = (a(:,j) - Padding(j)/2).*voxDim(j);
    end
    tracks_new(i).nPoints = length(a);
    tracks_new(i).matrix = a_tmp;

end
tracks_interp = trk_interp(tracks_new, number_of_points);
tracks_interp_str = trk_restruc(tracks_interp);
tracks_interp_flipped    = trk_flip(header, tracks_interp_str, points_origin);
% whos tracks_interp_flipped
% tracks_interp_str_flipped = trk_restruc(tracks_interp_flipped);
% whos tracks_interp_str_flipped



end
