function [xyzFg, rgbFg, normalBg, pointBg] = getForeground(frame3D, showProjectedCenters)
%{  
#Input
  * frame3D - frame 3D from pcl_cell

#Output
  * xyzFG - Coordinates of foreground pixels. 
    Size: number of foreground points x 3.
  * rgbFG - Colors of background pixels between 0 and 1. 
    Size: number of foreground points x 3.
  * normalBg - normal vector of background surface plane. Only for plotting
  * pointBg  - point on the background surface plane. Only for plotting

#Algorithm
  It relies on the fact that overwhelming majority of pixels belongs to
  the background. 

  The background surface essentially can be approximated by plane as frames
  are shot on smooth floor. For that we need to estimate normal of this
  plane and plane distance from origin of coordinate frame.

  First, we compute the normal to the background surface by applying
  PCA to centered cloud points. As we have 3D data we will receive 3 principal 
  components. 1st and 2nd will be lying within surface of the background 
  (because on the background surface the variety of coordinates is the 
  greatest) and 3rd component will be orthogonal to them
  and, therefore it will be normal to the background surface. 

  After that we project centered cloud points on background normal and get
  distribution where most of the points are concentrated on one level
  (background points near the surface of background plane). By taking 50th
  percentile of it we get value of this level and we are able to find 
  distance from origin of global coordinate frame. 

  Finally, we determine the correct direction of normal vector (where the 
  spheres and cube cloud point lie) and remove all points which are located
  not high enough from surface plane.

%}
  %select data point which has kinect 3D data relying on Bob Fisher email:
%   I'm guessing that if it == 0, then this is non-existant data.
%   The line finds all array entries where the z value is not equal to
%   zero, and then uses x(kk) to extract the valid data.
%   
%   Cheers, Bob
  %-------------- INITIAL CLEANING --------------
  existingIds = frame3D(:, :, 6) ~= 0;
  %delete non-existant data
  %coords
  x  = frame3D(:, :, 4);
  y  = frame3D(:, :, 5);
  z  = frame3D(:, :, 6);
  
  x  = x(existingIds);
  y  = y(existingIds);
  z  = z(existingIds);
  %colors
  r  = frame3D(:, :, 1);
  g  = frame3D(:, :, 2);
  b  = frame3D(:, :, 3);

  r  = r(existingIds);
  g  = g(existingIds);
  b  = b(existingIds);
  
  %matrix with background and foreground cloud points
  xyz = [x y z];% number of cloud points x 3
  %matrix with normalised colors for background and foreground cloud points
  rgb = [r g b] / 255;% number of cloud points x 3
  
  %roatate data a little bit for a better view
  alpha = deg2rad(30);
  R = [1 0 0; 0 cos(alpha) sin(alpha); 0 -sin(alpha) cos(alpha)];
  xyz = (R*xyz')';
  
 
  %-------------- FINDING PLANE NORMAL --------------
  %PCA
  meanPoint = mean(xyz); % 1x3
  %centering
  xyzCentered = xyz - ones(size(xyz, 1), 1) * meanPoint;
  %scatter matrix along XYZ
  scatter = xyzCentered' * xyzCentered; % 3x3
  %  
  [U,D,V]= svd(scatter);
  % compute background normal vector by selecting vector 
  % with lowest eigenvalue
  normalBg = V(:, 3)'; %1x3
  
  %-------------- FINDING PLANE DISTANCE --------------
  %project centered cloud points on background normal vector
  %and estimating plane distance in this centered coordinate frame
  xyzProjectedCentered = xyzCentered * normalBg';
  %showing distribution of positions along background surface normal
  if nargin == 2 && showProjectedCenters == 1
    figure();
    clf;
    histogram(xyzProjectedCentered);
    title('cloud points along background normal');
    xlabel('position along background normal');
    ylabel('number of points');
    fig=gcf;
    set(findall(fig,'-property','FontSize'),'FontSize',17);
  end
  
  rawDistanceBg = prctile(xyzProjectedCentered, 50);
  %point which is located on background surface
  pointBg = meanPoint + rawDistanceBg * normalBg;% 1x3

  %background plane distance from global coordinate frame
  planeBgDistance = pointBg *  normalBg'; %scalar
  
  %-------------- EXTRACTING FOREGROUND --------------
  planeDistThreshold = 0.0305;
  xyzProjected = xyz * normalBg'; %number of cloud point x 1
  %background indices
  %bg_ids = (cloud_surf_prjs - d) < -threshold; 
  diffFromBg = xyzProjected - planeBgDistance;
  bgIds = abs(diffFromBg) < planeDistThreshold; 
  %foreground indices
  fgIdsRaw = ~bgIds;
  fgDiff = diffFromBg(fgIdsRaw);
  %remove noise
  heightThreshold = 0.0125;
  normIsInverted = fgDiff(1) < 0;
  if normIsInverted
      fgIds = (diffFromBg) < -heightThreshold; 
      normalBg = -normalBg;
  else
      fgIds = (diffFromBg) > heightThreshold;
  end
  
  %return foreground values
  xyzFg = xyz(fgIds, :);
  rgbFg = rgb(fgIds, :);
end

