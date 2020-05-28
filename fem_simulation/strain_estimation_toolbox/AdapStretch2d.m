function [sR,sC,dR,dC,rho] = AdapStretch2d(block_pre,block_pst,svmin,svmax,dim)
%ADAPSTRETCH2D strain using adaptive stretching
%   SYNTAX: ADAPSTRETCH(SEG_PRE,SEG_PST,SVMIN,SVMAX)
%   SEG_PRE: block of pre-compression echo signal (typically larger than SEG_PST)
%   SEG_PST: block of post-compression echo signal
%   SVMIN:   minimum (expected) strain
%   SVMAX:   maximum (expected) strain
%   DIM:     dimensionality of the problem
%   
%   [STR,DSP,RHO] = ADAPSTRETCH; returns strain (STR), displacement (DSP), 
%   correlation (RHO)

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 10-04-05
% Revised: 10-07-05 (SKA)
% Version: 1.0
%
% New in this version: version 1.0
%
% Copyright © 2005 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________


if nargin ~= 5
   fprintf('Number of input arguments = %d\n',nargin);
   error('Must have EXACTLY 5 input arguments')
end

% MAXIMUM LAGS FOR CORR FUNC (REDUCES COMPUTATION, FALSE PEAKS)
lenR_pre = size(block_pre,1); lenR_pst = size(block_pst,1);
if lenR_pre > lenR_pst
   minlagR = -fix(lenR_pre - 3*lenR_pst/4);
   maxlagR = fix(lenR_pst/2);
else
   minlagR = -fix(lenR_pre/2);
   maxlagR = fix(lenR_pst - 3*lenR_pre/4);
end
lenC_pre = size(block_pre,2); lenC_pst = size(block_pst,2);
if lenC_pre > lenC_pst
   minlagC = -fix(lenC_pre - 3*lenC_pst/4);
   maxlagC = fix(lenC_pst/2);
else
   minlagC = -fix(lenC_pre/2);
   maxlagC = fix(lenC_pst - 3*lenC_pre/4);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STRAIN IS ESTIMATED BY ITERATIVELY DEFORMING THE POSTCOMPRESSION 
% 2D SIGNAL SEGMENT. STRETCH FACTOR THAT PRODUCES THE MAXIMUM CORRELATION 
% WITH THE PRECOMPRESSION SIGNAL SEGMENT IS USED TO ESTIMATE STRAIN. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INITIAL COARSE SEARCH 
if svmax > 0.20
   n_init = 41; % NUMBER OF COARSE POINTS
elseif svmax > 0.10
   n_init = 21;
else
   n_init = 11;
end
str_init = svmin:(svmax-svmin)/(n_init-1):svmax;
rho_init = zeros(1,n_init);
lag_init = zeros(1,n_init);

num_highmax = 0; % MAXIMUM ABOVE UNITY BECAUSE OF INTERPOLATION

for k=1:n_init % ONLY ONE FOR LOOP. AXIAL AND LATERAL STRAINS ARE RELATED. 
   block_stch = tscale2(block_pst,str_init(k),dim); % 2D temporal stretching
   [C,LR,LC] = myxcorr2(block_pre,block_stch,...
      maxlagR,maxlagC,minlagR,minlagC,'coeff');
   [rho_init(k),lagR_init(k),lagC_init(k)] = parbintp2(C,LR,LC); % interpolate maximum
   if rho_init(k) > 1.1
      num_highmax = num_highmax + 1;
   end
end

[mv,ml] = max(rho_init); % stretch factor with maximum correlation
[mvn,mln] = max([rho_init(1:ml-1) -Inf rho_init(ml+1:end)]); % next highest corr.

cclR = lagR_init(ml);
cclC = lagC_init(ml);

ccv = rho_init(ml); % maximum corr
ccl = lag_init(ml); % lag there
CorrMax = ccv;      % maximum corr
CorrNext = mvn;     % next lower
StrVal = zeros(1,2);	% two alternating strain values
StrVal = [str_init(ml) str_init(mln)];  % maximum and the next higher

% BINARY (FINER) SEARCH 
MaxIter = 10;  % maximum number of iterations allowed
IterNo = 1;  % iteration number
str = StrVal(1);  % strain estimates
StrIdx = 2; % index of maximum; probably start with 2 to save a step
StrVal(StrIdx) = (StrVal(1)+StrVal(2))/2.0; % new value
while (CorrMax-CorrNext)>1e-5 & abs(StrVal(1)-StrVal(2))>1e-5 & IterNo<=MaxIter
   IterNo = IterNo + 1;
   block_stch = tscale2(block_pst,StrVal(StrIdx),dim); % 2-D temporal stretching+
   [C,LR,LC] = myxcorr2(block_pre,block_stch,maxlagR,maxlagC,'coeff');
   [ccv,cclR,cclC] = parbintp2(C,LR,LC); % interpolate maximum
   if ccv > 1.1
      num_highmax = num_highmax + 1;
   end

   if ccv > CorrMax   % If the new CCF is higher than the old one
      str = StrVal(StrIdx);  % strain estimates
      CorrNext = CorrMax;
      CorrMax = ccv;
      CorrShiftR = cclR;
      CorrShiftC = cclC;
      StrIdx = ~(StrIdx-1) + 1;
      StrVal(StrIdx) = (StrVal(1)+StrVal(2))/2.0;
   else	% If the new CCF is lower
      StrVal(StrIdx)=(StrVal(1)+StrVal(2))/2.0;
   end
end

if num_highmax
   fprintf('# maximum > 1.1: %d.\n',num_highmax)
end

sR = str;
dm = str2num(dim(1));

% need to incorporate stretch factor in cclR and cclC
if nargout == 2, sC = -str/dm; end
if nargout == 3, sC = -str/dm; dR = cclR; end
if nargout == 4, sC = -str/dm; dR = cclR; dC = cclC; end
if nargout == 5, sC = -str/dm; dR = cclR; dC = cclC; rho = CorrMax; end