function [] = plotMergedCube(xyzMerged, rgbMerged)
  %merged data contains around 90000 points
  %that is why we are displaying via fscatter32
  [Xim, cm] = rgb2ind(reshape(rgbMerged, size(rgbMerged, 1), 1, 3), 512);
  fscatter32(xyzMerged(:,1), xyzMerged(:,2), xyzMerged(:,3), Xim, cm);
  zlim([0.2 max(xyzMerged(:, 3))]);
  ylim([0 1]);
  xlim([-.5 .5]);
  set(gca,'zdir','reverse');
end

