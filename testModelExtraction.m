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

%     [NPts,W] = size(xyzMerged);
%     patchid = zeros(NPts,1);
%     planelist = zeros(20,4); 
%     remaining = R;
%     for i = 1 : 4 
%         % select a random small surface patch
%         [oldlist,plane] = select_patch(remaining);
%         % grow patch
%         stillgrowing = 1;
%         while stillgrowing
%             % find neighbouring points that lie in plane
%             stillgrowing = 0;
%             [newlist,remaining] = getallpoints(plane,oldlist,remaining,NPts);
%             [NewL,W] = size(newlist);
%             [OldL,W] = size(oldlist);
%             if i == 1
%                 plot3(newlist(:,1),newlist(:,2),newlist(:,3),'r.')
%                 save1=newlist;
%             elseif i==2 
%                 plot3(newlist(:,1),newlist(:,2),newlist(:,3),'b.')
%                 save2=newlist;
%             elseif i == 3
%                 plot3(newlist(:,1),newlist(:,2),newlist(:,3),'g.')
%                 save3=newlist;
%             elseif i == 4
%                 plot3(newlist(:,1),newlist(:,2),newlist(:,3),'c.')
%                 save4=newlist;
%             else
%                 plot3(newlist(:,1),newlist(:,2),newlist(:,3),'m.')
%                 save5=newlist;
%             end
%             pause(1)
%             if NewL > OldL + 50
%               % refit plane
%               [newplane,fit] = fitplane(newlist);
%             [newplane',fit,NewL]
%               planelist(i,:) = newplane';
%               if fit > 0.04*NewL       % bad fit - stop growing
%                 break
%               end
%               stillgrowing = 1;
%               oldlist = newlist;
%               plane = newplane;
%             end
%         end        
%     end
end

