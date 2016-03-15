function [sphereCenters, sphereRadiuses, xyzSpherePatches ,rgbSpherePatches] =...
          extractSpheres(xyz, rgb, clusters, sphereIds)
%{
  #Decription
   extract balls patches and fit them with spheres using sphereFit
          
  #Input
  * xyz - Coordiantes of cloud points. Size:number of points x 3    
  * rgb - Colors of cloud points. Size:number of points x 3    
  * clusters - vector of point allocations to paticular clusters. 
    Size: number of points x 1
  * sphereIds - vector. Contains which clusters ids belong to spheres
          
  #Output
  * sphereCenters - 3x3 matrix containing center of each sphere after
    fitting
  * sphereRadiuses - vector which contains sphere radiuses after fitting
  * xyzSpherePatches - spheres coordinate data stored in cell array
  * rgbSpherePatches - spheres color data stored in cell array
%}
  sphereCenters = zeros(3, 3);
  sphereRadiuses = zeros(3, 1);
  xyzSpherePatches = cell(3, 1);
  rgbSpherePatches = cell(3, 1);
  
  for j = 1:3
    sphereId = sphereIds(j);
    xyzSpherePatches{j} = xyz(clusters == sphereId, :);
    rgbSpherePatches{j} = rgb(clusters == sphereId, :);
    %fitting
    [sphereCenter, sphereRadius] = sphereFit(xyzSpherePatches{j});
    sphereCenters(j, :) = sphereCenter;
    sphereRadiuses(j) = sphereRadius;
  end
end

