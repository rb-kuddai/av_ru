function [] = plotFrame3d(xyz, rgb, planeBgNormal, planeBgPoint)
  %{
  #Description
  plot frame 3d with original colors stored in rgb matrix.
  If planeNormal and planePoint are given then also plots
  the background normal vector.
  #Input
    * xyz - matrix with coordinates of cloud points. 
      Size: number of points x 3
    * rgb - matrix with normalised colors of cloud points
      Size: number of points x 3
    * planeBgNormal - additional parameter. Background surface normal 3d 
      vector
    * planeBgPoint - additional parameter. 3d point which lies on
      background surface.
  %}
  
  figure(); 
  clf;
  hold on;
  % plotting cloud points
  camproj('perspective');
  scatter3(xyz(:, 1), xyz(:,2), xyz(:,3), 12, rgb, 'filled');
  camproj('perspective');
  max_z = max(xyz(:,3));
  zlim([0.2 max_z])
  %ylim([0 1])
  %xlim([-.5 .5])
  set(gca,'zdir','reverse')
  
  % if planeBgNormal and planeBgPoint are given then plot background normal
  if nargin == 4
    direction = planeBgNormal * max_z * 0.35;
    quiver3(planeBgPoint(1),  planeBgPoint(2),  planeBgPoint(3),...
            direction(1), direction(2), direction(3),...
            'MaxHeadSize',5,'Color','r','LineWidth',2);  
  end

end

