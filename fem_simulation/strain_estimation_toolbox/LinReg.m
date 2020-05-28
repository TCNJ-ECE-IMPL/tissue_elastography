function [a1,a0] = linreg(x,lsqsize,lsqshift)
%LINREG linear regression
%   LINREG(X,LSQSIZE,LSQSHIFT) returns the linear regression 
%   slope of X. Size of linear regression kernel is LSQSIZE 
%   and the shift between estimation points is LSQSHIFT.
%
%   [A1,A0]=LINREG returns both slope and intercept at zero.

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 01-23-01
% Revised: 01-23-01 (SKA)
% Version: 1.1
%
% New in this version: added default values for lsqsize & lsqshift
%
% Copyright © 2001 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

error(nargchk(1,3,nargin)) % # INPUTS BET'N 1 AND 3

% DEFAULT VALUES
if nargin == 1
   lsqsize = 7;
   lsqshift = 1;
elseif nargin == 2
   lsqshift = 1;
end

num_col = fix((size(x,1) - lsqsize + lsqshift)/lsqshift);
num_row = size(x,2);
for k = 1:num_col
   for l = 1:num_row
      loc = (k-1)*lsqshift+1;
      [a1(k,l),a0(k,l)] = lsqfit(x(loc:loc+lsqsize-1,l));
   end
end