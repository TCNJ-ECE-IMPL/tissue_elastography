function C = compcorr(X,Y,MaxLag,MinLag,Option)
%COMPCORR computes correlation function.
%   COMPCORR(X,Y,MAXLAG,OPTION), returns the correlation function 
%   of length 2*MAXLAG-1. If OPTION equals 'coeff', the normalized 
%   correlation function is evaluated.
%
%   COMPCORR is normally called by the M function MYXCORR, and 
%   not by the user.
%   
%   To compile: mcc -irw compcorr intersect nargchk unique

%   if Option == 'F', call Fourier based routine.

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 02-26-99
% Revised: 12-20-02 (SKA)
% Version: 2.0
%
% New in this version: fixed error with lags (now Y is shifted, which is correct)
%
% Copyright © 1999 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

C = zeros(-MinLag+MaxLag+1,1);
LenX = length(X);
LenY = length(Y);

% LenNew = LenX + LenY - 1;
% LenCcf = abs(LenX - LenY) + 1;
% c1 = real(ifft(conj(fft([X-mean(X) zeros(1,LenNew-LenX)])).*fft([Y-mean(Y) zeros(1,LenNew-LenY)])));

% Since the mean has been taken out upon data read, no mean subtraction
if strcmpi(Option,'coeff')  % Correlation coefficient function (normalized)
   for i=MinLag:MaxLag
      Xix = 1:LenX;
      Yix = 1 + i:LenY + i;  % Y indices shifted
      Iix = intersect(Xix,Yix);  % Correlation computed using elements at array intersection
      Xidx = Iix;
      Yidx = Iix - i;  % Re-shifted to get correct Y indices
      Xs = X(Xidx);
      Ys = Y(Yidx);
      norm_fac = sqrt(sum(Xs.^2)*sum(Ys.^2));
      if norm_fac==0
         C(i-MinLag+1) = 0;
      else
         C(i-MinLag+1) = sum(Xs.*Ys)/norm_fac;
      end
   end
else   % Unnormalized correlation function
   for i=MinLag:MaxLag
      Xix = 1:LenX;
      Yix = 1 + i:LenY + i;  % Y indices shifted
      Iix = intersect(Xix,Yix);  % Correlation computed using elements at array intersection
      Xidx = Iix;
      Yidx = Iix - i;  % Re-shifted to get correct Y indices
      Xs = X(Xidx);
      Ys = Y(Yidx);
      C(i-MinLag+1) = sum(Xs.*Ys);
   end
end