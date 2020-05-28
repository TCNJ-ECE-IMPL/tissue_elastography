function [rfseq,filenames,rfpath] = readeyeseq(files,flag)
%READEYESEQ reads a sequence of RF data in EYE format
%
%   SYNTAX: RFSEQ = READEYESEQ(FILES,FLAG);
%           FILES: 
%           FLAG: 
%      Both input parameters are optional. 
%   User will be prompted for the filename(s). The routine automatically 
%   recognizes ATL (HDI) and calls the appropriate routine (READEYE_HDI)
%   to read individual files.
%
%   See also: READEYE, READEYE_HDI

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 06-29-99
% Revised: 10-08-11 (SKA)
% Version: 3.1.1
%
% New in this version: changed call to readeye to ReadEye to supress case-error                   
%
% Copyright © 1999 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if exist('files','var')
   if (ischar(files)) && (length(files) == 3)
      flag = files; clear files; % FIRST ARGUMENT IS REALLY FLAG
   end
end

if exist('flag','var')
   %if any(strcmpi(flag,'t'))
   %   tgc_flag = 'y';
   %end
   if strcmpi(flag,'zpl') % ZERO PAD, LEFT ('pre') OF ARRAY. HOW TO HANDLE IF FLAG = 'tzpl' or 'zplt'?
      zpad_flag = 'y';
      paddir = 'pre';
   elseif strcmpi(flag,'zpr') % ZERO PAD, RIGHT ('post') OF ARRAY
      zpad_flag = 'y';
      paddir = 'post';
   elseif strcmpi(flag,'zpb') % ZERO PAD, LEFT & RIGHT ('both') OF ARRAY
      zpad_flag = 'y';
      paddir = 'both';
   else
      zpad_flag = 'n';
   end
else
   zpad_flag = 'n';
end

if ~exist('files','var')
   [files,p] = uigetfile('*.eye','Choose EYE file sequence','MultiSelect','on'); % GET EYE FILE NAMES
end
if ~iscell(files) % MAKE SURE THAT files IS A CELL ARRAY EVEN IF ONLY ONE FILE IS CHOSEN
   f = cell(1);
   f{1} = files;
   files = f;
end
num=size(files,2);
files = sort(files);
if exist('p','var') % ADD PATH TO FILENAME, IF AVAILABLE
   FILES = cell(size(files));
   for k = 1:num
      FILES{k} = [p files{k}];
   end
else
   FILES = files;
end

if strcmpi(zpad_flag,'y')
   m = 1; n = 1;
   for k=1:num % FIND LARGEST SIZE SCAN IN SEQUENCE
      m1 = geteyehdr(FILES{k},'ppline');
      n1 = geteyehdr(FILES{k},'noline');
      m = m1*(m1 >= m) + m*(m1 < m);
      n = n1*(n1 >= n) + n*(n1 < n);
   end
else
   m = geteyehdr(FILES{1},'ppline');
   n = geteyehdr(FILES{1},'noline');
end

CurrentFname = FILES{1};
hv = geteyehdr(CurrentFname,'hver'); % CHECK IF ATL (HDI) FILE
if isempty(hv)
   hdi_flag = 'y';
   if exist('tgc_flag','var'), clear tgc_flag; end
   tgc_flag = input('Compensate for TGC (y/n)? [n]: ','s');
   if isempty(tgc_flag)
      tgc_flag = 'n';
   end
else
    hdi_flag = 'n';
end
fprintf('Now opening %s\n',CurrentFname);
if strcmpi(hdi_flag,'y')
   RF = readeye_hdi(CurrentFname,tgc_flag);
else
   RF = ReadEye(CurrentFname);
end

% [m,n] = size(RF); % INDIVIDUAL SCAN SIZE
rfseq = zeros(m,n,num); % INITIALIZE RF SCAN SEQUENCE
[mk,nk] = size(RF); % SIZE OF SCAN # 1
if strcmpi(zpad_flag,'y') % ZEROPAD
   if strcmpi(paddir,'both')
      mpad = fix((m - mk + 1)/2); npad = fix((n - nk + 1)/2);
   else
      mpad = m - mk; npad = n - nk;
   end
   RF = padarray(RF,[mpad npad],paddir);
end
rfseq(:,:,1) = RF; % FIRST IN THE SEQUENCE

for k=2:num
   CurrentFname = FILES{k};
   fprintf('Now opening %s\n',CurrentFname);
   if strcmpi(hdi_flag,'y')
      RF = readeye_hdi(CurrentFname,'n');
   else
      RF = ReadEye(CurrentFname);
   end
   [mk,nk] = size(RF);
   if strcmpi(zpad_flag,'y') % ZEROPAD
      if strcmpi(paddir,'both')
         mpad = fix((m - mk + 1)/2); npad = fix((n - nk + 1)/2);
      else
         mpad = m - mk; npad = n - nk;
      end
      RF = padarray(RF,[mpad npad],paddir);
   else
      if (mk ~= m) || (nk ~= n)
         error('Zeropadding NOT chosen...All RF frames should be of the same size')
      end
   end
   rfseq(:,:,k) = RF;
end

if nargout == 2, filenames = files; end
if nargout == 3, filenames = files; if exist('p','var'), rfpath = p; end; end