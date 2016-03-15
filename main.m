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
    are removed on this stage. Function: getForeground
  * Use DBscan clustering to allocate initial clusters 
    Function: clustering
  * Remove outliers near border from clustering stage by using the fact that
    most of the points belong to cube and clusters which are too far away
    from cube are outliers
  * Extract spheres clusters by using geometric information (forms triangle)
    and the fact that biggest cluster must be a cube
  * Fit sphere cloud points with sphereFit function
  * Save data

Select baseline frame and compute color histograms of its spheres and 
align spheres from all other frames accordingly. 
Find the rotation and translation of coordinate frame via PCA.
Apply rotation and translation to the cube cluster.
 
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
  PLOT_LOCATED_SPHERES = 1;
  HIST_SPHERE_DISTS = -1;
  %shows background normal vector
  PLOT_BG_NORMAL = -1;
  
  %for debuggin purposes only
  frameRange = 1:16;%1:length(frame3dArray);
  
  sphereCentersArray = cell(length(frameRange), 1);
  xyzSpheresArray = cell(length(frameRange), 1);
  rgbSpheresArray = cell(length(frameRange), 1);
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
    %display information about detected clusters 
    %and extract spheres using information that we know which cluster is
    %cube
    
    nClusters = length(clusterIds);
    fprintf('%d clusters are detected after cleaning\n', nClusters);
    if nClusters == 4
      sphereIds = clusterIds(clusterIds ~= cubeId);
    elseif nClusters > 4
        fprintf('Warning. Apply outer spheres triangle extraction\n');
        continue; %skip  for now
    else
      fprintf('Impossible to extract. Skip\n');
      continue;
    end
    
    %final sphere ids (in correspondence to clusters)
    display(sphereIds, 'Sphere Ids');
    
    [sphereCenters, sphereRadiuses, xyzSpherePatches ,rgbSpherePatches] =...
    extractSpheres(xyz, rgb, clusters, sphereIds);
    
    if PLOT_LOCATED_SPHERES == 1
      plotSpheres(sphereCenters, sphereRadiuses, xyzSpherePatches);
    end
    
    sphereCentersArray{iFrame3d} = sphereCenters;
    xyzSpheresArray{iFrame3d} = xyzSpherePatches;
    rgbSpheresArray{iFrame3d} = rgbSpherePatches;
    
    xyzCubeArray{iFrame3d} = xyz(clusters == cubeId, :);
    rgbCubeArray{iFrame3d} = rgb(clusters == cubeId, :);
    
    fprintf('\n\n');
  end
  %--------------- END OF FRAME LOOP -------------------
  
  
  %----------------- REGISTRATION ----------------------
  
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
  
  %this code allows to evaluate whether it is possible to
  %register spheres by comparing length of sides of triangles
  %that they form.
  if HIST_SPHERE_DISTS == 1
    histSphereDists(sphereCentersArray);
  end
end

