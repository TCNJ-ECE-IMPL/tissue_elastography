function [dispR,dispC,mcval]=estdisp2d(frame1,frame2,wsizeR,wsizeC,wsizeR2,wsizeC2,wshiftR,wshiftC,lagrngR,lagrngC,method)
%ESTDISP2D 2-D displacements (axial & lateral) using correlation, SAD or similar search
%  ESTDISP2D(FRAME1,FRAME2,WSIZER,WSIZEC,WSIZER2,WSIZEC2,WSHIFTR,WSHIFTC,LAGRNGR,LAGRNGC,METHOD)
%  computes the relative 2-D displacements between the windowed segments of the 
%  (rf) frames FRAME1 and FRAME2.
%  WSIZER,WSIZEC:   window sizes for FRAME1 (samples) in row and column directions 
%                   (WSIZER and WSIZEC are always passed in pair). 
%  WSIZER2,WSIZEC2: window sizes for FRAME2 (WSIZER2 <= WSIZER, WSIZEC2 <= WSIZEC) 
%                   in row and column directions (WSIZER2 and WSIZEC2 are always 
%                   passed in pair). 
%  WSHIFTR,WSHIFTC: amount each window is shifted for the next estimate in row and 
%                   column directions (WSHIFTR and WSHIFTC are always passed in pair). 
%  LAGRNGR,LAGRNGC: range of lag values in row and column directions to be used in 
%                   correlation analysis. To distinguish from other numeric input 
%                   arguments, this has to be a 2x1 or 1x2 array. The function will 
%                   otherwise complain with an error message (LAGRNGR and LAGRNGC may
%                   not have to be in pair. If only LAGRNGR is passed, LAGRNGC is set
%                   equal to LAGRNGR). 
%  METHOD:          correlation method used. 
%                   'none': unnormalized correlation function using "myxcorr2"
%                   'coeff' (DEFAULT): normalized correlation function (CF) using "myxcorr2"
%                   'fast': unnormalized CF (use MATLAB's function XCORR2). Same output 
%                   as 'none', but faster.
%                   'fastcoeff': Normalized CF (use XCORR2 for numerator and Corr2NormFac.dll 
%                   to compute the denominator). Same output as 'coeff', but faster.
%                   'matlab': calls MATLAB's xcorr2 (no normalization).
%                   'sad':    uses my SAD (sum-absolute-difference) routine
%                   'ssd':    uses my SSD (sum-squared-difference) routine
% If WSIZER2 and WSHIFTR are not passed, they are set equal to WSIZER. If WSIZER2 
% and WSHIFTR are not passed, they are set equal to WSIZER. At least first 4 input 
% arguments are essential. If there are less than 11 arguments, with the last argument 
% being a string, it is assumed to be the argument "method." 
%
% [DISPR,DISPC,MCVAL]=ESTDISP2D returns displacements and correlation max MCVAL.
%
%  See also ESTDISP1D, MYXCORR, MYXCORR2.

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 09-11-98
% Revised: 04-12-07 (SKA)
% Version: 2.1
% New in this version: if FRAME1 & FRAME2 are the only input arguments,
% bulk displacement between FRAME1 & FRAME2 is now computed.
%
% Copyright © 1998 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if nargout==1, warning('only row component of displacement returned'), end

if nargin==11 % ALL INPUT PARAMETERS PASSED. LATER PERFORM CHECK FOR LARRNG 
              % (SHOULD BE CONSECUTIVE OR ONLY ONE FOR SAME VALUES FOR BOTH).
   if length(lagrngR(:))~=2
      fprintf('LAGRNGR is a %dx%d array!\n',size(lagrngR));
      fprintf('It has to be a 2x1 or 1x2 array. Exiting...')
   end
   if length(lagrngC(:))~=2
      fprintf('LAGRNGC is a %dx%d array!\n',size(lagrngC));
      fprintf('It has to be a 2x1 or 1x2 array. Exiting...')
   end
elseif nargin==10
   if ischar(lagrngC), method = lagrngC; clear lagrngC; end % lagrngC REALLY method
elseif nargin==9
   if ischar(lagrngR), method = lagrngR; clear lagrngR; end % lagrngR REALLY method
elseif nargin==8
   if length(wshiftR(:))==2 % wshiftR REALLY lagrngR
      lagrngR = wshiftR; clear wshiftR
      if length(wshiftC(:))==2 % wshiftC REALLY lagrngC
         lagrngC = wshiftC; clear wshiftC
      elseif ischar(wshiftC) % wshiftC REALLY method
         method = wshiftC; clear wshiftC
      else
         warning('WSHIFTC cannot be after LAGRNGR. Clearing WSHIFTC. Will be set equal to min([WSIZEC WSIZEC2])...')
         clear wshiftC
      end
   end
elseif nargin==7
   if length(wshiftR(:))==2 % wshiftR REALLY lagrngR
      lagrngR = wshiftR; clear wshiftR
   elseif ischar(wshiftR) % wshiftR REALLY method
      method = wshiftR; clear wshiftR
   else
      warning('WSHIFTR passed without WSHIFTC. Clearing WSHIFTR. Will be set equal to min([WSIZER WSIZER2])...')
      clear wshiftR
   end
elseif nargin==6
   if length(wsizeR2(:))==2 % wsizeR2 REALLY lagrngR
      lagrngR = wsizeR2; clear wsizeR2
      if length(wsizeC2(:))==2 % wsizeC2 REALLY lagrngC
         lagrngC = wsizeC2; clear wsizeC2
      elseif ischar(wsizeC2) % wsizeC2 REALLY method
         method = wsizeC2; clear wsizeC2
      else
         warning('WSIZEC2 cannot be after LAGRNGR. Clearing WSIZEC2. Will be set equal to WSIZEC...')
         clear wsizeC2
      end
   end
elseif nargin==5
   if length(wsizeR2(:))==2 % wsizeR2 REALLY lagrngR
      lagrngR = wsizeR2; clear wsizeR2
   elseif ischar(wsizeR2) % wsizeR2 REALLY method
      method = wsizeR2; clear wsizeR2
   else
      warning('WSIZER2 passed without WSIZEC2. Clearing WSIZER2. Will be set equal to WSIZER2...')
      clear wsizeR2
   end
elseif nargin==3   % ONLY wsizeR CANNOT BE INPUT, wsizeC ALSO HAS TO BE PASSED
   fprintf('#Input arguments = %d\n\n',nargin);
   error('Not enough arguments')
elseif nargin<2   % AT LEAST frame1,frame2 HAVE TO BE PASSED
   fprintf('#Input arguments = %d\n\n',nargin);
   error('Not enough arguments')
end

if nargin==2 % COMPUTE BULK DISPLACEMENT BETWEEN TWO FRAMES
   wsizeR = size(frame1,1);
   wsizeC = size(frame1,2);
   wsizeR2 = size(frame2,1);
   wsizeC2 = size(frame2,2);
   wshiftR = max([wsizeR wsizeR2]);
   wshiftC = max([wsizeC wsizeC2]);
end

if ~exist('wsizeR2','var'), wsizeR2 = wsizeR; end
if ~exist('wsizeC2','var'), wsizeC2 = wsizeC; end
if ~exist('wshiftR','var'), wshiftR = min([wsizeR wsizeR2]); end
if ~exist('wshiftC','var'), wshiftC = min([wsizeC wsizeC2]); end
%if ~exist('lagrngR','var'), lagrngR = [-fix(min([wsizeR wsizeR2])/2) fix(min([wsizeR wsizeR2])/2)]; end
if ~exist('lagrngR','var')
   if wsizeR > wsizeR2, lagrngR = [-fix(wsizeR2/2) fix(wsizeR - wsizeR2/2)];
   else, lagrngR = [-fix(wsizeR2 - wsizeR/2) fix(wsizeR/2)];
   end
end
if ~exist('lagrngC','var')
   if wsizeC > wsizeC2, lagrngC = [-fix(wsizeC2/2) fix(wsizeC - wsizeC2/2)];
   else, lagrngC = [-fix(wsizeC2 - wsizeC/2) fix(wsizeC/2)];
   end
end
if ~exist('method','var'), method = 'coeff'; end

% if nargin==2 % COMPUTE BULK DISPLACEMENT BETWEEN TWO FRAMES
%    [dispR,dispC,mcval]=estdisp2d(frame1,frame2,wsizeR,wsizeC,wsizeR2,wsizeC2,wshiftR,wshiftC);
%    return
% end

[row,col]=size(frame1); [row2,col2]=size(frame2);

num_dispR = fix((row - max([wsizeR wsizeR2]) + wshiftR)/wshiftR);  % #DISPLACEMENT ESTIMATES/COLUMN
num_dispC = fix((col - max([wsizeC wsizeC2]) + wshiftC)/wshiftC);  % #DISPLACEMENT ESTIMATES/ROW

if ~((num_dispR==1) & (num_dispC==1)) % IF NOT BULK DISPLACEMENT
   if ((row~=row2) | (col~=col2))
      error('Frames should be same size');
   end
end

MinLagR = lagrngR(1); MaxLagR = lagrngR(2); % RANGE OF CORRELATION LAGS IN THE ROW DIRECTION
MinLagC = lagrngC(1); MaxLagC = lagrngC(2); % RANGE OF CORRELATION LAGS IN THE COLUMN DIRECTION

% INITIALIZE TO ZERO
dispR = zeros(num_dispR,num_dispC); dispC = zeros(num_dispR,num_dispC);
Cval = zeros(num_dispR,num_dispC);

for k=1:num_dispR
   for l=1:num_dispC
      locR = (k-1)*wshiftR+1;
      locC = (l-1)*wshiftC+1;
      tmp1 = frame1(locR:locR+wsizeR-1,locC:locC+wsizeC-1);  % LARGER WINDOW
      tmp2 = frame2(locR:locR+wsizeR2-1,locC:locC+wsizeC2-1);
      [C,LagR,LagC] = myxcorr2(tmp1,tmp2,MaxLagR,MaxLagC,MinLagR,MinLagC,method);
      if ~isreal(C) | ~isreal(LagR) | ~isreal(LagC)
         error('Correlation routine returned complex values!')
      end
      if strcmpi(method,'sad')
         %[mval,mlocR,mlocC]=max2d(C);  % find maximum of sampled CCF
         %pval=mval; plocR=LagR(mlocR); plocC=LagC(mlocC);
         [pval,plocR,plocC] = parbintp2(-C,LagR,LagC);  % MINIMIZE C MEANS MAXIMIZE -C
         dispR(k,l) = plocR;
         dispC(k,l) = plocC;
         Cval(k,l) = pval;
         %keyboard
      else
         [pval,plocR,plocC] = parbintp2(C,LagR,LagC);  % PARABOLIC INTERPOLATION (2-D)
         dispR(k,l) = plocR;
         dispC(k,l) = plocC;
         Cval(k,l) = pval;
      end
      if ~isreal(dispR(k,l)) | ~isreal(dispC(k,l))
         warning('Complex displacement produced!')
      end
      %keyboard
   end
end

if nargout==3, mcval=Cval; end  % returning maximum correlation values