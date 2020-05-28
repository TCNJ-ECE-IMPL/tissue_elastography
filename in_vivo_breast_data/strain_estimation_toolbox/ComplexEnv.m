function ce=complexenv(rf,f0,fs)
%COMPLEXENV complex envelope of an RF signal
%
%   COMPLEX(RF,F0,FS) returns the complex envelope of 
%   the RF signal (RF). 
%   F0: center frequency in MHa (default - 5 MHz)
%   FS: sampling rate in MHz (default - 50 MHz)
% 
%   See also: LPF

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 10-25-00
% Revised: 11-26-08 (SKA)
% Version: 1.1
%
% New in this version: Changed the LPF from (f0/2,f0/2) to (f0,f0/32) so
%                      that magnitude of complex envelope equals envelope
%
% Copyright © 2000 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if nargin < 3, fs = 50e6; end;
if nargin < 2, f0 = 5e6; end;

[row,col]=size(rf);
Size = length(rf);

ce = zeros(size(rf));

if row==1 % signal passed is an one-row array
   t = linspace(1,Size,Size);
   Carrier = exp(i*(2*pi*f0/fs)*t); % complex envelope in one shot
   ce1 = 2*rf.*Carrier;	% Mix with the carrier. Factor of two, because of losing ½ power in LPF.
   %ce = lpf(ce1,f0,f0/16,fs);	% complex envelope (LPF: H(f)=0, f>1.0625*f0. H(f) = 1, f<0.9375*f0)
   ce = lpf(ce1,f0,f0/32,fs);	% complex envelope (LPF: H(f)=0, f>33/32*f0. H(f) = 1, f<31/32*f0)
   %ce = lpf(ce1,246/256*f0,f0/16,fs);	% complex envelope (LPF: H(f)=0, f>f0. H(f) = 1, f<15/16*f0)
   %ce = lpf(ce1,501/512*f0,f0/32,fs);	% complex envelope (LPF: H(f)=0, f>f0. H(f) = 1, f<31/32*f0)
else	% otherwise, each column of signal is processed (including 1-column signals)
   t = linspace(1,Size,Size)';
   Carrier = exp(i*(2*pi*f0/fs)*t); % complex envelope in one shot
   for k=1:col
      ce1 = 2*rf(:,k).*Carrier;	% Mix with the carrier. Factor of two, because of losing ½ power in LPF.
      %ce(:,k) = lpf(ce1,f0,f0/16,fs);	% complex envelope (LPF: H(f)=0, f>1.0625*f0. H(f) = 1, f<0.9375*f0)
      ce(:,k) = lpf(ce1,f0,f0/32,fs);	% complex envelope (LPF: H(f)=0, f>33/32*f0. H(f) = 1, f<31/32*f0)
      %ce(:,k) = lpf(ce1,246/256*f0,f0/16,fs);	% complex envelope (LPF: H(f)=0, f>f0. H(f) = 1, f<15/16*f0)
      %ce(:,k) = lpf(ce1,501/512*f0,f0/32,fs);	% complex envelope (LPF: H(f)=0, f>f0. H(f) = 1, f<31/32*f0)
   end
end