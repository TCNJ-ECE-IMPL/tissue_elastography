function [ENVs,SDCs,SDC2s,SDC3s] = DispProsElast(fname1,fname2,appstr,maxstr,lc)
%DISPPROSELAST  Computes/displays (sector) prostate Elastogram
%  SYNTAX: DISPPROSELAST(FNAME1,FNAME2,APPSTR,MAXSTR,LC) 
%          FNAME1: PRECOMPRESSION DATA FILE (".EYE" FORMAT)
%          FNAME2: POSTCOMPRESSION DATA FILE (".EYE" FORMAT)
%          APPSTR: APPLIED STRAIN
%          MAXSTR: MAXIMUM STRAIN
%  If APPSTR is in percent, it is divided by 100 to convert to 
%  fraction. Similarly, If MAXSTR is in percent, it is divided 
%  by 100 to convert to fraction. The routine prompts for the 
%  FNAME1, FNAME2, APPSTR, and MAXSTR if not input. 
%  [ENVs,Ss] = DISPPROSELAST returns Midband Fit and Computed 
%  strain in sector format. 
%
%  See also ESTSTRN, SECTOR, DISPPROSELAST2D

% Author:  S. Kaisar Alam, Ph.D.
% Email:   kaisar.alam@ieee.org
% Written: 03-15-05
% Revised: 02-07-11 (SKA)
% Version: 2.0
%
% New in this version: Default value for lc = 5 (NOT 0.06). Returning the 
%                      strain and displacement values. 
%
% Copyright © 2005 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if nargin==0	% If no argument is given, ask for the filenames. Ask for Appstr.
   [fname1,pname1] = uigetfiles('*.eye','Choose precompression file');
   fname1 = [pname1 char(fname1)];
   [fname2,pname2] = uigetfiles('*.eye','Choose postcompression file');
   fname2 = [pname2 char(fname2)];
   appstr = input('Applied strain (%): ');
   while isempty(appstr), appstr = input('Must supply applied strain (%): '); end
   appstr = appstr/100;
   maxstr = input('Maximum strain (%) [2*Applied Strain]: ');
   while isempty(maxstr), maxstr = 2*appstr*100; end
   maxstr = maxstr/100;
elseif nargin==1	% one argument means AppStr; ask for the filenames and max strain. 
   [fname1,pname1] = uigetfiles('*.eye','Choose precompression file');
   fname1 = [pname1 char(fname1)];
   [fname2,pname2] = uigetfiles('*.eye','Choose postcompression file');
   fname2 = [pname2 char(fname2)];
   maxstr = input('Maximum strain (%) [2*Applied Strain]: ');
   while isempty(maxstr), maxstr = 2*appstr*100; end
   maxstr = maxstr/100;
elseif nargin==2	% two argument means filenames; ask for AppStr. 
   appstr = input('Applied strain (%): ');
   while isempty(appstr), appstr = input('Must supply applied strain (%): '); end
   appstr = appstr/100;
   maxstr = input('Maximum strain (%) [2*Applied Strain]: ');
   while isempty(maxstr), maxstr = 2*appstr*100; end
   maxstr = maxstr/100;
elseif nargin==3	% Three argument means filenames and AppStr; ask for MaxStr. 
   maxstr = input('Maximum strain (%) [2*Applied Strain]: ');
   while isempty(maxstr), maxstr = 2*appstr*100; end
   maxstr = maxstr/100;
end

if nargin < 5, lc = 5; end

% CONVERT TO FRACTION IF IN PERCENT
if appstr >= 1, appstr = appstr/100; end
if maxstr >= 1, maxstr = maxstr/100; end

rf1 = readeye(fname1); env1 = envelope(rf1);
rf2 = readeye(fname2); env2 = envelope(rf2);

wsize1 = 192; wsize2 = 128; wshift = 64;
alg_flag = 'lsus'; alg_flag2 = 'lsus-2s'; alg_flag3 = 'ssus'; 
[s,d,c] = eststrn(rf1,rf2,wsize1,wsize2,wshift,appstr,0,maxstr,'lsus'); % LSUS
[slu,dlu,clu] = eststrn(rf1,rf2,wsize1,wsize2,wshift,appstr,0,maxstr,'lsus-2s'); % 2-STEP LSUS
[ssu,dsu,csu] = eststrn(rf1,rf2,wsize1,wsize2,wshift,appstr,0,maxstr,'ssus',0.65); % SMOOTHING SPLINE

