function [] = testMerge()
  clear all;
  load('registData.mat');
  getHist = @(rgbPatch) reshape(calcColorHist(rgbPatch), 1, []);
  rgbBaseline = rgbSpheresArray{1};
  centersBaseline = sphereCentersArray{1};
  
  baselineHists = cell(3, 1);
  baselineHists{1} = getHist(rgbBaseline{1});
  baselineHists{2} = getHist(rgbBaseline{2});
  baselineHists{3} = getHist(rgbBaseline{3});
  
  spheresMatched = zeros(length(rgbSpheresArray), 3);
  for iFrame = 2:length(rgbSpheresArray)
    rgbPatch = rgbSpheresArray{iFrame};
    otherHists = cell(3,1);
    otherHists{1} = getHist(rgbPatch{1});
    otherHists{2} = getHist(rgbPatch{2});
    otherHists{3} = getHist(rgbPatch{3});
    otherRemains = [1, 2, 3];
    result =  [0, 0, 0];
    for optionId = 1:3
      optionHist = baselineHists{optionId};
      minDist = 10000000;
      minId = -1;
      for iRemain = 1:length(otherRemains)
        otherId = otherRemains(iRemain);
        otherHist =  otherHists{otherId};
        dist = bhattacharyya(otherHist, optionHist);
        if dist < minDist
          minDist = dist;
          minId = otherId;
        end
      end
      
      result(optionId) = minId;
      otherRemains = otherRemains(otherRemains ~= minId);
    end
    spheresMatched(iFrame, :) = result;
  end
  
  %idea from http://nghiaho.com/?page_id=671
  meansBaseline = mean(centersBaseline);
  mB = meansBaseline;
  cB = centersBaseline;
  xyzMerged = xyzCubeArray{1};
  rgbMerged = rgbCubeArray{1};
  for iFrame = 2:length(rgbSpheresArray)
    ids = spheresMatched(iFrame, :);
    otherCenters = sphereCentersArray{iFrame};
    meanOthers = mean(otherCenters);
    mO = meanOthers;
    cO = otherCenters;
    scatter = zeros(3,3);
    for k = 1:3
      scatter = scatter + (cO(ids(k),:)-mO)'*(cB(k,:)-mB);
    end
  
    [U,S,V] = svd(scatter);
    R = V*U';
    if det(R) < 0
      fprintf('Reflect 3 axis\n');
      V(:, 3) = V(:, 3) * -1;
      R = V*U';
    end
    
    trans = (-mO * R' + mB);
    xyzOther = xyzCubeArray{iFrame};
    nOtherPoints = size(xyzOther, 1);
    xyzOther = xyzOther * R' + ones(nOtherPoints, 1) * trans;
    xyzMerged = cat(1, xyzMerged, xyzOther);
    
    rgbOther = rgbCubeArray{iFrame};
    rgbMerged = cat(1, rgbMerged, rgbOther);
  end
  
  [Xim, cm] = rgb2ind(reshape(rgbMerged, size(rgbMerged, 1), 1, 3), 512);
  fscatter32(xyzMerged(:,1), xyzMerged(:,2), xyzMerged(:,3), Xim, cm)
  zlim([0.2 max(xyzMerged(:, 3))])
  ylim([0 1])
  xlim([-.5 .5])
  set(gca,'zdir','reverse')

  %plotFrame3d(xyzMerged, rgbMerged);
  a = 5;
  %for debugging and for report
  %  showColorComparison(xyzSpheresArray{1}, rgbSpheresArray{1});
  %showColorComparison(xyzSpheresArray{16}, rgbSpheresArray{16});
end

