function y=tscale(x,str)
%TSCALE time scale (stretch) a signal
%   Y = TSCALE(X,STR) uniformly stretches a signal such that 
%   the endpoint in Y now corresponds to X(LEN*(1-STR)) where 
%   LEN is the length of both X and Y. 
%   STR should be in fraction. If STR is between 1 and 100, 
%   it is assumed to be in percent.
%   
%   Current implementation handles only 1D 
%   signals (both row & column vectors)

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 04-99
% Revised: 2018-01-21 (SKA)
% Version: 1.2
%
% New in this version: replaced 'cubic' with 'pchip'
%
% Copyright © 1999 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if nargin==1, error('Require strain (in percent)!'); end
if nargin==0, error('No input argument!'); end

[row,col]=size(x); % SIZE OF x

StcFac = 1/(1-str); % STRETCH FACTOR

if isreal(x)
   % return row vector if x is a row vector
   if row==1  % row vector x
      t = linspace(0,1,col);
      t_stc = t/StcFac;
      y = interp1(t,x,t_stc,'pchip');
   else % COLUMN-BY-COLUMN OPERATION
      t = linspace(0,1,row)';
      t_stc = t/StcFac;
      y = interp1(t,x,t_stc,'pchip');
   end
else
   % return row vector if x is a row vector
   if row==1  % row vector x
      t = linspace(0,1,col);
      t_stc = t/StcFac;
      yr = interp1(t,real(x),t_stc,'pchip');
      yi = interp1(t,imag(x),t_stc,'pchip');
      y = yr + i*yi;
   else % COLUMN-BY-COLUMN OPERATION
      t = linspace(0,1,row)';
      t_stc = t/StcFac;
      yr = interp1(t,real(x),t_stc,'pchip');
      yi = interp1(t,imag(x),t_stc,'pchip');
      y = yr + i*yi;
   end
end