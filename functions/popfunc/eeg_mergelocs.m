% eeg_mergelocs() - merge channel structure while preserving channel
%                   order
%
%      >> mergedlocs = eeg_mergelocs(loc1, loc2, loc3, ...);
%
% Inputs: 
%     loc1     - EEGLAB channel location structure
%     loc2     - second EEGLAB channel location structure
%
% Output: 
%     mergedlocs - merged channel location structure
%
% Author: Arnaud Delorme, August 2006

% Copyright (C) Arnaud Delorme, CERCO, 2006, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: not supported by cvs2svn $
% Revision 1.3  2009/07/30 19:27:10  arno
% handles dataset with different channel order
%
% Revision 1.2  2008/04/16 17:35:57  arno
% simplify code, added one optional input
%
% Revision 1.1  2006/09/20 12:26:44  arno
% Initial revision
%

function alllocs = eeg_mergelocs(varargin)

% sort by length
% --------------
len = cellfun(@length, varargin);
[tmp so] = sort(len, 2, 'descend');
varargin = varargin(so);

alllocs = varargin{1};
for index = 2:length(varargin)
    
    % fuse while preserving order (assumes the same channel order)
    % ------------------------------------------------------------
    tmplocs = varargin{index};
    newlocs = myunion(alllocs, tmplocs);
    
    if length(newlocs) > length(union({ alllocs.labels }, { tmplocs.labels }))

        disp('Warning: different channel montage order for the different datasets');

        % trying to preserve order of the longest array
        %----------------------------------------------
        if length(alllocs) < length(tmplocs)
            tmp     = alllocs;
            alllocs = tmplocs;
            tmplocs = tmp;
        end;
        allchans = { alllocs.labels tmplocs.labels };
        [uniquechan ord1 ord2 ]  = unique( allchans );
        
        [tmp rminds] = intersect( uniquechan, { alllocs.labels });
        ord1(rminds) = [];
        tmplocsind = ord1-length(alllocs);
        
        newlocs = [ alllocs tmplocs(tmplocsind) ];

    end;
    alllocs = newlocs;
end;

% union of two channel location structure
% without loosing the order information
% ---------------------------------------
function alllocs = myunion(locs1, locs2)

   labs1 = { locs1.labels };
   labs2 = { locs2.labels };
   
   count1 = 1;
   count2 = 1;
   count3 = 1;
   alllocs = locs1; alllocs(:) = [];
   while count1 <= length(locs1) | count2 <= length(locs2)
       
       if count1 > length(locs1)
           alllocs(count3) = locs2(count2);
           count2 = count2 + 1;
           count3 = count3 + 1;
       elseif count2 > length(locs2)
           alllocs(count3) = locs1(count1);
           count1 = count1 + 1;
           count3 = count3 + 1;
       elseif strcmpi(labs1{count1}, labs2{count2})
           alllocs(count3) = locs1(count1);
           count1 = count1 + 1;
           count2 = count2 + 1;
           count3 = count3 + 1;
       elseif isempty(strmatch(labs1{count1}, labs2, 'exact'))
           alllocs(count3) = locs1(count1);
           count1 = count1 + 1;
           count3 = count3 + 1;
       else 
           alllocs(count3) = locs2(count2);
           count2 = count2 + 1;
           count3 = count3 + 1;
       end;
       
   end;
