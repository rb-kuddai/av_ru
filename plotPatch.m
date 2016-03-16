function [ ] = plotPatch( data,colours,marker_size,clust_id )
%PLOTPATCH function to plot segmentation updates
    if clust_id == 0
        plot3(data(:,1),data(:,2),data(:,3),'k.','markersize',1)
    else
        plot3(data(:,1),data(:,2),data(:,3),'.','color',colours(clust_id,:),'markersize',marker_size); 
    end
    
    set(gca,'zdir','reverse')
    hold on
end

