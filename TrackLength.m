function [ totalDistance ] = TrackLength( track_matrix )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

temp_size = size(track_matrix);
numPoints = temp_size(1);

distVector = zeros(numPoints-1,1);

for i=1:(numPoints -1)
    a=track_matrix(i,:);
    b=track_matrix(i+1, :);
    diff_ab=a-b;
    distVector(i) = norm(diff_ab);
end

totalDistance = sum(distVector);




end

