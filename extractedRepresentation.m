function [ ] = extractedRepresentation( listOfClusters,colours )
%EXTRACTEDREPRESENTATION Summary of this function goes here
%   Detailed explanation goes here
figure(2)
clf;
for clstr=1:9
    cluster = listOfClusters(clstr,:,:);
    cluster = reshape(cluster,[96840,3]);
    cluster(all(cluster==0,2),:)=[];
    prunedCluster = datasample(cluster,100);
    prunedCluster(all(prunedCluster==0,2),:)=[];
    plotPatch(prunedCluster,colours,45,clstr)
end

