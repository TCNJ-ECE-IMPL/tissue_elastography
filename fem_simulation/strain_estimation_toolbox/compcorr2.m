function C = compcorr2(X,Y,MaxLagR,MaxLagC,MinLagR,MinLagC,Option)
%CORRCOMP2 computes 2-D correlation function
%   COMPCORR2(X,Y,MAXLAGR,MAXLAGC,MINLAGR,MINLAGC,OPTION), 
%   returns the correlation function of size abs(MINLAGR)+MAXLAGR+1 by 
%   abs(MINLAGC)+MAXLAGC+1 If OPTION equals 'coeff', the normalized 
%   correlation function is evaluated.
%
%   COMPCORR2 is normally called by the M function MYXCORR2, and 
%   not by the user.
%   
%   To compile: mcc -irw compcorr2 intersect nargchk unique

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 02-24-99
% Revised: 12-20-02 (SKA)
% Version: 2.0
%
% New in this version: fixed error with lags (now Y is shifted, which is correct)
%
% Copyright © 1999 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

C = zeros(-MinLagR+MaxLagR+1,-MinLagC+MaxLagC+1);
[RowX,ColX] = size(X);
[RowY,ColY] = size(Y);

if strcmpi(Option,'coeff')  % Correlation coefficient function (normalized)
   norm_fac = zeros(-MinLagR+MaxLagR+1,-MinLagC+MaxLagC+1);
   for i=MinLagR:MaxLagR
      for j=MinLagC:MaxLagC
         XixR = 1:RowX;
         YixR = 1 + i:RowY + i;  % Y row indices shifted
         IixR = intersect(XixR,YixR);  % Correlation computed using elements at array intersection
         XidxR = IixR;
         YidxR = IixR - i;  % Re-shifted to get correct Y row indices
         XixC = 1:ColX;
         YixC = 1 + j:ColY + j;  % Y column indices shifted
         IixC = intersect(XixC,YixC);  % Correlation computed using elements at array intersection
         XidxC = IixC;
         YidxC = IixC - j;  % Re-shifted to get correct Y column indices
         Xs = X(XidxR,XidxC);
         Ys = Y(YidxR,YidxC);
         C(i-MinLagR+1,j-MinLagC+1) = sum(sum(Xs.*Ys));
         norm_fac(i-MinLagR+1,j-MinLagC+1) = sqrt(sum(sum(Xs.^2))*sum(sum(Ys.^2)));
     end
   end
   norm_fac(find(norm_fac==0))=Inf;  % such that when divides C, will yield zero
   C = C./norm_fac;
else
   for i=MinLagR:MaxLagR
      for j=MinLagC:MaxLagC
         XixR = 1:RowX;
         YixR = 1 + i:RowY + i;  % Y row indices shifted
         IixR = intersect(XixR,YixR);  % Correlation computed using elements at array intersection
         XidxR = IixR;
         YidxR = IixR - i;  % Re-shifted to get correct Y row indices
         XixC = 1:ColX;
         YixC = 1 + j:ColY + j;  % Y column indices shifted
         IixC = intersect(XixC,YixC);  % Correlation computed using elements at array intersection
         XidxC = IixC;
         YidxC = IixC - j;  % Re-shifted to get correct Y column indices
         Xs = X(XidxR,XidxC);
         Ys = Y(YidxR,YidxC);
         C(i-MinLagR+1,j-MinLagC+1) = sum(sum(Xs.*Ys));
      end
   end
end