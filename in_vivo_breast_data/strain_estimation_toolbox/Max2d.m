function [mval,mlocR,mlocC]=max2d(x)
%MAX2D finds the absolute maximum of matrix
%   MVAL=MAX2D(X) gives the maximum value in matrix X.
%   [MVAL,MLOCR,MLOCC]=MAX2D gives the row location 
%   (MLOCR) and column location (MLOCC) of the max MVAL.
%
%   See also MAX

% Version 1.0:
%
% Copyright (c) September 1998.
% Last revised September 15, 1998.
% This matlab program was developed by S. Kaisar Alam.
% Questions & suggestions to <kalam@rrinyc.org>
%___________________________________________________________

if ~isreal(x), x=abs(x); end

[mvR,mlR]=max(x,[],1);  % find row max
[vR,cR]=max(mvR);
mlocR=mlR(cR);

[mvC,mlC]=max(x,[],2);  % find column max
[vC,cC]=max(mvC);
mlocC=mlC(cC);

if vR~=vC, error('column and row max not same'), end

mval=vR;