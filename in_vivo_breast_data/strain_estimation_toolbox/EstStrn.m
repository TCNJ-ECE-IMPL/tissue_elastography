function [str,dsp,ccf] = EstStrn(rf1,rf2,wsize1,wsize2,wshift,app_strn,min_strn,max_strn,alg_flag,lsz,dsp_flag,stg_flag)
%ESTSTRN 1-D strain estimators (spatio-temporal algorithms)
%   SYNTAX: ESTSTRN(RF1,RF2,WSIZE1,WSIZE2,WSHIFT,APP_STRN,MIN_STRN,MAX_STRN,ALG_FLAG,LSZ,DSP_FLAG,STG_FLAG)
%   RF1:      pre-compression echo signal 
%   RF2:      post-compression echo signal 
%   WSIZE1:   pre-compression window size [samples] 
%   WSIZE2:   post-compression window size (>=WSIZE1) [samples] 
%   WSHIFT:   window shifted between displacement estimates [samples] 
%   APP_STRN: applied strain
%   MIN_STRN: mimimum (expected) strain 
%   MAX_STRN: maximum (expected) strain 
%   ALG_FLAG: estimation algorithm. Choices are - 
%      'a': adaptive stretching 
%      'g': gradient of estimated displacements (no stretching) 
%      'ls': least squares fit of estimated displacements (no stretching) 
%      'us': gradient of estimated displacements (uniform stretching) 
%      'lsus': least squares fit of estimated displacements (uniform stretching) 
%      'lsus-2s':  
%      'lscm': least squares fit of correlation maximum 
%      'lscmus': least squares fit of corr max (w/ uniform stretching) 
%      'vs': variable stretching 
%      'lsvs': least squares fit of estimated displacements (w/ variable stretching). 
%          With both 'vs' and 'lsvs' flags, elastograms are computed at varying 
%          stretch factors that correspond to 0*APP_STRN, �*APP_STRN, �*APP_STRN, 
%          �*APP_STRN, 1.0*APP_STRN, and  1�*APP_STRN. These are combined at the 
%          end by choosing the strain estimate corresponding to the maximum
%          correlation among the 6. 
%      'ss': smoothing splines fit of estimated displacements (no stretching) 
%      'ssus': smoothing splines fit of estimated displacements (uniform stretching) 
%      'ss0': smoothing splines fit of estimated displacements (no stretching, no weighting) 
%      'ssus0': smoothing splines fit of estimated displacements (uniform stretching, no weighting) 
%      'ssN': smoothing splines fit of estimated displacements (no stretching, weighted by corr.^N).
%          Allowed values for N: 0:9 (default=4). Thus, 'ss', in fact, is 'ss4'.
%      'ssusN': smoothing splines fit of estimated displacements (uniform stretching, weighted by 
%          corr.^N). Allowed values for N: 0:9 (default=4). Thus, 'ssus', in fact, is 'ssus4'.
%   LSZ:      number of displacement samples used in least squares fit (used only for 'ls','lsus',
%          'lscm','lscmus','lsvs'). For 'ss' and 'ssus' it denotes the smoothing parameter rho. 
%          (The default is 0.85. At 0.35, the results are very similar to 'lsus', with slightly 
%          better resolution. At 0.75, the resolution is still good, and at 0.65, the appearance
%          is much nicer.) 
%   DSP_FLAG: Displacement estimation option. Allowed values: 'none','coeff','matlab',
%          'mcoeff','sad','ssd','fast','fastcoeff'. DEFAULT ('fastcoeff').
%   STG_FLAG: Use staggered estimates to avoid the "worm" artifact? (Default is 'y'.)
%   
%   [STR,DSP,CCF] = EST_STRN returns Estimated Strains (STR), Estimated 
%   Displacements (DSP), and Correlation Coefficients (CCF).
%
%   See also: ESTSPECSTRN, ESTSTRN2D

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 07-17-00
% Revised: 02-24-11 (SKA)
% Version: 4.11
%
% New in this version: Changed 'eststrn' to 'EstStrn' in the code 
%
% Copyright � 2000 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________


% LATER ON, INCLUDE DEFAULT VALUES FOR APP_STRN,MIN_STRN, AND MAX_STRN, IF 
% NOT PASSED FROM THE CALLING PROGRAM.

