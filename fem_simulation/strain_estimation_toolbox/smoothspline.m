function [ys,cf] = smoothspline(x,y,p,w)
%SMOOTHSPLINE Fit data points to a smoothing spline
%   SYNTAX: SMOOTHSPLINE(Xdata,Yata,P,W)
%    Xdata = X Column Vector
%    Ydata = Y Column Vector
%        P = Smoothing Parameter (default=0.99. 0 is Linear Fit. 1 is Cubic Spline Fit.)
%        W = Weights [default=ones(size(x))]
%   
%   [YS,CF] = SMOOTHSPLINE also returns a cfit (Curve Fitting
%   Toolbox) object CF.
%
%   See also: FIT, SMOOTH, SPLINE

% Author:	S. K. Alam
% Email: kalam@rrinyc.org
% Date: 11-24-08
% Revised: 11-24-08
% Version: 1.0
%
% New in this version: version 1.0
%
% Copyright © 2008 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if ~exist('p','var'), p = 0.99; end % SMOOTHING PARAMETER
if ~exist('w','var'), w = ones(size(x)); end % ALL WEIGHTS ARE UNITY

% CREATE FIT
fo = fitoptions('method','SmoothingSpline','SmoothingParam',p);
fo.Weights = w;
fin = isfinite(x) & isfinite(y);
ft = fittype('smoothingspline');

% FIT THIS MODEL USING THE DATA
cf = fit(x(fin),y(fin),ft,fo);

ys = cf(x); % ASSIGN TO OUTPUT PARAMETER