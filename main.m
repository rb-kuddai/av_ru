function [] = main(frame3DArray)
%{
#Input
  * frame3DArray - cell of 3d frames (pcl_cell from av_pcl.mat file)

#General Algorithm
for each 3D frame:
  * Subtract background using PCA and remove noise by using percentile 
    statistics (relying on the fact that overwhelming majority of 
    cloud points belongs to the background). Due to that most of outliers 
    are removed on this stage.
  * Use DBscan clustering to allocate initial clusters 
  * Select clusters which belongs to spheres using geometric information 
    that spheres form outer triangle
  * Compute color histograms of each spheres and compare it to the anchor 
    3D frame and align sphere indices
  * Find the rotation and translation of coordinate frame via PCA
  * Apply rotation and translation to the cube cluster and store it 
 
After that merge all cube cloud points from each 3D frame and utilize 
patch growing algorithm to select 9 planes. On this stage sampling 
is used to reduce the number of cloud points and reduce load 
on patch growing algorithm.
%}  
%[xyzFg, rgbFg] = getForeground(
  [xyzFg, rgbFg, normalBg, pointBg] = getForeground(frame3DArray{1});
  figure(2); 
  clf;
  hold on;
  camproj('perspective');
  scatter3(xyzFg(:, 1), xyzFg(:,2), xyzFg(:,3), 10, rgbFg, 'filled');
  camproj('perspective');
  %fscatter32(XYZ(fg_ids,1), XYZ(fg_ids,2), XYZ(fg_ids,3), Xim(fg_ids), cm)
  max_z = max(xyzFg(:,3));
  zlim([0.2 max_z])
  ylim([0 1])
  xlim([-.5 .5])
  set(gca,'zdir','reverse')
  fprintf('K: %d\n', 5);
end

