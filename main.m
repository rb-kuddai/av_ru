%run it as: main(pcl_cell)
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
  PLOT_LOCATED_SPHERES = -1;
  HIST_SPHERE_DISTS = -1;
  %shows background normal vector
  PLOT_BG_NORMAL = -1;
  PLOT_MERGED_CUBE = 1;
  
  SAVE_DATA_FOR_REGISTRATION = 1;
  SAVE_DATA_FILE_NAME = 'registData2';
  SAVE_MERGED_CUBE_DATA = 1;
  SAVE_MERGED_CUBE_FILE_NAME = 'cubeMerged1';
  
  
  
  %for debuggin purposes only
  frameRange = 1:16;%1:length(frame3dArray);
  
  sphereCentersArray = cell(length(frameRange), 1);
  xyzBallsArray = cell(length(frameRange), 1);
  rgbBallsArray = cell(length(frameRange), 1);
  xyzCubeArray = cell(length(frameRange), 1);
  rgbCubeArray = cell(length(frameRange), 1);
  
  for iFrame3d = frameRange
    fprintf('PROCESS FRAME %d !!!\n', iFrame3d);
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
    %xyzSpherePatches ,rgbSpherePatches are cell array
    %where index belongs to one of 3 spheres
    [sphereCenters, sphereRadiuses, xyzBallPatches ,rgbBallPatches] =...
    extractSpheres(xyz, rgb, clusters, sphereIds);
    
    if PLOT_LOCATED_SPHERES == 1
      plotSpheres(sphereCenters, sphereRadiuses, xyzBallPatches);
    end
    
    sphereCentersArray{iFrame3d} = sphereCenters;
    xyzBallsArray{iFrame3d} = xyzBallPatches;
    rgbBallsArray{iFrame3d} = rgbBallPatches;
    
    xyzCubeArray{iFrame3d} = xyz(clusters == cubeId, :);
    rgbCubeArray{iFrame3d} = rgb(clusters == cubeId, :);
    
    fprintf('\n\n');
  end
  %--------------- END OF FRAME LOOP -------------------
  
  
  %----------------- REGISTRATION AND MERGE ----------------------
  
  %this code allows to evaluate whether it is possible to
  %register spheres by comparing length of sides of triangles
  %that they form.
  if HIST_SPHERE_DISTS == 1
    histSphereDists(sphereCentersArray);
  end
  
  %for testing purposes.
  %To skip previous steps and experiment with data directly
  %Saves a lot of time
  if SAVE_DATA_FOR_REGISTRATION == 1
    save(SAVE_DATA_FILE_NAME,...
         'sphereCentersArray',...
         'xyzBallsArray',...
         'rgbBallsArray',...
         'xyzCubeArray',...
         'rgbCubeArray');  
    fprintf('\n\nData is saved to %s \n\n', SAVE_DATA_FILE_NAME);
  end
  
  [xyzMerged, rgbMerged] = merge(rgbBallsArray, sphereCentersArray, xyzCubeArray, rgbCubeArray);
  if PLOT_MERGED_CUBE == 1
     plotMergedCube(xyzMerged, rgbMerged);
  end
  
  %for testing purposes.
  %To skip previous steps and experiment with data directly
  %Saves a lot of time
  if SAVE_MERGED_CUBE_DATA == 1
    save(SAVE_MERGED_CUBE_FILE_NAME,'xyzMerged', 'rgbMerged');
  end
  
  %----------------- MODEL EXTRACTION ----------------------
  %TODOR, YOU GO HERE. THIS PROGRAM MAY WORK DIFFERENTLY ON DIFFERENT MATLABS
  %VERSIONS AS I AM FIXING RANDOM SEED. WATCH LECTURSE ADOPT 3 FUNCTIONS FROM THERE.
  %PLANE EXTRACTION WILL WORK VERY SLOWLY (4 MINS) BECAUSE THERE ARE OVER 90000
  %POINTS IN THE MERGED DATA. THAT IS WHY YOU WILL NEED TO DOWNSAMPLE TO 
  %APPROXIMATELY 20000-30000 POINTS (YOU WILL GET 6 TIMES BOOST). THIS
  %DOWNSAMPLING IS VERY IMPORTANT AS I AM SURE THAT THEY WILL GIVE EXTRA
  %POINTS FOR THIS SPEED AND DOWNSAMPLING IS JUST SELECTING POINTS RANDOMLY
  
  %THRERE IS ALMOST NO NOISE IN THE MERGED DATA
  
  %IN ORDER TO SAVE YOUR TIME YOU CAN EXPERIMENT IN testModelExtraction()
  %IN THAT CASE YOU WON'T HAVE TO WAIT 1-2 MINUTES TO SEE RESULTS AS IT
  %JUST LOADS THE MERGED DATA FROM cubeMerged1.mat
end

