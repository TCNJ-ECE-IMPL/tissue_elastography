function [str,dsp,rho] = AdapStretch(seg_pre,seg_pst,svmin,svmax)
%ADAPSTRETCH strain using adaptive stretching
%   SYNTAX: ADAPSTRETCH(SEG_PRE,SEG_PST,SVMIN,SVMAX)
%   SEG_PRE: segment of pre-compression echo signal (typically larger than SEG_PST)
%   SEG_PST: segment of post-compression echo signal
%   SVMIN:   minimum (expected) strain
%   SVMAX:   maximum (expected) strain
%   
%   [STR,DSP,RHO] = ADAPSTRETCH; returns strain (STR), displacement (DSP), 
%   correlation (RHO)
%
%   See also: ESTSSTRN, ADAPSTRETCH2D, ESTDISP1D.

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 07-19-00
% Revised: 05-12-09 (SKA)
% Version: 1.2
%
% New in this version: no longer reporting # maximas > 1.1.
%
% Copyright © 2005 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if nargin ~= 4
   fprintf('Number of input arguments = %d\n',nargin);
   error('Must have EXACTLY 4 input arguments')
end

% MAXIMUM LAG FOR CORR FUNC (REDUCES COMPUTATION, FALSE PEAKS)
len_pre = length(seg_pre); len_pst = length(seg_pst);
if len_pre > len_pst
   minlag = -fix(len_pre - 3*len_pst/4);
   maxlag = fix(len_pst/2);
else
   minlag = -fix(len_pre/2);
   maxlag = fix(len_pst - 3*len_pre/4);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STRAIN IS ESTIMATED BY ITERATIVELY STRETCHING THE POSTCOMPRESSION 
% SIGNAL SEGMENT. STRETCH FACTOR THAT PRODUCES THE MAXIMUM CORRELATION 
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

num_highmax = 0;

for k=1:n_init
   seg_stch = tscale(seg_pst,str_init(k)); % temporal stretching
   [C,L] = myxcorr(seg_pre,seg_stch,maxlag,minlag,'cov-coeff');
   [rho_init(k),lag_init(k)] = cosintp(C); % interpolate maximum
   %[rho_init(k),lag_init(k)] = parbintp(C); % interpolate maximum
   if rho_init(k) > 1.1
      num_highmax = num_highmax + 1;
   end
end

[mv,ml] = max(rho_init); % stretch factor with maximum correlation
[mvn,mln] = max([rho_init(1:ml-1) -Inf rho_init(ml+1:end)]); % next highest corr.

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
   seg_stch = tscale(seg_pst,StrVal(StrIdx)); % temporal stretching
   [C,L] = myxcorr(seg_pre,seg_stch,maxlag,minlag,'cov-coeff');
   [ccv,ccl] = cosintp(C,L);
   %[ccv,ccl] = parbintp(C,L);
   if ccv > 1.1
      num_highmax = num_highmax + 1;
   end
   
   if ccv > CorrMax   % If the new CCF is higher
      str = StrVal(StrIdx);  % strain estimates
      CorrNext = CorrMax;
      CorrMax = ccv;
      CorrShift = ccl;
      StrIdx = ~(StrIdx-1) + 1;
      StrVal(StrIdx) = (StrVal(1)+StrVal(2))/2.0;
   else	% If the new CCF is lower than the old one
      StrVal(StrIdx)=(StrVal(1)+StrVal(2))/2.0;
   end
end

%if num_highmax
%   fprintf('# maximum > 1.1: %d.\n',num_highmax)
%end

% need to incorporate stretch factor in ccl
if nargout == 2, dsp = ccl; end
if nargout == 3, dsp = ccl; rho = CorrMax; end