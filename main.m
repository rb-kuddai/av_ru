function [] = main(frame3dArray)
%{
#Naming Conventions
 Bg - background
 Fg - foreground

#Input
  * frame3DArray - cell of 3d frames (pcl_cell from av_pcl.mat file)

#General Algorithm
for each 3D frame:
  * Extracting foreground using PCA and remove noise by using percentile 
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
  rng(2016);
  %close all opened windows
  close all;
  %---------- PARAMETERS FOR PLOTTING ----------------
  PLOT_FOREGROUND_FRAME3D = -1;
  %shows distribution of all cloud points along background normal
  PLOT_POSITIONS_ALONG_BG_NORMAL = -1;
  PLOT_CLUSTERS_WITH_OUTLIERS = -1;
  PLOT_CLUSTERS_CLEANED = -1;
  PLOT_LOCATED_SPHERES = 1;
  %shows background normal vector
  SHOW_BG_NORMAL = 1;
  for iFrame3d = 8:8%1:length(frame3dArray)
    fprintf('Process frame3d %d\n', iFrame3d);
    frame3d = frame3dArray{iFrame3d};
    
    % ------------------- EXTRACTING FOREGROUND --------------------------

    fprintf('Extracting foreground\n');
    
    [xyz, rgb, planeBgNormal, planeBgPoint] = getForeground(frame3d,...
      ismember(iFrame3d, PLOT_POSITIONS_ALONG_BG_NORMAL));
    
    fprintf('Number of foreground cloud points: %d\n', size(xyz, 1));
    if PLOT_FOREGROUND_FRAME3D == 1;
      if SHOW_BG_NORMAL == 1
        plotFrame3d(xyz, rgb, planeBgNormal, planeBgPoint);
      else
        plotFrame3d(xyz, rgb);
      end
    end
    
    % ----------------------- CLUSTERING  --------------------------
    [xyz, rgb, clusters, cluster2mean, clusterIds, cubeId] = clustering(xyz, rgb);
    
    display(clusterIds, 'clusters ids with possible outliers');
    printClustersSizes(clusters, clusterIds);
    colors = brewermap(length(clusterIds),'Set1'); 
   	if PLOT_CLUSTERS_WITH_OUTLIERS == 1
      plotClusters(xyz, clusters, colors);
    end
    
    % final cluster cleaning
    % dbscan mark outliers by -1 id that is why we are removing them
    clusterIds = clusterIds(clusterIds ~= -1);
    xyz = xyz(clusters ~= -1, :);
    rgb = rgb(clusters ~= -1, :);
    clusters = clusters(clusters ~= -1);
    
    display(clusterIds, 'clusters ids cleaned');
    
    if PLOT_CLUSTERS_CLEANED == 1
      plotClusters(xyz, clusters, colors);
    end
    
    % --------------------- SPHERES EXTRACTION -----------------------
    nClusters = length(clusterIds);
    fprintf('%d clusters are detected after cleaning\n', nClusters);
    if nClusters == 4
      fprintf('4 clusters are detected after cleaning\n');
      sphereIds = clusterIds(clusterIds ~= cubeId);
    elseif nClusters > 4
      fprintf('Problem. Apply outer spheres triangle extraction\n');
      continue; %skip  for now
    elseif nCluster < 4;
      fprintf('Impossible to extract. Skip');
      continue;
    end
    
    display(sphereIds, 'Sphere Ids');
    
    sphereCenters = zeros(3, 3);
    sphereRadiuses = zeros(3, 1);
    spherePatches = cell(3, 1);
    for j = 1:3
      sphereId = sphereIds(j);
      spherePatches{j} = xyz(clusters == sphereId, :);
      [sphereCenter, sphereRadius] = sphereFit(spherePatches{j})
      sphereCenters(j, :) = sphereCenter;
      sphereRadiuses(j) = sphereRadius;
    end
    
    if PLOT_LOCATED_SPHERES == 1
      plotSpheres(sphereCenters, sphereRadiuses, spherePatches)
    end
  end
end

