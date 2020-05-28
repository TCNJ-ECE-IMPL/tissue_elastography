function [disp,mcval,cc,lags]=estdisp1d(frame1,frame2,wsize,wsize2,wshift,lagrng,method)
%ESTDISP1D 1-D axial displacements using correlation, SAD or similar search
%  ESTDISP1D(FRAME1,FRAME2,WSIZE,WSIZE2,WSHIFT,LAGRNG,METHOD) computes the 
%  relative displacements between the windowed segments of the (rf) frames 
%  FRAME1 and FRAME2. 
%  WSIZE: window size for FRAME1 (samples)
%  WSIZE2: window size for FRAME2 (WSIZE2 <= WSIZE)
%  WSHIFT: amount each window is shifted for the next estimate
%  LAGRNG: range of lag values to be used in correlation analysis. To distinguish 
%       from other numeric input arguments, this has to be a 2x1 or 1x2 array. 
%       The function will otherwise complain with an error message.
%  METHOD: correlation method used. 
%      'none':   unnormalized correlation function using "myxcorr"
%      'coeff':  (DEFAULT) normalized correlation function using "myxcorr"
%      'matlab'  calls MATLAB's xcorr (no normalization).
%      'mcoeff': calls MATLAB's xcorr with 'coeff' option
%      'sad':    uses my SAD (sum-absolute-difference) routine
%      'ssd':    uses my SAD (sum-square-difference) routine
%
%  If WSIZE2 and/or WSHIFT are not passed, they are set equal to WSIZE.
%
%  First 3 input arguments (FRAME1,FRAME2,WSIZE) are essential. If there are less 
%   than 7 arguments, with the last argument being a string, it is assumed to be 
%   the argument "method." In that case, the previous argument is also checked to 
%   see if it is a 2x1 or 1x2 array; if so, it is assumed to be "lagrng." For less 
%   than 7 arguments, if the last argument is not "method," then it is checked to 
%   see if it is a 2x1 or 1x2 array, and if so, it is assumed to be "lagrng."
%
%  [DISP,MCVAL] = ESTDISP1D returns both displacements (DISP) and 
%   correlations (MCVAL).
%
%  [DISP,MCVAL,CC,LAGS] = ESTDISP1D also returns correlation functions (CC) 
%   and lags (LAGS).
%
%  [DISP,MCVAL,CC] = ESTDISP1D will produce error message, asking to add 
%   output argument LAGS.
%
%  See also ESTDISP2D, MYXCORR

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 07-00-98
% Revised: 04-12-07 (SKA)
% Version: 2.1
% New in this version: if FRAME1 & FRAME2 are the only input arguments,
% bulk displacement between FRAME1 & FRAME2 (have to be A-line Segments) 
% is now computed.
%
% Copyright © 1998 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if nargin==7
   if length(lagrng(:))~=2
      fprintf('LAGRNG is a %dx%d array!\n',size(lagrng));
      error('It has to be a 2x1 or 1x2 array.')
   end
elseif nargin==6
   if ischar(lagrng) % 6th argument is 'method'
      method = lagrng; clear lagrng
      if length(wshift(:)) == 2 % 5th argument is lagrng
         lagrng = wshift; clear wshift
      end
   end
elseif nargin==5
   if ischar(wshift) % 5th argument is 'method'
      method = wshift; clear wshift
      if length(wsize2(:)) == 2 % 4th argument is lagrng
         lagrng = wsize2; clear wsize2
      end
   elseif length(wshift(:)) == 2 % 5th argument is lagrng
      lagrng = wshift; clear wshift
   end
elseif nargin==4  % only four arguments, no wshift entered
   if ischar(wsize2) % 4th argument is 'method'
      method = wsize2; clear wsize2
      if length(wsize(:)) == 2 % 3rd argument is lagrng
         error('For 4 input arguments, the 3rd argument has to be wsize.')
      end
   elseif length(wsize2(:)) == 2 % 4th argument is lagrng
      lagrng = wsize2; clear wsize2
   end
elseif nargin==3  % only three arguments, wsize2 & wshift not entered
   if ischar(wsize) | length(wsize(:)) == 2 % 3rd argument is 'method' or lagrng
      error('For 3 input arguments, the 3rd argument has to be wsize.')
   end
