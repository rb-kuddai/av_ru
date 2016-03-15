% BHATTACHARYYA(histogram1, histogram2)
% compute the BHATTACHARYYA distance between 2 histograms
% where each histogram is a 1xN vector
% 
% Based on the estimation presented in 
% "Real-Time Tracking of Non-Rigid Objects using Mean Shift"
%  D. Comaniciu, V. Ramesh & P. Meer (IEEE CVPR 2000, 142-151)
%
% N.B. both histograms must be normalised
% (i.e. bin values lie in range 0->1 and SUM(bins(i)) = 1
%       for i = {histogram1, histogram2} )
%
% Author / Copyright: T. Breckon, October 2005.
% School of Informatics, University of Edinburgh.
% License: http://www.gnu.org/licenses/gpl.txt

function bdist = bhattacharyya(hist1, hist2)
    %small epsilon to prevent floating substraction 
    %pitfall like: 1-1.0 = -1e-16. 
    %Without epsilon would get complex numbers in the end
    eps = 1e-12;
    bcoeff = sqrt(hist1)*sqrt(hist2');
    % get the distance between the two distributions as follows
    bdist = sqrt(1 + eps - bcoeff);
end
