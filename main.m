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


  %fix random seed to have repeatable resutls
  rng(2016);
  %close all opened windows
  close all;
  %---------- PARAMETERS FOR PLOTTING ----------------
  PLOT_FOREGROUND_FRAME3D = -1;
  %shows distribution of all cloud points along background normal
  PLOT_POSITIONS_ALONG_BG_NORMAL = -1;
  PLOT_CLUSTERS_WITH_OUTLIERS = -1;
  PLOT_CLUSTERS_CLEANED = -1;
  PLOT_LOCATED_SPHERES = -1;
  HIST_SPHERE_DISTS = 1;
  %shows background normal vector
  PLOT_BG_NORMAL = -1;
  
  %for debuggin purposes only
  frameRange = 1:16;%1:length(frame3dArray);
  
  sphereCentersArray = cell(length(frameRange), 1);
  xyzCubeArray = cell(length(frameRange), 1);
  rgbCubeArray = cell(length(frameRange), 1);
  
  for iFrame3d = frameRange
    fprintf('Process frame3d %d\n', iFrame3d);
    frame3d = frame3dArray{iFrame3d};
    
    % ------------------- EXTRACTING FOREGROUND --------------------------

    fprintf('Extracting foreground\n');
    
    [xyz, rgb, planeBgNormal, planeBgPoint] = getForeground(frame3d,...
                                            PLOT_POSITIONS_ALONG_BG_NORMAL);
    
    fprintf('Number of foreground cloud points: %d\n', size(xyz, 1));
    if PLOT_FOREGROUND_FRAME3D == 1;
      if PLOT_BG_NORMAL == 1
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
      sphereIds = clusterIds(clusterIds ~= cubeId);
    elseif nClusters > 4
        fprintf('Problem. Apply outer spheres triangle extraction\n');
        continue; %skip  for now
    else
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
      [sphereCenter, sphereRadius] = sphereFit(spherePatches{j});
      sphereCenters(j, :) = sphereCenter;
      sphereRadiuses(j) = sphereRadius;
    end
    
    if PLOT_LOCATED_SPHERES == 1
      plotSpheres(sphereCenters, sphereRadiuses, spherePatches);
    end
    
    sphereCentersArray{iFrame3d} = sphereCenters;
    xyzCubeArray{iFrame3d} = xyz(clusters == cubeId, :);
    rgbCubeArray{iFrame3d} = xyz(clusters == cubeId, :);
  end
  
  %----------------- Registration ----------------------
  
  %find first suitable baseline frame
  iBaselineFrame = -1;
  for j = 1:length(xyzCubeArray)
    if isempty(xyzCubeArray{j})
      fprintf('frame %d is empty', j);
    else
      if iBaselineFrame == -1
        iBaselineFrame = j;
      end
    end
  end
  
  if iBaselineFrame == -1
    fprintf('Warning! All frames are empty!\n');
    return;
  end
  
  if HIST_SPHERE_DISTS == 1
    histSphereDists(sphereCentersArray);
  end
end

