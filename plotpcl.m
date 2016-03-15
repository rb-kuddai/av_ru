function plotpcl(pcl)
  
    kk = pcl(:, :, 6) ~= 0;
    x  = pcl(:, :, 4);
    y  = pcl(:, :, 5);
    z  = pcl(:, :, 6);
    x  = x(kk);
    y  = y(kk);
    z  = z(kk);
    
    %colors
    r  = pcl(:, :, 1);
    g  = pcl(:, :, 2);
    b  = pcl(:, :, 3);

    r  = r(kk);
    g  = g(kk);
    b  = b(kk);
    
    
    rgbUndistorted = pcl(:,:,1:3)/255;
    [Xim, cm] = rgb2ind(rgbUndistorted, 512);
    Xim = Xim(kk);
    XYZ = [x y z];
    alpha = deg2rad(30);
    R = [1 0 0; 0 cos(alpha) sin(alpha); 0 -sin(alpha) cos(alpha)];
    XYZ = (R*XYZ')';
    figure (1);
    fscatter32(XYZ(:,1), XYZ(:,2), XYZ(:,3), Xim, cm)
    max_z = max(z(:));
    zlim([0.2 max(z(:))])
    ylim([0 1])
    xlim([-.5 .5])
    set(gca,'zdir','reverse')
    mean_point = mean(XYZ); % 1x3
    %centering
    point_dev = XYZ - ones(size(XYZ, 1), 1) * mean_point;
    %scatter matrix along XYZ
    scatter = point_dev' * point_dev; % 3x3
    [U,D,V]= svd(scatter);
    %background normal vector, get the vector with lowest eigenvalue
    bg_n = V(:, 3)'; %1x3
    %projection of centered cloud points on the background normal 
    %in other words how far certain point from the background
    norm_prjs = point_dev * bg_n'; % num_points x 1
    %background point project on background normal
    bg_prj_point = prctile(norm_prjs, 50);
    bg_point = mean_point + bg_prj_point * bg_n;% 1x3

    %background surface parameters for following equation:
    % n*r=d where n - normal, d - offset along the normal
    d = bg_point *  bg_n'
    threshold_raw = 0.0305;
    %threshold = 0.0125;
    cloud_surf_prjs = XYZ * bg_n'; %number of cloud point x 1
    %background indices
    %bg_ids = (cloud_surf_prjs - d) < -threshold; 
    surf_diff = cloud_surf_prjs - d;
    bg_ids_raw = abs(surf_diff) < threshold_raw; 
    %foreground indices
    fg_ids_raw = ~bg_ids_raw;
    fg_diff = surf_diff(fg_ids_raw);
    %remove noise
    threshold = 0.0125;
    norm_is_inverted = fg_diff(1) < 0;
    if norm_is_inverted
        fg_ids = (surf_diff) < -threshold; 
    else
        fg_ids = (surf_diff) > threshold;
    end

    figure(4);
    %   class = kmeans(XYZ(fg_ids,:),4); % does not perform so well / replace
    x = XYZ(fg_ids,1);
    y = XYZ(fg_ids,2);
    z = XYZ(fg_ids,3);
    xyz = XYZ(fg_ids,:);
    % cluster in n categories with DBSCAN with automatic epsilon
    [class, type]=dbscan([XYZ(fg_ids,1),XYZ(fg_ids,2),XYZ(fg_ids,3)],100);
    figure();
    
    % unqiue class names
    uniqueGroups = unique(class)
    fscatter32(x, y, z, Xim(fg_ids), cm);
    max_z = max(xyz(:,3));
    %zlim([0.2 max_z])
    %ylim([0 1])
    %xlim([-.5 .5])
    set(gca,'zdir','reverse')
    % RGB values of your favorite colors: 
    % Initialize some axes
    view(3)
    %grid on
    hold on
    return
    % obtain all possible combinations of clusters
    triples = combnk (uniqueGroups,3);
    % compute means for each cluster 1x3 - per cluster
    groups2mean = containers.Map('KeyType','double','ValueType','any');
    for t = 1:numel(uniqueGroups)
      group_id = uniqueGroups(t);
      groups2mean(group_id) = mean(xyz(class == group_id, :));
    end

    % compute 3D area for the groups of three clusters
    area = zeros(size(triples));
    g2m = groups2mean;
    maxArea = 0;
    for group = 1:size(triples)
        grupa = triples(group,:);
        area(group) = triangleArea3d(g2m(grupa(1)),g2m(grupa(2)),g2m(grupa(3)));
        if area(group) > maxArea
            maxArea = area(group); % keep track of the biggest area
        end;
    end;
    % choose spheres
    
    
    index = area==maxArea;
    spheres = triples(index,:) % those are the three spheres
    rest = setdiff(uniqueGroups,spheres);
    % set cluster colours
    colors = brewermap(length(spheres),'Set1'); 
    % plot middle patch
%     for k = 1:length(rest)
%           % Get indices of this particular unique group:
%           ind = class==rest(k); 
%           % Plot only this group: 
%           plot3(x(ind),y(ind),z(ind),'.','color',colors(1,:),'markersize',20); 
%     end
%     set(gca,'zdir','reverse')
%     zlim([0.2 max(z(:))])
%     ylim([0 1])
%     xlim([-.5 .5])
%     hold on
%     %plotting arrow of background normal
%     arrow_p = bg_point;% 1x3
%     %scale it and invert it for better representation
%     %because z axis is inverted
%     arrow_dir   = -bg_n * max_z/4; 
%     quiver3(arrow_p(1), arrow_p(2), arrow_p(3),...
%           arrow_dir(1)  , arrow_dir(2)  , arrow_dir(3), 'color', 'b'); 
%     view(3)
%     hold off
    plotEt = [x(class==spheres(1)),y(class==spheres(1)),z(class==spheres(1))];
    plotEtwo = [x(class==spheres(2)),y(class==spheres(2)),z(class==spheres(2))];
    plotEthree = [x(class==spheres(3)),y(class==spheres(3)),z(class==spheres(3))];
    [Center_LSE,Radius_LSE] = sphereFit(plotEt);
    [Center_LSEtwo,Radius_LSEtwo] = sphereFit(plotEtwo);
    [Center_LSEthree,Radius_LSEthree] = sphereFit(plotEthree);
    
    
    plot3(plotEt(:,1),plotEt(:,2),plotEt(:,3),'r.')
    hold on;daspect([1,1,1]);
    [Base_X,Base_Y,Base_Z] = sphere(20);
    surf(Radius_LSE*Base_X+Center_LSE(1),...
        Radius_LSE*Base_Y+Center_LSE(2),...
        Radius_LSE*Base_Z+Center_LSE(3),'faceAlpha',0.3,'Facecolor','m')
    hold on
    plot3(plotEtwo(:,1),plotEtwo(:,2),plotEtwo(:,3),'g.')
    hold on;
    [Base_Xtwo,Base_Ytwo,Base_Ztwo] = sphere(20);
    surf(Radius_LSEtwo*Base_Xtwo+Center_LSEtwo(1),...
        Radius_LSEtwo*Base_Ytwo+Center_LSEtwo(2),...
        Radius_LSEtwo*Base_Ztwo+Center_LSEtwo(3),'faceAlpha',0.3,'Facecolor','c')
    hold on
    plot3(plotEthree(:,1),plotEthree(:,2),plotEthree(:,3),'b.')
    hold on;
    [Base_Xthree,Base_Ythree,Base_Zthree] = sphere(20);
    surf(Radius_LSEthree*Base_Xthree+Center_LSEthree(1),...
        Radius_LSEthree*Base_Ythree+Center_LSEthree(2),...
        Radius_LSEthree*Base_Zthree+Center_LSEthree(3),'faceAlpha',0.3,'Facecolor','y')
%     view([45,28])
%     legend({'Data','Actual Sphere','LSE Sphere'},'location','W')

    hold on
    
    % Plot each group individually: 
    for k = 1:length(spheres)
          % Get indices of this particular unique group:
          ind = class==spheres(k); 
          % Plot only this group: 
          plot3(x(ind),y(ind),z(ind),'.','color',colors(k,:),'markersize',20); 
    end
    legend('group 1','group 2','group 3')
    set(gca,'zdir','reverse')
    zlim([0.2 max(z(:))])
    ylim([0 1])
    xlim([-.5 .5])
    hold on
    %plotting arrow of background normal
    arrow_p = bg_point;% 1x3
    %scale it and invert it for better representation
    %because z axis is inverted
    arrow_dir   = -bg_n * max_z/4; 
    quiver3(arrow_p(1), arrow_p(2), arrow_p(3),...
          arrow_dir(1)  , arrow_dir(2)  , arrow_dir(3), 'color', 'b'); 
    camproj('perspective')
    view(3)
return;%just for easy debug
    % Show colour image
    figure(2)
    image(pcl(:,:,1:3)/255)

    % show depth image
    figure(3)
    [H,W]=size(pcl(:,:,1));
    depth=zeros(H,W);
    for r = 1 : H
    for c = 1 : W
      depth(r,c) = norm(reshape(pcl(r,c,4:6),1,3));
    end
    end
    M = max(max(depth));
    m = min(min(depth));
    depth = (depth - m) / (M-m);
    imshow(depth.^2)

    end
