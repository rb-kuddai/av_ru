function [ listOfClusters,clusterSize ] = completeModel( xyzData, colours, number_of_clusters )
%COMPLETE_MODEL Plane growing implementation

% Sample data
data = datasample(xyzData,size(xyzData,1)/4);
figure(999);
plotPatch(data,colours,1,0)
pause(1)

% Local Variables
dim = 3; % keep track of data dimensionality
[NPts,W] = size(data);
remaining = data; % keep track of the non-segmented data
listOfClusters = zeros(number_of_clusters,size(xyzData/4,1),dim);
clusterSize = zeros(number_of_clusters,1);


for i = 1 : 9
    % select a random small surface patch
    [oldlist,plane,N] = select_patch(remaining);
    % grow patch
    stillgrowing = 1;
    while stillgrowing
        % find neighbouring points that lie in plane
        stillgrowing = 0;
        % get all points from the plane under observation
        [newlist,remaining] = getallpoints(plane,oldlist,remaining,NPts);
        [NewL,W] = size(newlist);
        [OldL,W] = size(oldlist);
        % plot results
        plotPatch( newlist,colours,8,i )
        % save cluster for analysis
        listOfClusters(i,1:size(newlist,1),:) = newlist;
        clusterSize(i) = size(newlist,1); % we need this for angle calculation
        pause(0.5) % wait for update
        % if exploration decreases significantly then just stop.
        if NewL > OldL + 50
            % refit plane
            [newplane,fit] = fitplane(newlist);
            if fit > 0.04*NewL       % bad fit - stop growing
                break
            end
            stillgrowing = 1;
            oldlist = newlist;
            plane = newplane;
        end
    end
    waiting=1;
    pause(0.5) % wait for update
    ['**************** Segmentation Completed']
end

end

