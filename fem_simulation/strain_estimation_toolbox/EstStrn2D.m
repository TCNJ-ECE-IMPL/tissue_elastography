function [strR,strC,dspR,dspC,ccf] = eststrn2d(rf1,rf2,wsizeR1,wsizeC1,wsizeR2,wsizeC2,wshiftR,wshiftC,...
    app_strn,min_strn,max_strn,alg_flag,lsz,dim,dsp_flag)
%ESTSTRN2D 2-D strain estimators
%   SYNTAX: EST_STRN(RF1,RF2,WSIZER1,WSIZEC1,WSIZER2,WSIZEC2,WSHIFTR,WSHIFTC,APP_STRN,MIN_STRN,MAX_STRN,ALG_FLAG,LSZ,DIM,DSP_FLAG)
%   RF1:      pre-compression echo signal
%   RF2:      post-compression echo signal
%   WSIZER1:  pre-compression window size (# of rows or axial) [samples]
%   WSIZEC1:  pre-compression window size (# of columns or lateral) [samples]
%   WSIZER2:  (row) post-compression window size (>=WSIZE1) [samples]
%   WSIZEC2:  (column) post-compression window size (>=WSIZE1) [samples]
%   WSHIFTR:  (row) window shifted between displacement estimates [samples]
%   WSHIFTC:  (column) window shifted between displacement estimates [samples]
%   MIN_STRN: mimimum (expected) strain 
%   MAX_STRN: maximum (expected) strain 
%             Output strain STR is hard limited between MIN_STRN and MAX_Strn.
%   ALG_FLAG: estimation algorithm. Choices are - 'cm': correlation magnitude.
%      'g2': gradient of estimated 2-D displacements (no stretching) 
%      'ls2': least squares fit of estimated 2-D displacements (no stretching) 
%      'us2': gradient of estimated 2-D displacements (uniform stretching) 
%      'lsus2': least squares fit of estimated 2-D displacements (uniform stretching) 
%      'a2': adaptive 2-D stretching 
%      'vs2': variable 2-D stretching 
%      'lsvs2': least squares fit of estimated 2-D displacements (w/ variable stretching). 
%          With both 'vs' (gradient) and 'lsvs' (least squares fit) flags, elastograms 
%          are computed at varying stretch factors, which correspond to 0*APP_STRN, 
%          ¼*APP_STRN, ½*APP_STRN, ¾*APP_STRN, 1.0*APP_STRN, and  1½*APP_STRN. These are 
%          combined at the end by choosing the strain estimate corresponding to the maximum 
%          correlation among the 6 at each window. 
%   LSZ:      number of displacement samples used in least squares fit (used only for 
%          'ls','lsus','lsvs'. 
%   DIM:      Dimension of the model for use with tscale2. Required only for 'us2', 
%          'lsus2', 'vs2', and 'lsvs2'. Choices are:
%      '1D': uniform stretching in the axial direction only
%      '2D':  axial stretching and lateral shrinking/contraction. '2D' model assumed, 
%         meaning that the area remains unchanged for an infinitesimal rectangle
%      '3D':  axial stretching and lateral as well as out-of-plane contraction. '3D' 
%         model assumed; the volume remains unchanged for an infinitesimal cube
%   DSP_FLAG: correlation method used (to compute displacement). Choices are: 
%      'none', 'coeff', 'fast', 'fastcoeff' (DEFAULT), 'matlab', 'sad', and 'ssd'.
%      See help file for EstDisp2D for details about these methods. 
%
%   [STR,DSP,CCF] = ESTSTRN2D returns Estimated Strains (STR), Estimated 
%   Displacements (DSP), and Correlation Coefficients (CCF).
%
%   See also: ESTSSTRN, ESTDISP2D, ESTDISP1D.

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 07-17-00
% Revised: 09-28-05 (SKA)
% Version: 3.1
%
% New in this version: Fixed the order of inputs "dim" and "dsp_flag". 
%          2D Adaptive Stretching still not working.
%
% Copyright © 2000 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if ~exist('dsp_flag','var'), dsp_flag = 'fastcoeff'; end
if ~exist('dim','var'), dim = '3D'; end

if strcmpi(alg_flag,'g2') | strcmpi(alg_flag,'ls2') | strcmpi(alg_flag,'us2') | strcmpi(alg_flag,'lsus2')
   if strcmpi(alg_flag,'us2') | strcmpi(alg_flag,'lsus2') % UNIFORM STRETCHING OF POSTCOMPRESSION SIGNALS
      rf2 = tscale2(rf2,app_strn,dim);
   end
   [dspR,dspC,ccf] = EstDisp2D(rf1,rf2,wsizeR1,wsizeC1,wsizeR2,wsizeC2,wshiftR,wshiftC,dsp_flag); % 2D DISPLACEMENT ESTIMATES
   dspR = medfilt2(dspR,[5 5]); % MEDIAN FILTERING TO REMOVE SHOT NOISE
   dspC = medfilt2(dspC,[5 5]); % COLUMN (HORIZONTAL) DISPLACEMENT
   if strcmpi(alg_flag,'us2') | strcmpi(alg_flag,'lsus2')
      if wsizeR1 > wsizeR2
         offsetR = app_strn*wsizeR2/2;
      else
         offsetR = app_strn*wsizeR1/2;
      end
      dspR = dspR + (0:size(dspR,1)-1)'*ones(1,size(dspR,2))*app_strn*wshiftR + offsetR; % RESTORE REMOVED DISP.
      if wsizeC1 > wsizeC2
         offsetC = app_strn*wsizeC2/2;
      else
         offsetC = app_strn*wsizeC1/2;
      end
      dspC = dspC + ones(1,size(dspC,1))'*(0:size(dspC,2)-1)*app_strn*wshiftC + offsetC; % RESTORE REMOVED DISP.
   end
   if strcmpi(alg_flag,'g2') | strcmpi(alg_flag,'us2') % GRADIENT METHODS
      if (size(dspR,1) == 1) | (size(dspR,2) == 1) % ROW/COLUMN VECTOR
         str = gradient(dspR);
         strR = str/wshiftR; % DIVIDE BY WINDOW SHIFT
         strC = zeros(size(strR));
      else
         [strx,stry] = gradient(dspR);
         strR = stry/wshiftR; % DIVIDE BY WINDOW SHIFT
         [strx,stry] = gradient(dspC);
         strC = strx/wshiftR;
      end
   elseif strcmpi(alg_flag,'ls2') | strcmpi(alg_flag,'lsus2') % LEAST SQUARES FIT
      if ~exist('lsz','var'), lsz = 7; end
      stry = linreg(dspR,lsz,1);
      strR = stry/wshiftR; % DIVIDE BY WINDOW SHIFT
      strx = linreg(dspC',lsz,1)';
      strC = strx;
   end
   % MINIMUM AND MAXIMUM STRAINS
   mask1 = strR > min_strn; strR = strR.*mask1 + ~mask1*min_strn;
   mask2 = strR < max_strn; strR = strR.*mask2 + ~mask2*max_strn;
   mask1 = strC > min_strn; strC = strC.*mask1 + ~mask1*min_strn;
   mask2 = strC < max_strn; strC = strC.*mask2 + ~mask2*max_strn;
   
elseif strcmpi(alg_flag,'a2') % 2-D ADAPTIVE STRETCHING
   [row,col]=size(rf1);
   [row2,col2]=size(rf2);
   if (row~=row2) | (col~=col2)
      error('Pre- and post-compression data has to be same size');
   end
   if row==1     % SINGLE ROW
      [strC,dspC,ccf] = eststrn(rf1,rf2,wsizeC1,wsizeC2,wshiftC,app_strn,min_strn,...
         max_strn,'a',dsp_flag);
      strR = zeros(size(strC)); dspR = zeros(size(dspC)); 
      return
   elseif col==1 % SINGLE COLUMN
      [strR,dspR,ccf] = eststrn(rf1,rf2,wsizeR1,wsizeR2,wshiftR,app_strn,min_strn,...
         max_strn,'a',dsp_flag);
      strC = zeros(size(strR)); dspC = zeros(size(dspR)); 
      return
   end
   
   num_strR = fix((row - max([wsizeR1 wsizeR2]) + wshiftR)/wshiftR);  % #STRAIN ESTIMATES/COLUMN
   num_strC = fix((col - max([wsizeC1 wsizeC2]) + wshiftC)/wshiftC);  % #STRAIN ESTIMATES/ROW

% INITIALIZE TO ZERO
   strR = zeros(num_strR,num_strC); strC = zeros(num_strR,num_strC);
   dispR = zeros(num_strR,num_strC); dispC = zeros(num_strR,num_strC);
   Cval = zeros(num_strR,num_strC);
   
   for k=1:num_strR
      for l=1:num_strC
         loc1R = (k-1)*wshiftR + 1; % PRE-COMPRESSION (ROW DIRECTION)
         loc1C = (l-1)*wshiftC + 1;  % PRE-COMPRESSION (COLUMN DIRECTION)
         % loc2R = (k-1)*wshiftR + 1;
         loc2R = round((k-1)*wshiftR*(1-app_strn)+1); % ACCOUNT FOR AVERAGE SHIFT DUE TO COMPRESSION
         loc2C = round((l-1)*wshiftC*(1+app_strn/2)+1); % ASSUMING A 2D MODEL
         tmp1 = rf1(loc1R:loc1R+wsizeR1-1,loc1C:loc1C+wsizeC1-1);  % PRECOMPRESSION, LARGER WINDOW
         tmp2 = rf2(loc2R:loc2R+wsizeR2-1,loc2C:loc2C+wsizeC2-1);  % POSTCOMPRESSION
         [sR,sC,dR,dC,c] = adapstretch2d(tmp1,tmp2,min_strn,max_strn,dim);
         strR(k,l) = sR; % AXIAL STRAIN
         dspR(k,l) = dR + (loc1R - loc2R); % AXIAL DELAY
         strC(k,l) = sR; % LATERAL STRAIN
         dspC(k,l) = dC + (loc1R - loc2R); % LATERAL DELAY
         ccf(k,l) = c; % Corr Max
      end
   end
elseif strcmpi(alg_flag,'cm') % CORRELATION MAGNITUDE
   % [r,c,m]=fhe_disp(rf1,rf2,232,24,32,4,16,2);
   [r,c,m]=fhe_disp(rf1,rf2,wsizeR1,wsizeC1,wsizeR2,wsizeC2,wshiftR,wshiftC);
   str = []; dsp = []; ccf = m;
   return
else
   error('Improper strain estimation algorithm')
end

% function 
% return

% function 
% return