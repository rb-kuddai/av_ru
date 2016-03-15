function [] = showColorComparison(xyzSpherePatches, rgbSpherePatches)
  %show color comparison between different spheres for the same frame
  
  %color histograms
  figure();
  clf;
  hold on;
  plot(reshape(calcColorHist(rgbSpherePatches{1}), 1, []), 'k', 'LineWidth', 2);
  plot(reshape(calcColorHist(rgbSpherePatches{2}), 1, []), 'b', 'LineWidth', 2);
  plot(reshape(calcColorHist(rgbSpherePatches{3}), 1, []), 'g', 'LineWidth', 2);
  ylabel('Intensity');
  xlabel('Color vector');
  legend('Black Line', 'Blue Line', 'Green Line');
  fig=gcf;
  set(findall(fig,'-property','FontSize'),'FontSize',17);
  hold off;
  
  %spheres patches
  figure(); 
  clf;
  % plotting cloud points
  subplot(2,2,1);
  xyz = xyzSpherePatches{1};
  rgb = rgbSpherePatches{1};
  scatter3(xyz(:, 1), xyz(:,2), xyz(:,3), 15, rgb, 'filled');
  title('Black Line');
  set(gca,'zdir','reverse');

  subplot(2,2,2);
  xyz = xyzSpherePatches{2};
  rgb = rgbSpherePatches{2};
  scatter3(xyz(:, 1), xyz(:,2), xyz(:,3), 15, rgb, 'filled');
  title('Blue Line');
  set(gca,'zdir','reverse');

  subplot(2,2,3);
  xyz = xyzSpherePatches{3};
  rgb = rgbSpherePatches{3};
  scatter3(xyz(:, 1), xyz(:,2), xyz(:,3), 15, rgb, 'filled');
  title('Green Line');
  set(gca,'zdir','reverse');    
end