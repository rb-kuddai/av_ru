function [] = histSphereDists(sphereCentersArray)
  %{
    # Description
    makes histogram of distance between spheres of each frame.
    In each frame 3 spheres form a triangle, and this histogram
    allows to estimate how persistance the length of sides of these
    triangles are.

    #Input
      * sphereCentersArray - cell array of 3x3 matrices which contains
      information about sphere centers for particular frame
  %}


  %there are only 3 combinations of 3 elements by 2
  %that is why multiplying by 3
  distances = zeros(length(sphereCentersArray) * 3, 1);
  for j = 1:length(sphereCentersArray)
    if isempty(sphereCentersArray{j})
      continue;
    end
    sphereCenters = sphereCentersArray{j};
    pairs = combnk([1:3],2);
    %there are only 3 combinations of 3 elements by 2
    for iPair = 1:3
      pair = pairs(iPair, :);
      diff = sphereCenters(pair(1)) - sphereCenters(pair(2));
      distances((j-1) * 3 + iPair) = norm(diff);
    end
  end
  
  %plotting
  figure();
  clf
  histogram(distances, 25);
  xlabel('distance between spheres');
  ylabel('frequency');
  title('histogram of distances between spheres for all frames');
  fig=gcf;
  set(findall(fig,'-property','FontSize'),'FontSize',17);
end

