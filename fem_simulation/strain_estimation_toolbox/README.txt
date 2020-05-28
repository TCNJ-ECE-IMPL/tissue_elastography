EstStrn computes 1D strain (axial) from ultrasound RF data (IN VIVO) using 1D crosscorrlation routines. (1 pair data files needed, #1: acquired before compression, #2: acquired after compression.) Following is an example of computing and displaying strain in MATLAB:
____________________________________________________________________________________________
% READ DATA
rf1 = readeye('C009BC2a4.eye'); % READ FILE 1
rf2 = readeye('C009BC2a8.eye'); % READ FILE 2
env1 = envelope(rf1);
fs = geteyehdr(filename,'fs'); % SAMPLING FREQ

wsize1 = 192; wsize2 = 128; wshift = 64; % PROCESSING PARAMETERS
appstr = 0.005; % APPLIED STRAIN (IF NOT KNOWN, TRY 0.01 and 0.02)
[s,d,c] = eststrn(rf1,rf2,wsize1,wsize2,wshift,appstr,0,2*appstr,'lsus'); %STRAIN ESTIMATED

% NOW DISPLAY THEM
h = figure(1); set (h,'Position',[100 50 560 660]); 
subplot(2,1,1), imagesc(logcomp(env1,0.05)), axis equal, axis off, colormap gray, title('B-mode image'), colorbar
subplot(2,1,2), imagesc(mulaw(100*s,3)), axis equal, axis off, colormap gray, title('Strain (percent)'), colorbar
____________________________________________________________________________________________

You can also display d,, and c. We typically use 192 and 128 for window sizes and 64 for window shift for 1-D strain estimation. Also try 'g', 'ls', and 'us' options instead of 'lsus'.

============================================================================================

EstStrn2D computes 2D strain and displacements using 2D crosscorrlation routines. Axial strain/displacement estimates are more reliable. Following is an example of computing and displaying strain in MATLAB:

% READ DATA
rf1 = readeye('C009BC2a4.eye'); % READ FILE 1
rf2 = readeye('C009BC2a8.eye'); % READ FILE 2
env1 = envelope(rf1);
fs = geteyehdr(filename,'fs'); % SAMPLING FREQ

wsize1R = 128; wsize1C = 32; wsize2R = 96; wsize2C = 24; wshiftR = 64; wshiftC = 2; % PROCESSING PARAMETERS
appstr = 0.005; % APPLIED STRAIN (IF NOT KNOWN, TRY 0.01 and 0.02)
[sR,sC,dR,dC,c2] = eststrn2d(rf1,rf2,wsize1R,wsize1C,wsize2R,wsize2C,wshiftR,wshiftC,appstr,0,2*appstr,'lsus2',7,'fastcoeff'); %STRAIN ESTIMATED

% NOW DISPLAY THEM
h = figure(1); set (h,'Position',[100 50 560 660]); 
subplot(2,1,1), imagesc(logcomp(env1,0.05)), axis equal, axis off, colormap gray, title('B-mode image'), colorbar
subplot(2,1,2), imagesc(mulaw(100*sR,3)), axis equal, axis off, colormap gray, title('Axial strain (percent)'), colorbar
____________________________________________________________________________________________

The following is for a simulated FEM phantom. It will need an extra file ('readut.m') to read the data. The applied compression is about 0.005 (0.5%) between files. Simulated strain map for 0.5% applied strain is in file 'ideal.mat'.

--------
rf1 = readut('unconf8.001',60);
rf2 = readut('unconf8.003',60);
[s,d,c] = eststrn(rf1,rf2,192,128,48,0.01,0,0.02,'lsus');

load ideal.mat % SIMULATED (AXIAL) STRAIN MAP
h = figure(1); set (h,'Position',[100 50 560 660]); 
subplot(2,1,1), imagesc(100*exx), axis equal, axis off, colormap gray, title('Simulated axial strain (%) - 1% Applied strain'), colorbar
subplot(2,1,2), imagesc(100*s), axis equal, axis off, colormap gray, title('Computed axial strain (%)'), colorbar
--------
% ANOTHER EXAMPLE
rf1 = readut('unconf8.001',60);
rf2 = readut('unconf8.017',60);
[s,d,c] = eststrn(rf1,rf2,192,128,48,0.08,0,0.16,'lsus');

load ideal.mat % SIMULATED (AXIAL) STRAIN MAP
h = figure(1); set (h,'Position',[100 50 560 660]); 
subplot(2,1,1), imagesc(16*100*exx), axis equal, axis off, colormap gray, title('Simulated axial strain (%) - 8% Applied strain'), colorbar
subplot(2,1,2), imagesc(100*s), axis equal, axis off, colormap gray, title('Computed axial strain (%)'), colorbar

============================================================================================

You can also display sC, dR, dC, and c2.  Also try 'g2', 'ls2', and 'us2' options instead of 'lsus'.