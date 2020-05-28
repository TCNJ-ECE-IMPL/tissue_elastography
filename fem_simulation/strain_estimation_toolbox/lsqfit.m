function [a1,a0]=lsqfit(y,x,N)
% LSTSQFIT  least-square straight line fit through 
%	    given data points.
%	    LSTSQFIT(Y,X) returns the slope of the
%	    line through [X,Y]. LSTSQFIT(Y,X,N) 
%	    returns the slope of the line through 
%	    [X(1:N),Y(1:N)]. LSTSQFIT(Y) assumes
%	    Y to be discrete sample points, so
%	    X = linspace(1,length(Y)).
%	    [A1,A0] = LSQFIT returns the slope of fitted 
%      line (A1) and intercept between the fitted 
%      line and Y-axis (A0).

% Written by S. K. Alam: kalam@rrinyc.org

if nargin < 2
   x = linspace(1,length(y),length(y));
   [r,c]=size(y);
   if c==1
      x=x';
   end
end;
if nargin > 2, if length(x) > N & length(y) > N, x = x(1:N); y = y(1:N); end; end;
if nargin == 2
   if length(x)==1
      N=x;
      x = linspace(1,length(y),length(y));
      [r,c]=size(y);
      if c==1
         x=x';
      end
      if length(x) > N, x = x(1:N); y = y(1:N); end
   elseif length(x) ~= length(y)
      error('X and Y should have equal length'); 
   end
end

a = polyfit(x,y,1);
if nargout < 2
    a1 = a(1);
else
    a1 = a(1); a0 = a(2);
end

% avg_x = mean(x);
% avg_y = mean(y);
% avg_x_sq = mean(x.^2);
% avg_y_sq = mean(y.^2);
% avg_xy = mean(x.*y);
% 
% b = (avg_xy - avg_x*avg_y)/(avg_x_sq - avg_x^2);
% a = avg_y - b*avg_x;
% 
% if nargout < 2
%     a1 = b;
% else
%     a0 = a; a1 = b;
% end
