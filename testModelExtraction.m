function [ ] = testModelExtraction()
  %Todor, you can experiment here, because in that case
  %you won't have to wait for background substraction, clustering,
  %registration, etc when you want to experiment with your functions 
  %(because all operations take 1-2 minutes);
  load('cubeMerged1.mat');
  %loaded 2 variables:
  % * xyzMerged - coordinates of the merged cube
  % * rgbMerged - colors of the merged cube
  
  %plotting it
  plotMergedCube(xyzMerged, rgbMerged);
end

