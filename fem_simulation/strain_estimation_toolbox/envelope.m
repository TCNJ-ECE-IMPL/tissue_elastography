function Env=envelope(rf,n)
% ENVELOPE computes the envelope of an RF line/frame
%   envelope(rf) computes the envelope of the RF echo: 
%   rf, using the Hilbert transform algorithm. 
%   envelope(rf,n) uses n-point FFT to reduce computation 
%   time, if the echo length is not 2^m, m being an integer.
%
%   An advantage of the Hilbert algorithm is that, 
%   being an asynchronous detector, it does not need 
%   the center frequency.

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 06-99
% Revised: 05-09-11 (SKA)
% Version: 4.1
%
% New in this version: If rf is an integer array, converts to single before 
%                      computing envelope to avoid error message.
%
% Copyright © 1999 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if nargin < 1, error('Needs rf frame!'); end
if nargin > 2, error('Too many inputs! Maximum 2 necessary.'); end

nd = ndims(rf);

% CHECK IF rfseq IS INTEGER TYPE
intType = isa(rf,'integer'); % ALSO CAN USE isinteger(rf) OR class(rf)

if nd > 3
   error('Number of dimension cannot be over 3') % CANNOT HANDLE 3+ DIMENSION DATA YET
elseif nd == 3 % 3-D DATA
   [row,colx,colz]=size(rf);
   if nargin == 1, n = row; end
   
   for k = 1:colz
      RF = rf(:,:,k);	% ONE SCAN PLANE
      % COMPUTE ENVELOPE 1 SCAN PLANE AT A TIME
      if intType, env = abs(hilbert(single(RF),n)); % IF INTEGER, CONVERT TO SINGLE
      else, env = abs(hilbert(RF,n));
      end
      Env(:,:,k) = env(1:row,:);
   end   
else % 1-D & 2-D DATA
   [row,col]=size(rf);
   if nargin == 1, n = row; end
   % COMPUTE ENVELOPE
   if intType, Env = abs(hilbert(single(rf),n));
   else, Env = abs(hilbert(rf,n));
   end
end