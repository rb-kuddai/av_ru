function [] = plotClusters(xyz, clusters, colors)
  figure();
  clf;
  fscatter32(xyz(:,1), xyz(:,2), xyz(:,3), clusters, colors);
  max_z = max(xyz(:,3));
  zlim([0.2 max_z]);
  ylim([0 1]);
  xlim([-.5 .5]);
  set(gca,'zdir','reverse');
end