% SECTOR FORMATTING
fs = geteyehdr(fname1,'fs');
pivot = geteyehdr(fname1,'pivot');
delay = geteyehdr(fname1,'delay');
angle = geteyehdr(fname1,'scnang');
ENVs = sector(env1(wsize2/2+2*wshift:8:wshift*(fix((size(rf1,1)-wsize1+wshift)/wshift)-2),:),...
   pivot,delay,angle,fs/8);

Ss = sector(s,pivot,delay,angle,fs/wshift); % LSUS
Ds = sector(d,pivot,delay,angle,fs/wshift);
Cs = sector(movavg2(c,[7 1],'valid'),pivot,delay,angle,fs/wshift);
Ss = mulaw(100*Ss,10); % EXTEND DYNAMIC RANGE
min_strn = 0; max_strn = maxstr;
mask = Cs > 0.3;
Ss = Ss.*mask + ~mask*((min_strn+max_strn)/2);

SLUs = sector(slu,pivot,delay,angle,fs/wshift); % 2-STEP LSUS
DLUs = sector(dlu,pivot,delay,angle,fs/wshift);
CLUs = sector(movavg2(clu,[7 1],'valid'),pivot,delay,angle,fs/wshift);
SLUs = mulaw(100*SLUs,10);
min_strn = 0; max_strn = maxstr;
mask = CLUs > 0.5;
SLUs = SLUs.*mask + ~mask*((min_strn+max_strn)/2);

SSUs = sector(ssu(1:size(slu,1),:),pivot,delay,angle,fs/wshift); % 2-STEP LSUS
DSUs = sector(dsu,pivot,delay,angle,fs/wshift);
CSUs = sector(movavg2(csu,[7 1],'valid'),pivot,delay,angle,fs/wshift);
SSUs = mulaw(100*SSUs,10);
min_strn = 0; max_strn = maxstr;
mask = CSUs > 0.5;
%keyboard
SSUs = SSUs.*mask + ~mask*((min_strn+max_strn)/2);

% DISPLAY
if nargout > 3 % LSUS, 2-STEP LSUS, and SSUS
   figure(1); set(gcf,'Position',[28 25 906 647]); title('Least-squares Fit w/ Uniform Stretching')
   subplot(2,2,1), imagesc(logcomp(ENVs,lc)), axis equal, axis off, colormap gray, title('B-mode (dB)'), colorbar
   subplot(2,2,3), imagesc(Ss), axis equal, axis off, colormap gray, title('Strain (%)'), colorbar
   subplot(2,2,2), imagesc(Ds), axis equal, axis off, colormap jet, title('Displacement'), colorbar
   subplot(2,2,4), imagesc(Cs), axis equal, axis off, colormap gray, title('Correlation'), colorbar
   figure(2); set(gcf,'Position',[40 19 906 647]); title('2-Step Least-squares Fit w/ Uniform Stretching')
   subplot(2,2,1), imagesc(logcomp(ENVs,lc)), axis equal, axis off, colormap gray, title('B-mode (dB)'), colorbar
   subplot(2,2,3), imagesc(SLUs), axis equal, axis off, colormap gray, title('Strain (%)'), colorbar
   subplot(2,2,2), imagesc(DLUs), axis equal, axis off, colormap jet, title('Displacement'), colorbar
   subplot(2,2,4), imagesc(CLUs), axis equal, axis off, colormap gray, title('Correlation'), colorbar
   figure(3); set(gcf,'Position',[52 13 906 744]); title('Least-squares Fit w/ Uniform Stretching') %[52 1 400 480] / [52 1 760 647]
   subplot(2,1,1), imagesc(logcomp(ENVs,lc)), axis equal, axis off, colormap gray, colorbar
   subplot(2,1,2), imagesc(Ss), axis equal, axis off, colormap gray, colorbar
   figure(4); set(gcf,'Position',[64 7 906 744]); title('2-Step Least-squares Fit w/ Uniform Stretching') %[52 1 400 480] / [52 1 760 647]
   subplot(2,1,1), imagesc(logcomp(ENVs,lc)), axis equal, axis off, colormap gray, colorbar
   subplot(2,1,2), imagesc(SLUs), axis equal, axis off, colormap gray, colorbar
   figure(5); set(gcf,'Position',[76 1 906 744]); title('Smoothing Spline w/ Uniform Stretching') %[52 1 400 480] / [52 1 760 647]
   subplot(2,1,1), imagesc(logcomp(ENVs,lc)), axis equal, axis off, colormap gray, colorbar
   subplot(2,1,2), imagesc(SSUs), axis equal, axis off, colormap gray, colorbar
   SDCs=Ss; SDC2s=SLUs; SDC3s=SSUs; %SDCs=zeros(size(Ss,1),size(Ss,2),3);SDCs(:,:,1) = Ss; SDCs(:,:,2) = Ds; SDCs(:,:,3) = Cs; % UNEQUAL DIMENSIONS
