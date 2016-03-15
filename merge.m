function [xyzMerged, rgbMerged] = merge(rgbBallsArray, sphereCentersArray, xyzCubeArray, rgbCubeArray)
  %{
    #Description
    merge cube cloud points. It is achieved by:
    first finding all spheres matches by comparing
    color histograms from baseline frame (first one);
    After PCA is applied to find rotation and translations;

    #Input
    rgbBallsArray - cell array of balls colors
    sphereCentersArray -  cell array of sphere's centers
    xyzCubeArray - cell array of cube coordinates stored for each frame.
    rgbCubeArray - cell array of cube colors stored for each frame.

    #Output
    * xyzMerged - cube merged coordinates in one coordinate system. 
      Size: number of merged cube points x 3
    * rgbOther  - cube merged colors.
      Size: number of merged cube points x 3
  %}

  %load('registData.mat');
  
  getHist = @(rgbPatch) reshape(calcColorHist(rgbPatch), 1, []);
  
  rgbBaseline = rgbBallsArray{1};
  centersBaseline = sphereCentersArray{1};
  
  %storing histograms of baseline spheres for
  %future comparison
  baselineHists = cell(3, 1);
  baselineHists{1} = getHist(rgbBaseline{1});
  baselineHists{2} = getHist(rgbBaseline{2});
  baselineHists{3} = getHist(rgbBaseline{3});
  
  %which ids correspoinds to the baselineSphere ids
  spheresMatched = zeros(length(rgbBallsArray), 3);
  for iFrame = 2:length(rgbBallsArray)
    rgbPatch = rgbBallsArray{iFrame};
    %storing histograms of all spheres
    otherHists = cell(3,1);
    otherHists{1} = getHist(rgbPatch{1});
    otherHists{2} = getHist(rgbPatch{2});
    otherHists{3} = getHist(rgbPatch{3});
    %unpaired matches
    otherRemains = [1, 2, 3];
    
    %final matches stored here
    result =  [0, 0, 0];
    %there are only 3 spheres
    %finding matches with smallest bhattacharyya distances
    for candidateId = 1:3
      candidateHist = baselineHists{candidateId};
      minDist = 10000000;
      minId = -1;
      for iRemain = 1:length(otherRemains)
        otherId = otherRemains(iRemain);
        otherHist =  otherHists{otherId};
        dist = bhattacharyya(otherHist, candidateHist);
        if dist < minDist
          minDist = dist;
          minId = otherId;
        end
      end
      %saving matches
      result(candidateId) = minId;
      otherRemains = otherRemains(otherRemains ~= minId);
    end
    spheresMatched(iFrame, :) = result;
  end
  
  %idea from http://nghiaho.com/?page_id=671
  meansBaseline = mean(centersBaseline);
  %shortcuts
  mB = meansBaseline;
  cB = centersBaseline;
  xyzMerged = xyzCubeArray{1};
  rgbMerged = rgbCubeArray{1};
  
  %computing Rotation and Translation by applying PCA
  for iFrame = 2:length(rgbBallsArray)
    %spheres matched ids
    ids = spheresMatched(iFrame, :);
    otherCenters = sphereCentersArray{iFrame};
    meanOthers = mean(otherCenters);
    %shortcuts
    mO = meanOthers;
    cO = otherCenters;
    scatter = zeros(3,3);
    for k = 1:3
      scatter = scatter + (cO(ids(k),:)-mO)'*(cB(k,:)-mB);
    end
  
    [U,S,V] = svd(scatter);
    %computing rotation and translation
    R = V*U';
    %avoid reflection case
    if det(R) < 0
      fprintf('Reflect 3rd axis for frame %d\n', iFrame);
      V(:, 3) = V(:, 3) * -1;
      R = V*U';
    end
    translation = (-mO * R' + mB);
    
    xyzOther = xyzCubeArray{iFrame};
    nOtherPoints = size(xyzOther, 1);
    
    %applying transformations to the cube cloud points
    xyzOther = xyzOther * R' + ones(nOtherPoints, 1) * translation;
    
    %mergin cube cloud points
    rgbOther = rgbCubeArray{iFrame};
    xyzMerged = cat(1, xyzMerged, xyzOther);
    rgbMerged = cat(1, rgbMerged, rgbOther);
  end
end