% DEFAULT FLAG VALUES
if ~exist('alg_flag','var'), alg_flag = 'lsus-2s'; end % ALGORITHM FLAG <---ssus-2s??
if ~exist('dsp_flag','var'), dsp_flag = 'fastcoeff'; end % DISPLACEMENT ESTIMATION OPTION
if ~exist('stg_flag','var'), stg_flag = 'Y'; end % USE STAGGERED ESTIMATES?

if strcmpi(alg_flag,'g') || strcmpi(alg_flag,'us') || strcmpi(alg_flag,'us-2s') || strcmpi(alg_flag,'vs') ||...
   strcmpi(alg_flag,'ls') || strcmpi(alg_flag,'lsvs') || strcmpi(alg_flag,'lsus') || strcmpi(alg_flag,'lsus-2s')% LEAST SQUARES FIT
   if ~exist('lsz','var'), lsz = 7; end
end

% SMOOTHING SPLINES DEFAULTS
if strncmpi(alg_flag,'ss',2)
   if strncmpi(alg_flag,'ssus',4)
      if length(alg_flag)==4
         N = 4; % DEFAULT VALUE
      else
         N = str2num(alg_flag(5)); % EXTRACTED POWER OF CORRELATION FUNCTION FOR WEIGHTS
         alg_flag = 'ssus';
      end
   else
      if strncmpi(alg_flag,'ss',2) && length(alg_flag)==2
         N = 4; % DEFAULT VALUE
      else
         N = str2num(alg_flag(3)); % EXTRACTED POWER OF CORRELATION FUNCTION FOR WEIGHTS
         alg_flag = 'ss';
      end
   end
end
if strcmpi(alg_flag,'ss') || strcmpi(alg_flag,'ssus') % SMOOTHING SPLINE
      if ~exist('lsz','var'), lsz = 0.85; end
end

if strcmpi(alg_flag,'g') || strcmpi(alg_flag,'ls') || strcmpi(alg_flag,'us') || ...
      strcmpi(alg_flag,'lsus') || strcmpi(alg_flag,'ss') || strcmpi(alg_flag,'ssus')
   if strcmpi(alg_flag,'us') || strcmpi(alg_flag,'lsus') || strcmpi(alg_flag,'ssus') % UNIFORM STRETCHING OF POSTCOMPRESSION SIGNALS
      rf2 = tscale(rf2,app_strn);
   end
   [dsp,ccf] = EstDisp1D(rf1,rf2,wsize1,wsize2,wshift,dsp_flag); % DISPLACEMENT ESTIMATES
   
    % RESTORE DISPLACEMENTS REMOVED IN TEMPORAL STRATECHING
   if strcmpi(alg_flag,'us') || strcmpi(alg_flag,'lsus') || strcmpi(alg_flag,'ssus')
      if wsize1 > wsize2, offset = app_strn*wsize2/2;
      else offset = app_strn*wsize1/2;
      end
      dsp = dsp + (0:size(dsp,1)-1)'*ones(1,size(dsp,2))*app_strn*wshift + offset;
   end
   dsp = medfilt2(dsp,[3 3],'symmetric'); % MEDIAN FILTERING TO REMOVE SHOT NOISE
   %dsp = medfilt2(dsp,[5 5]); % MEDIAN FILTERING TO REMOVE SHOT NOISE

   % STAGGERED ESTIMATES NECESSARY? ONE OPTION IS TO CALL DISP2STRN A FEW TIMES, EACH TIME WITH LESS THAN 50% OVERLAP
   wsize = (wsize2>wsize1)*wsize1+(wsize1>wsize2)*wsize2;
   wrat = wsize/wshift; % RATIO BETWEEN WINDOW SHIFT AND SIZE
   if ( wrat > 2) && strcmpi(stg_flag,'y')
      wratNEW = ceil(wsize/(2*wshift));
      wshiftNEW = wratNEW*wshift; % ASSURE THAT OVERLAP IS 50% OR LESS
      for k=1:wratNEW
         d11 = dsp(k:wratNEW:(end-wratNEW+k),:);
         c11 = ccf(k:wratNEW:(end-wratNEW+k),:);
         %[s1,d1] = disp2strn(d11,wsize1,wsize2,wshiftNEW,app_strn,alg_flag,lsz);
         if strncmpi(alg_flag,'ss',2)
            s1 = disp2strn(d11,c11,wsize1,wsize2,wshiftNEW,app_strn,alg_flag,lsz,N);
         else
            s1 = disp2strn(d11,c11,wsize1,wsize2,wshiftNEW,app_strn,alg_flag,lsz);
         end
         if k == 1 % INITIALIZE STR AND DSP
            [ms,ns] = size(s1);
            str1 = zeros(ms*wratNEW,ns); dsp1 = str1;
            kk = 1:ms;
         end
         str1((kk-1)*wratNEW+k,:) = s1;
         %dsp1((kk-1)*wratNEW+k,:) = d1;
      end
      str = str1; %dsp = dsp1;
   else
      %[str,dsp] = disp2strn(dsp,wsize1,wsize2,wshift,app_strn,alg_flag,lsz);
      if strncmpi(alg_flag,'ss',2)
        str = disp2strn(dsp,ccf,wsize1,wsize2,wshift,app_strn,alg_flag,lsz,N);
      else
        str = disp2strn(dsp,ccf,wsize1,wsize2,wshift,app_strn,alg_flag,lsz);
      end
   end

   % MINIMUM AND MAXIMUM STRAINS
   mask1 = str > min_strn; str = str.*mask1 + ~mask1*min_strn;
   mask2 = str < max_strn; str = str.*mask2 + ~mask2*max_strn;
   