elseif nargout > 2 % LSUS and 2-STEP LSUS
   figure(1); set(gcf,'Position',[28 25 906 647]); title('Least-squares Fit w/ Uniform Stretching')
   subplot(2,2,1), imagesc(logcomp(ENVs,lc)), axis equal, axis off, colormap gray, title('B-mode (dB)'), colorbar
   subplot(2,2,3), imagesc(Ss), axis equal, axis off, colormap gray, title('Strain (%)'), colorbar
   subplot(2,2,2), imagesc(Ds), axis equal, axis off, colormap jet, title('Displacement'), colorbar
   subplot(2,2,4), imagesc(Cs), axis equal, axis off, colormap gray, title('Correlation'), colorbar
   figure(2); set(gcf,'Position',[40 19 906 647]); title('2-Step Least-squares Fit w/ Uniform Stretching')
   subplot(2,2,1), imagesc(logcomp(ENVs,lc)), axis equal, axis off, colormap gray, title('B-mode (dB)'), colorbar
   subplot(2,2,3), imagesc(SLUs), axis equal, axis off, colormap gray, title('Strain (%)'), colorbar
   subplot(2,2,2), imagesc(DLUs), axis equal, axis off, colormap jet, title('Displacement'), colorbar
   subplot(2,2,4), imagesc(CLUs), axis equal, axis off, colormap gray, title('Correlation'), colorbar
   figure(3); set(gcf,'Position',[52 13 906 744]); title('Least-squares Fit w/ Uniform Stretching') %[52 1 400 480] / [52 1 760 647]
   subplot(2,1,1), imagesc(logcomp(ENVs,lc)), axis equal, axis off, colormap gray, title('B-mode (dB)'), colorbar
   subplot(2,1,2), imagesc(Ss), axis equal, axis off, colormap gray, title('Strain (%)'), colorbar
   figure(4); set(gcf,'Position',[64 7 906 744]); title('2-Step Least-squares Fit w/ Uniform Stretching') %[52 1 400 480] / [52 1 760 647]
   subplot(2,1,1), imagesc(logcomp(ENVs,lc)), axis equal, axis off, colormap gray, title('B-mode (dB)'), colorbar
   subplot(2,1,2), imagesc(SLUs), axis equal, axis off, colormap gray, title('Strain (%)'), colorbar
   SDCs=Ss; SDC2s=SLUs; %SDCs=zeros(size(Ss,1),size(Ss,2),3);SDCs(:,:,1) = Ss; SDCs(:,:,2) = Ds; SDCs(:,:,3) = Cs; % UNEQUAL DIMENSIONS
else % ONLY LSUS
   figure(1); set(gcf,'Position',[28 25 906 647]); title('Least-squares Fit w/ Uniform Stretching')
   subplot(2,2,1), imagesc(logcomp(ENVs,lc)), axis equal, axis off, colormap gray, title('B-mode (dB)'), colorbar
   subplot(2,2,3), imagesc(Ss), axis equal, axis off, colormap gray, title('Strain (%)'), colorbar
   subplot(2,2,2), imagesc(Ds), axis equal, axis off, colormap jet, title('Displacement'), colorbar
   subplot(2,2,4), imagesc(Cs), axis equal, axis off, colormap gray, title('Correlation'), colorbar
   figure(2); set(gcf,'Position',[40 13 906 744]); title('Least-squares Fit w/ Uniform Stretching') %[52 1 400 480] / [52 1 760 647]
   subplot(2,1,1), imagesc(logcomp(ENVs,lc)), axis equal, axis off, colormap gray, title('B-mode (dB)'), colorbar
   subplot(2,1,2), imagesc(Ss), axis equal, axis off, colormap gray, title('Strain (%)'), colorbar
   SDCs=Ss; SDC2s=SLUs; %SDC2s=zeros(size(SLUs,1),size(SLUs,2),3);%SDC2s(:,:,1) = SLUs; SDC2s(:,:,2) = DLUs; SDC2s(:,:,3) = CLUs; % UNEQUAL DIMENSIONS
end