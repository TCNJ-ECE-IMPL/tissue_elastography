function y=tscale2(x,str,dim,zlat,nu)
%TSCALE2 2-D time scale a signal
%   Y = TSCALE2(X,STR,DIM,NU,ZLAT) uniformly stretches a signal such that 
%      the endpoint in Y now corresponds to X(LEN*(1-STR)) where LEN is 
%      the length of both X and Y. 
%   STR:  should be in fraction. If STR is between 1 and 100, it is 
%      assumed to be in percent.
%   DIM:  Dimension of model. For incompressible material, '2D' means 
%      that lateral displacement at a point equals axial displacement. 
%      For '3D', lateral displacement equals half of axial displacement. 
%      For '1D', lateral displacement is assumed not to occur.
%   ZLAT: lateral position of zero displacement, around which signals 
%      are scaled
%   NU:   Poisson's ratio (default = 0.495 - incompressible fluid). 
%      WILL BE IMPLEMENTED IN LATER VERSIONS using the definition 
%      Da = - NU*Dl, Da is the change in the cross-sectional area 
%      and Dl is the increase in length. Alternate definition 
%      using measures per unit length/area, NU = - (Da/a)/(Dl/l). 
%
%   WARNING: All input arguments should be in order (e.g., NU can be 
%      passed only if DIM is passed). 
%      Minimum required input arguments: X, STR. 
%
%   See also: TSCALE

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 09-27-05
% Revised: 2018-01-21 (SKA)
% Version: 1.3
%
% New in this version: replaced 'cubic' with 'pchip'
%
% Copyright © 2005 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if nargin==0, error('No input argument!'); end

[row,col]=size(x); % SIZE OF x

if nargin < 2, error('Require strain (in percent)!'); end
if nargin < 3, dim = '1D'; end % NO LATERAL MOTION
if nargin < 4 & ~strcmpi(dim,'1D')  % ZERO LATERAL MOTION
   zlat = 0; 
end 

if str >= 1, str = str/100; end % STRAIN EXPRESSED IN PERCENT
StcFac_t = 1/(1-str); % STRETCH FACTOR

if strcmpi(dim,'1D')
   if isreal(x)
      % return row vector if x is a row vector
      if row==1  % row vector x
         t = linspace(0,1,col);
         t_stc = t/StcFac_t;
         y = interp1(t,x,t_stc,'cubic');
      else % COLUMN-BY-COLUMN OPERATION
         t = linspace(0,1,row)';
         t_stc = t/StcFac_t;
         y = interp1(t,x,t_stc,'cubic');
      end
   else % COMPLEX INPUT
      % return row vector if x is a row vector
      if row==1  % row vector x
         t = linspace(0,1,col);
         t_stc = t/StcFac_t;
         yr = interp1(t,real(x),t_stc,'cubic');
         yi = interp1(t,imag(x),t_stc,'cubic');
         y = yr + i*yi;
      else % COLUMN-BY-COLUMN OPERATION
         t = linspace(0,1,row)';
         t_stc = t/StcFac_t;
         yr = interp1(t,real(x),t_stc,'cubic');
         yi = interp1(t,imag(x),t_stc,'cubic');
         y = yr + i*yi;
      end
   end
elseif strcmpi(dim,'2D') | strcmpi(dim,'3D')
   if strcmpi(dim,'2D')
      StcFac_l = 1/(1+str); % LATERAL SCALE FACTOR
   else
      StcFac_l = 1/(1+str/2); % LATERAL MOTION HALF OF AXIAL MOTION
   end
   if isreal(x)
      % return row vector if x is a row vector
      if row==1  % row vector x
         t = linspace(0,1,col);
         t_stc = t/StcFac_t;
         lat = linspace(0,1,row);
         y = interp1(t,x,t_stc,'cubic'); 
      else % COLUMN-BY-COLUMN OPERATION
         y = ts2(x,StcFac_t,StcFac_l);
         y = inpaint_nans(y,2); % REMOVE NaNs
         % y(find(~isfinite(y))) = 0; % ZERO OUTSIDE THE RANGE OF l and x
      end
   else % COMPLEX INPUT
      % return row vector if x is a row vector
      if row==1  % row vector x
         t = linspace(0,1,col);
         t_stc = t/StcFac_t;
         yr = interp1(t,real(x),t_stc,'cubic');
         yi = interp1(t,imag(x),t_stc,'cubic');
         y = yr + i*yi;
      else % COLUMN-BY-COLUMN OPERATION
         yr = ts2(real(x),StcFac_t,StcFac_l); 
         yr = inpaint_nans(yr,2); % REMOVE NaNs
         yi = ts2(imag(x),StcFac_t,StcFac_l); 
         yi = inpaint_nans(yi,2); % REMOVE NaNs
         y = yr + i*yi;
         % y(find(~isfinite(y))) = 0; % ZERO OUTSIDE THE RANGE OF l and x
      end
   end
else
   error('Unknown dimensionality!')
end

function y = ts2(x,StcFac_t,StcFac_l)
% THE ACTUAL COMPUTATION
[row,col]=size(x); % SIZE OF x
t = linspace(0,1,row)';
t_stc = t/StcFac_t;
lpos = linspace(-0.5,0.5,col);
lpos_scl = lpos/StcFac_l;
% [lpos,t] = meshgrid(lpos,t); [lpos_scl,t_stc] = meshgrid(lpos_scl,t_stc);
y = interp2(lpos,t,x,lpos_scl,t_stc,'*cubic');
% y(find(~isfinite(y))) = 0; % ZERO OUTSIDE THE RANGE OF l and x
% y = interp2(lpos,t,x,lpos_scl,t_stc,'*cubic');
% y = inpaint_nans(y,2); % REMOVE NaNs
% '*cubic' is faster for equally spaced X & Y.
% Use 'griddata' for ununiform vectors.