elseif nargin==2   % ONLY TWO FRAMES frame1 AND frame2 PASSED, COMPUTE BULK DISPLACEMENT BETWEEN
   wsize = size(frame1,1);
   wsize2 = size(frame2,1);
else   % AT LEAST frame1,frame2 HAVE TO BE PASSED
   fprintf('#Input arguments = %d\n\n',nargin);
   error('Not enough arguments')
end

if ~exist('wsize2','var'), wsize2 = wsize; end
if ~exist('wshift','var'), wshift = min([wsize wsize2]); end
if ~exist('lagrng','var')
   if wsize > wsize2, lagrng = [-fix(wsize2/2) fix(wsize - wsize2/2)];
   else, lagrng = [-fix(wsize2 - wsize/2) fix(wsize/2)];
   end
end
if ~exist('method','var'), method = 'coeff'; end

if nargin==2 % COMPUTE BULK DISPLACEMENT BETWEEN TWO A-LINE SEGMENTS
   [disp,mcval]=estdisp1d(frame1,frame2,wsize,wsize2);
   return
end

[row,col]=size(frame1);
[row2,col2]=size(frame2);

if row==1  % if row vectors
   len=col;
   frame1=frame1';  % convert to column vector
   frame2=frame2';  % convert to column vector
   col=1;
else
   len=row;
end

if wsize > wsize2
   num_disp = fix((len-wsize+wshift)/wshift);  % #displacement estimates/column
else
   num_disp = fix((len-wsize2+wshift)/wshift);  % #displacement estimates/column
end


if (num_disp ~= 1) % BULK DISPLACEMENT BETWEEN TWO A-LINES
   if (row~=row2) | (col~=col2), error('Frames should be same size'); end
end

disp = zeros(num_disp,col);
mcval = zeros(num_disp,col);

MinLag = lagrng(1); % FOR myxcorr ONLY
MaxLag = lagrng(2);

if nargout==3 
   fprintf('Number of input arguments: 3.\n');
   fprintf('Allowed numbers: 1, 2, or 4.\n');
   error('Correlation function cannot be returned without lags.')
elseif nargout==4 % CORRELATION FUNCTIONS WILL BE RETURNED
   cc = zeros(num_disp,col,MaxLag-MinLag+1); % INITIALIZE FOR FASTER EXECUTION
end

for k=1:num_disp
   loc = (k-1)*wshift+1;
   tmp1 = frame1(loc:loc+wsize-1,:);  % LARGER WINDOW
   tmp2 = frame2(loc:loc+wsize2-1,:);
   for l=1:col
      if strcmpi(method,'none') | strcmpi(method,'coeff') | strcmpi(method,'fast')...
            | strcmpi(method,'fastcoeff') | strcmpi(method,'sad') | strcmpi(method,'ssd')
         [C,L] = myxcorr(tmp1(:,l),tmp2(:,l),MaxLag,MinLag,method);
      elseif strcmpi(method,'mcoeff')
         [C,L] = xcorr(tmp1(:,l),tmp2(:,l),MaxLag,'coeff');
      elseif strcmpi(method,'matlab')
         [C,L] = xcorr(tmp1(:,l),tmp2(:,l),MaxLag);
      end
      
      if ~isreal(C) | ~isreal(L)
         error('Correlation routine returned complex values!')
      end
      
      if nargout == 4, cc(k,l,:) = C; end % FOR PASSING CORRELATION FUNCTIONS
      
      if strcmpi(method,'sad') | strcmpi(method,'ssd')
         [pval,ploc]=parbintp(-C,L);  % need to compute minimum for SAD
      else
         [pval,ploc]=cosintp(C,L);  % gives the subsample CCF maximum
      end
      % disp(k,l)=L(mloc)+ploc;  % Actual delay
      disp(k,l)=ploc;  % Delay
      if ~isreal(disp(k,l))
         warning('Complex displacement produced!')
      end
      mcval(k,l)=pval;
   end
end

if nargout == 4, lags = L; end

if row==1, disp=disp'; mcval=mcval'; end  % if row vector, row vector is returned