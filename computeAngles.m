function [ surface_angles ] = computeAngles( list_clusters,clusterSize,number_of_clusters )
%COMPUTEANGLES Summary of this function goes here
%   Detailed explanation goes here
    
    % Local variables
    surface_angles = zeros(number_of_clusters);

    fprintf('Calculating angles between planes...');
    for i=1:9
        % 100 points sampled is enough to calculate angle
        one = datasample(list_clusters(i,1:clusterSize(i),:),100);
        one = reshape(one,[100,3]);
        [plane,fit,N1] = fitplane(one(:,:));
        for y=1:9
            if i ~= y
                two = datasample(list_clusters(y,1:clusterSize(y),:),100);
                two = reshape(two,[100,3]);
                [plane,fit,N2] = fitplane(two(:,:));
                % Computing the angle between two planes
                surface_angles(i,y) = rad2deg(atan2(norm(cross(N1,N2)),dot(N1,N2)));
                if surface_angles(i,y) > 90.0
                    surface_angles(i,y) = 180 - surface_angles(i,y);
                end
            else
                surface_angles(i,y) = 0;
            end
        end
    end
end