elseif strcmpi(alg_flag,'us-2s') || strcmpi(alg_flag,'lsus-2s')
   mx = size(rf1,1); nx = size(rf1,2);
   %if ~exist('lsz','var'), lsz = 7; end
   [s1,d1,c] = EstStrn(rf1,rf2,wsize1,wsize2,wshift,app_strn,min_strn,max_strn,alg_flag(1:end-3),lsz,dsp_flag);
   m1 = 7; n1 = 5;
   % MEDIAN FILTERING TO REMOVE SHOT NOISE
   s11 = medfilt2(s1,[m1 n1]);
   d11 = medfilt2(d1,[m1 n1]);
   % MOVING AVERAGE FOR SMOOTHING
   s12 = movavg2(s11,[m1 n1]); % CHANGED FROM movavg
   d111 = movavg2(d11,[m1 n1]); % CHANGED FROM movavg
   % d111 = d1; % NO FILTERING. RMS ERROR BET'N rf1 and rf2_stc HIGHER
   % FIRST FORCE MONOTONICITY (INCREASING)
   % WITH CURVE FITTING, THIS MAY NOT BE NECESSARY
   d12d = diff(d111);
   d12n = d12d.*(d12d >= 0) + eps*(d12d < 0); % 2ND TERM TO MAKE IT INCREASING
   % d12s = cumsum(d12n,1);
   d12 = [d111(1,:);d111(1:end-1,:) + d12n];
   
   % INTERPOLATE FOR DISPLACEMENTS AT ALL mx POINTS
   wsize = max([wsize1 wsize2]);
   pos  = (wsize/2:wshift:mx-wsize/2)';
   pos_full = (1:mx)'; % SHOULD IT BE (0:mx-1)?
   d2 = zeros(mx,nx);
   for k=1:nx
      d2(:,k) = interp1(pos,d12(:,k),(1:mx)','cubic'); % CURVE FITTING TOOLBOX FOR SMOOTHER FITS?
   end
   % THESE DISPLACEMENTS ARE TO BE USED FOR VARIABLE STRETCHING
   t = (0:(mx-1))'*ones(1,nx);
   t_stc = t - d2;
   
   % STRETCHING
   rf2_stc = zeros(size(rf2));
   for k=1:nx
      rf2_stc(:,k) = interp1(t(:,k),rf2(:,k),t_stc(:,k),'cubic');
   end
   
   % COMPUTE STRAIN. REMEMBER, SIGNALS ARE ALREADY STRETCHED.
   if strcmpi(alg_flag,'lsus-2s')
      %if ~exist('lsz','var'), lsz = 7; end
      [s2,d2,c] = EstStrn(rf1,rf2_stc,wsize1,wsize2,wshift,app_strn,min_strn,max_strn,'ls',lsz,dsp_flag);
   else
      [s2,d2,c] = EstStrn(rf1,rf2_stc,wsize1,wsize2,wshift,app_strn,min_strn,max_strn,'g',lsz,dsp_flag);
   end
   % CORRECT RESIDUAL DISPLACEMENTS
   d3 = d1 - d2;
   d3 = medfilt2(d3,[5 5]); % SHOT NOISE REMOVED
   
   % COMPUTE STRAIN
   if strcmpi(alg_flag,'lsus-2s')
      %if ~exist('lsz','var'), lsz = 7; end
      stry = LinReg(d3,lsz,1);
      str = stry/wshift; % DIVIDE BY WINDOW SHIFT
   else
      if size(d3,1) == 1 || size(d3,2) == 1 % ROW/COLUMN VECTOR
         str = gradient(d3)/wshift;
      else
         [strx,stry] = gradient(d3);
         str = stry/wshift;
      end
   end
   
   % str = medfilt2(str,[5 5]);
   dsp = d3;
   ccf = c;
   
   % MINIMUM AND MAXIMUM STRAINS
   mask1 = str > min_strn; str = str.*mask1 + ~mask1*min_strn;
   mask2 = str < max_strn; str = str.*mask2 + ~mask2*max_strn;

elseif strcmpi(alg_flag,'vs') || strcmpi(alg_flag,'lsvs')
   % 'vs': VARIABLE STRETCHING + GRADIENT. 'lsvs': VARIABLE STRETCHING + LEAST SQUARES FIT
   %if ~exist('lsz','var'), lsz = 7; end
   if app_strn < 0.04
      n = 5;
   else
      n = fix(100*app_strn) + 1; 
   end
   aapp_strn = app_strn:-app_strn/(n-1):0; % RANGE OF ASSUMED APPLIED STRAINS FOR GLOBAL STRETCHING
   aapp_strn = [aapp_strn 1.5*app_strn];
   n = length(aapp_strn);
   % SHOULD WE ALSO TRY 2*APP_STRN?
   % STRETCHING BY FACTOR CORRESPONDING TO APPLIED STRAIN + SIZE OF STRAIN MAPS
   [str,dsp,ccf] = EstStrn(rf1,rf2,wsize1,wsize2,wshift,aapp_strn(1),min_strn,max_strn,'us');
   str1 = zeros(size(str,1),size(str,2),n); dsp1 = zeros(size(dsp,1),size(dsp,2),n); ccf1 = zeros(size(ccf,1),size(ccf,2),n);
   str1(:,:,1) = str; dsp1(:,:,1) = dsp; ccf1(:,:,1) = ccf;
   % VARIABLE STRETCHING
   for k=2:n
      [str,dsp,ccf] = EstStrn(rf1,rf2,wsize1,wsize2,wshift,aapp_strn(k),min_strn,max_strn,'us');
      str1(:,:,k) = str; dsp1(:,:,k) = dsp; ccf1(:,:,k) = ccf;
   end
   
   % FINALLY, COMBINE THE SIX STRAINS
   [mv,iv] = max(ccf1,[],3);
   if strcmpi(alg_flag,'vs')
      for k = 1:size(str1,1)
         for l = 1:size(str1,2)
            str(k,l) = str1(k,l,iv(k,l));
            dsp(k,l) = dsp1(k,l,iv(k,l));
            ccf(k,l) = ccf1(k,l,iv(k,l));
         end
      end
   elseif strcmpi(alg_flag,'lsvs')
      K = size(ccf1,1); L = size(ccf1,2);
      for k=1:K
         for l=1:L
            if (k > 3) && (k <= K-3), str(k-3,l) = str1(k-3,l,iv(k,l)); end
            dsp(k,l) = dsp1(k,l,iv(k,l));
            ccf(k,l) = ccf1(k,l,iv(k,l));
         end
      end
   end
   
   % MINIMUM AND MAXIMUM STRAINS
   mask1 = str > min_strn; str = str.*mask1 + ~mask1*min_strn;
   mask2 = str < max_strn; str = str.*mask2 + ~mask2*max_strn;
   
elseif strcmpi(alg_flag,'a') % ADAPTIVE STRETCHING
   [row,col]=size(rf1);
   [row2,col2]=size(rf2);
   if (row~=row2) || (col~=col2)
      error('Pre- and post-compression data has to be same size');
   end
   if row==1  % IF ROW VECTORS
      len=col;
      rf1=rf1';  % CONVERT TO COLUMN VECTOR
      rf2=rf2';  % CONVERT TO COLUMN VECTOR
      col=1;
   else
      len=row;
   end
   
   if wsize1 > wsize2
      num_str = fix((len-max([wsize1 wsize2])+wshift)/wshift);  % #STRAIN ESTIMATES/COLUMN
   else
      num_str = fix((len-wsize2+wshift)/wshift);  % #STRAIN ESTIMATES/COLUMN
   end
   % COULD USE: num_str = fix((len-max([wsize1 wsize2])+wshift)/wshift);
   str = zeros(num_str,col);
   dsp = zeros(num_str,col);
   ccf = zeros(num_str,col);
   
   for l=1:col
      for k=1:num_str
      loc1 = (k-1)*wshift+1;
      % loc2 = (k-1)*wshift+1;
      loc2 = round((k-1)*wshift*(1-app_strn)+1); % ACCOUNT FOR AVERAGE SHIFT DUE TO COMPRESSION
         tmp1 = rf1(loc1:loc1+wsize1-1,l);  % LARGER WINDOW
         tmp2 = rf2(loc2:loc2+wsize2-1,l);
         [s,d,c] = AdapStretch(tmp1,tmp2,min_strn,max_strn);
         str(k,l) = s; % STRAIN
         dsp(k,l) = d + (loc1 - loc2); % DELAY
         ccf(k,l) = c; % Corr Max
      end
   end

   str = medfilt2(str,[5 5]);
   % MOVING AVERAGE?

elseif strcmpi(alg_flag,'lscm') || strcmpi(alg_flag,'lscmus')
   fprintf('Sarayu has been developing %s; method not finalized yet. Exiting ESTSTRN...\n',algflag);
elseif strcmpi(alg_flag,'as') || strcmpi(alg_flag,'sr') || strcmpi(alg_flag,'srv')
   fprintf('Strain estimation algorithm: %s. Call ESTSPECSTRN. Exiting ESTSTRN...\n',alg_flag);
else
   error('Improper strain estimation algorithm')
end

%COMPUTE STRAIN FROM DISPLACEMENT
function [s,d] = disp2strn(d,c,wsize1,wsize2,wshift,app_strn,method,lsz,N)
%COMPUTE STRAIN FROM DISPLACEMENTS
s = zeros(size(d,1)-1,size(d,2)); % INITIALIZE STRAIN ARRAY

if strcmpi(method,'g') || strcmpi(method,'us') % GRADIENT METHODS
   if size(d,1) == 1 || size(d,2) == 1 % ROW/COLUMN VECTOR
      s = gradient(d)/wshift;
   else
      [strx,stry] = gradient(d);
      s = stry/wshift; % DIVIDE BY WINDOW SHIFT
   end

elseif strcmpi(method,'ls') || strcmpi(method,'lsus') % LEAST SQUARES FIT
   %if ~exist('lsz','var'), lsz = 7; end
   stry = LinReg(d,lsz,1);
   s = stry/wshift;

elseif strcmpi(method,'ss') || strcmpi(method,'ssus') % FIT TO A SMOOTHING SPLINE
   for k = 1:size(d,2)
      [d(:,k),cf_] = smoothspline((1:size(d,1))',d(:,k),lsz,c(:,k).^N); % lsz IS THE SMOOTHING PARAMETER
      [breaks,coefs,npieces,ord,dim] = unmkpp(cf_.p); % EXTRACT SPLINE COEFFICIENTS
      s(:,k) = coefs(:,3)/wshift; % 1ST ORDER COEFFICIENT IS STRAIN. GRADIENT NOT NEEDED
   end
end
return

%SMOOTH DISPLACEMENTS FOR THE '-2s' METHODS
function ds = smoothdisp(d)
return