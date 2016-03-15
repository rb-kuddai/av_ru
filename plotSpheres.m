function [] = plotSpheres(sphereCenters, sphereRadiuses, spherePatches)
  %{
  plot ball patches and spheres which approximate them
  %}

  figure();
  hold on;
  daspect([1,1,1]);
  %create color map
  colors = brewermap(length(spherePatches),'Set1');
  %generate sphere shape
  [baseX, baseY, baseZ] = sphere(20);
  for i = 1:length(spherePatches)
    xyz = spherePatches{i};
    %draw patch values
    plot3(xyz(:,1), xyz(:,2), xyz(:,3), '.', 'color', colors(i, :), 'markersize',20);
    radius = sphereRadiuses(i);
    center = sphereCenters(i, :);
    %draw wireframe
    surf(radius*baseX+center(1),...
         radius*baseY+center(2),...
         radius*baseZ+center(3),'faceAlpha',0.3,'Facecolor',colors(i, :));
  end
  set(gca,'zdir','reverse')
  ylim([0 1])
  xlim([-.5 .5])
  hold off;
end

