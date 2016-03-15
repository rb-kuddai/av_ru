function [] = printClustersSizes(clusters, clusterIds)
%PRINTCLUSTERSSIZES Summary of this function goes here
%   Detailed explanation goes here
  for i = 1:length(clusterIds)
    clusterId = clusterIds(i);
    fprintf('cluster id %d has size %d \n', clusterId, nnz(clusters==clusterId));
  end

end

