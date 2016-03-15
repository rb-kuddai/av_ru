function [ hist ] = calcColorHist(rgb)
%{
  #Input
  * rgb - normalised (between 0 and 1) color of the points. 
  Size: number of cloud points x 3
%}
  nPoints = size(rgb, 1);
  %parameter
  edges = 0:0.05:1; %because normalised
  
  histR = histc(rgb(:,1), edges);
  histG = histc(rgb(:,2), edges);
  histB = histc(rgb(:,3), edges);
  
  histR = histR / nPoints;
  histG = histG / nPoints;
  histB = histB / nPoints;
  hist = [histR, histG, histB];%[histR, histG, histB];
  %normalize it as whole to 1
  hist = hist ./ 3;
end

