%BATCH_STR2 Compute strain images (2D) from a sequence of data files
%   This script prompts for all input including filenames.
%   It saves the strain images as JPEG files and also writes the 
%   sequence of strain images to an AVI movie
%
%   See also: AVIFILE, AVIWRITE, EYE2AVI, MOVIE2AVI, READEYESEQ, STR2AVI

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 02-20-06
% Revised: 03-07-06 (SKA)
% Version: 1.4
%
% New in this version: i) Prompt for scan angle if ZERO. 
%          ii) Envelope sequence computed after checking 
%          for scan angle. 
%
% Copyright © 2006 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

fprintf('Compute and save 2D strain image(s) from data file sequence...\n\n')

clear envseqsec sRSeq sCSeq cSeq sRSeqsec sCSeqsec cSeqsec combSeqsec; % CLEAR FROM PREVIOUS RUN

% SIGNAL-PROCESSING PARAMETERS
if exist('Wsize1R','var'), clear Wsize1R, end
Wsize1R = input('(Axial) window size I in sample(s)? [128]: ');
if isempty(Wsize1R), Wsize1R = 128; end
% Wsize1R = input('(Axial) window size I in sample(s)? [192]: ');
% if isempty(Wsize1R), Wsize1R = 192; end
if exist('Wsize2R','var'), clear Wsize2R, end
Wsize2R = input('(Axial) window size II in sample(s)? [96]: ');
if isempty(Wsize2R), Wsize2R = 96; end
% Wsize2R = input('(Axial) window size II in sample(s)? [128]: ');
% if isempty(Wsize2R), Wsize2R = 128; end
if exist('Wsize1C','var'), clear Wsize1C, end
Wsize1C = input('(Lateral) window size I in sample(s)? [16]: ');
if isempty(Wsize1C), Wsize1C = 16; end
if exist('Wsize2C','var'), clear Wsize2C, end
Wsize2C = input('(Lateral) window size II in sample(s)? [12]: ');
if isempty(Wsize2C), Wsize2C = 12; end
if exist('WshiftR','var'), clear WshiftR, end
WshiftR=input('(Axial) window shift in samples(s)? [64]: ');
if isempty(WshiftR), WshiftR = 64; end
% WshiftR=input('(Axial) window shift in samples(s)? [48]: ');
% if isempty(WshiftR), WshiftR = 48; end
if exist('WshiftC','var'), clear WshiftC, end
WshiftC=input('(Axial) window shift in samples(s)? [1]: ');
if isempty(WshiftC), WshiftC = 1; end

% APPLIED, MINIMUM, AND MAXIMUM STRAINS
if exist('AppStrn','var'), clear AppStrn, end
AppStrn = input('(Estimated) percent applied strain? [1]: ');
if isempty(AppStrn), AppStrn=1; end
if exist('MinStrn','var'), clear MinStrn, end
MinStrn = input('(Expected) minimum percent strain in the image? [0]: ');
if isempty(MinStrn), MinStrn=0; end
if exist('MaxStrn','var'), clear MaxStrn, end
eval(['MaxStrn = input(''(Expected) maximum percent strain in the image? [' num2str(2*AppStrn) ']: ''' ');']);
if isempty(MaxStrn), MaxStrn=2*AppStrn; end
AppStrn = AppStrn/100; MinStrn = MinStrn/100; MaxStrn = MaxStrn/100;

% STRAIN-ESTIMATION ALGORITHM
if exist('AlgFlag','var'), clear AlgFlag, end
fprintf('Available (implemented) Strain Estimation Algorithms:\n');
fprintf('''g2'': gradient of estimated displacements; \n''us2'': gradient of displacements, uniform stretching (U/S);... \n');
fprintf('''ls2'': least squares (LSQ) fit of displacements; \n''lsus2'': LSQ fit of displacements, U/S;... \n');
fprintf('''lsus2-2s'': 2-step LSQ fit of displacements, U/S;... \n');
fprintf('''a2'': adaptive stretching; \n''vs2'': gradient of displacements, variable stretching (V/S);... \n');
fprintf('''lsvs2'': LSQ fit of displacements, V/S. \nType help eststrn2D if additional info is required... \n');
AlgFlag = input('Enter Strain Estimation Algorithm to use [''lsus2'']: ','s');
if isempty(AlgFlag), AlgFlag = 'lsus2'; end

% NUMBER OF SAMPLES FOR LEAST-SQUARES REGRESSION METHODS
if exist('Lsz','var'), clear Lsz, end
if strcmpi(AlgFlag,'ls2') | strcmpi(AlgFlag,'lsus2') | strcmpi(AlgFlag,'lsus2-2s') | strcmpi(AlgFlag,'lsvs2')
   Lsz = input('Number of samples used in LSQ fit [7]: ');
   if isempty(Lsz), Lsz = 7; end
else
   Lsz = input('Number of samples used in LSQ fit []: ');
end

% DIMENSION OF MODEL
if exist('DIM','var'), clear DIM, end
fprintf('Dimension of the model for use with tscale2.\n')
fprintf('Required only for ''us2'',''lsus2'', ''vs2'', and ''lsvs2''. \nChoices are::\n');
fprintf('''1D'': uniform stretching in the axial direction only; \n');
fprintf('''2D'': uniform stretching, ''2D'' model assumed, area (axial/lateral) remains unchanged;... \n');
fprintf('''3D'': uniform stretching, ''3D'' model assumed, volume (axial/lateral/out-of-plane) remains unchanged;... \n');
Dim = input('Enter Model Dimension [''2D'']: ','s');
if isempty(Dim), Dim = '2D'; end
% Dim = input('Enter Model Dimension [''1D'']: ','s');
% if isempty(Dim), Dim = '1D'; end

% CORRELATION METHOD USED IN DISPLACEMENT ESTIMATES
if exist('CorrFlag','var'), clear CorrFlag, end
fprintf('Correlation Methods for Displacement Estimates:\n')
fprintf('MYXCORR unnormalized correlation (CF): ''none''/''n''; MYXCORR unnormalized CF: ''coeff''/''c''; \n');
fprintf('MYXCORR unnormalized CF (fast impl.): ''fast''/''f''; MYXCORR normalized CF (fast impl.): ''fastcoeff''/''fc'';...\n')
fprintf('MATLAB''s XCORR unnormalized CF: ''matlab''/''m''; XCORR CF (with ''coeff'' option): ''mcoeff''/''mc'';...\n')
fprintf('SAD (sum-absolute-difference) instead of CF, minimized for displacement estimation: ''sad''; ...\n')
fprintf('SSD (sum-squared-difference), also minimized: ''ssd''.\n')
if exist('CorrFlag','var'), clear CorrFlag, end
CorrFlag = input('Enter a choice for Correlation Method from above [''fastcoeff'']: ','s');
if isempty(CorrFlag), CorrFlag = 'fastcoeff'; end

% DISPLAY FORMAT
if exist('DispFlag','var'), clear DispFlag, end
DispFlag = input('Enter Display Format; Sector: ''s'', Linear: ''l'' [''s'']: ','s');
if isempty(DispFlag), DispFlag = 's'; end

% IMAGE HEIGHT
if ~strcmpi(DispFlag,'s')
   if exist('L','var'), clear L; end
   L = input('Image dimensions of rect image [256]: ');
   if isempty(L), L = 256; end
   if exist('rot','var'), clear rot; end
   rot = input('Rotate image 180 degrees (yes for prostate)? (''y''/''n'') [''n'']: ','s');
   if isempty(rot), rot = 'n'; end
   rotK = strcmpi(rot,'y')*2;
else
   if exist('K','var'), clear K; end
   K = input('Height of Sector Image [256]: ');
   if isempty(K), K = 256; end
end

% LOG COMPRESSION (B-MODE IMAGES)
if exist('LogCompFlagB','var'), clear LogCompFlagB; end
LogCompFlagB = input('Log compress of B-mode images? (y/n) [''y'']: ','s');
if isempty(LogCompFlagB), LogCompFlagB = 'y'; end

if strcmpi(LogCompFlagB,'y')
   if exist('lcB','var'), clear lcB; end
   lcB = input('B-mode log compress (A-law) factor [5] :');
   if isempty(lcB), lcB = 5; end
end

% LOG COMPRESSION (STRAIN IMAGES)
if exist('LogCompFlagS','var'), clear LogCompFlagS; end
LogCompFlagS = input('Log compression of strain images? (y/n) [''y'']: ','s');
if isempty(LogCompFlagS), LogCompFlagS = 'y'; end

if strcmpi(LogCompFlagS,'y')
   if exist('lcS','var'), clear lcS; end
   lcS = input('Strain-image log compression (A-law) factor [3] :');
   if isempty(lcS), lcS = 3; end
end

% CREATE COMPOSITE IMAGES (B-MODE & STRAIN IMAGES)?
if exist('CompositeFlag','var'), clear CompositeFlag; end
CompositeFlag = input('Combine B-mode and strain images on the same frame? (y/n) [''y'']: ','s');
if isempty(CompositeFlag), CompositeFlag = 'y'; end

if strcmpi(CompositeFlag,'y') % SHOW 2 (env and sR) OR 4 (env, sR, sC, c) IMAGES?
   if exist('NumIm','var'), clear NumIm; end
   NumIm = input('Number of images to combine? 2 for (env/sR) OR 4 (env/sR/sC/c). [2]: ');
   if isempty(NumIm), NumIm = 2; end
   if (NumIm ~= 2) & (NumIm ~= 4)
      NumIm = (abs(NumIm - 2) <= abs(NumIm - 4))*4 + (abs(NumIm - 2) > abs(NumIm - 4))*2;
   end
   if (NumIm == 2) % HORIZONTAL/VERTICAL CONCATENATION
      if exist('VCatFlag','var'), clear VCatFlag; end
      VCatFlag = input('Enter ''y'' to combine vertically (y/n) [''y'']: ','s');
      if isempty(VCatFlag), VCatFlag = 'y'; end
   end
end

% AVI FILE PARAMETERS
if exist('F','var'), clear F; end
F = input('AVI frames/sec [2] :');
if isempty(F), F = 2; end
if exist('Q','var'), clear Q; end
Q = input('AVI quality factor [90] :'); 
if isempty(Q), Q = 90; end

fprintf('Opening elastography eye file sequence...\n\n');
[RFSeq,files] = readeyeseq;
[m,n,NN] = size(RFSeq);
% NN=size(files,2);

if exist('nskip','var'), clear nskip; end
nskip = input('Number of files to skip [0 or NO SKIP]: ');
if isempty(nskip), nskip = 0; end

% % CONVERT TO ENVELOPE AND PROCESS
% envseq = envelope(RFSeq);
% [m,n,NN] = size(envseq);

% DROPS THE ".EYE" EXTENSION FROM FILENAMES
for k=1:NN
   f=files{k};
   len=length(f);
   files{k}=f(1:len-4); 
end
filename = files{1}; %IF NEED ARISES FOR READING HEADER

% SECTOR FORMATTING PARAMETERS
if strcmpi(DispFlag,'s')
   filename = files{1};
   pivot = geteyehdr(filename,'pivot');
   delay = geteyehdr(filename,'delay');
   angle = geteyehdr(filename,'scnang');
   fs = geteyehdr(filename,'fs');
   % CHECK IF SCAN ANGLE WAS NOT WRITTEN IN HEADER
   if ~angle
      angle = input('Scan angle in header ZERO. Enter angle in degrees: ');
      while isempty(angle)
         angle = input('Must enter angle in degrees: ');
      end
   end
end

% CONVERT TO ENVELOPE AND PROCESS
envseq = envelope(RFSeq);
[m,n,NN] = size(envseq);

for k=1:NN-(nskip+1) % INDIVIDUALLY PROCESS EACH PLANE
   [sR,sC,dR,dC,c] = EstStrn2D(RFSeq(:,:,k),RFSeq(:,:,k+nskip+1),Wsize1R,Wsize1C,...
      Wsize2R,Wsize2C,WshiftR,WshiftC,AppStrn,MinStrn,MaxStrn,AlgFlag,Lsz,Dim,CorrFlag);
   if strcmpi(LogCompFlagS,'y')
      sRSeq(:,:,k) = 100*logcomp(sR,'A',lcS); % AXIAL STRAIN (PERCENT)
      sCSeq(:,:,k) = 100*logcomp(sC,'A',lcS); % LATERAL STRAIN (PERCENT)
   else
      sRSeq(:,:,k) = 100*sR; % AXIAL STRAIN (PERCENT)
      sCSeq(:,:,k) = 100*sC; % LATERAL STRAIN (PERCENT)
   end
   cSeq(:,:,k) = c; % CORRELATION MAX
end

clear RFSeq

% LOG COMPRESSION AND SECTOR FORMATTING (B-MODE), IF NECESSARY
for k=1:NN
   if strcmpi(DispFlag,'s')
      if strcmpi(LogCompFlagB,'y')
         envseqsec(:,:,k) = logcomp(sector(envseq(Wsize2R/2+2*WshiftR:8:WshiftR*(fix((m-Wsize1R+WshiftR)/WshiftR)-2),...
            :,k),pivot,delay,angle,fs/8,K),'A',lcB);
      else
         envseqsec(:,:,k) = sector(envseq(Wsize2R/2+2*WshiftR:8:WshiftR*(fix((m-Wsize1R+WshiftR)/WshiftR)-2),:,k),...
            pivot,delay,angle,fs/8,K);
         
      end
   else
      envseq2 = imresize(rot90(envseq(:,:,k),rotK),[L L],'bicubic'); % 180° ROTATION FOR PROSTATE, ETC., SCANS
      if strcmpi(LogCompFlagB,'y') % LOG COMPRESSION (STRAIN IMAGES), IF NECESSARY
         envseqsec(:,:,k) = logcomp(envseq2,'A',lcB);
      else
         envseqsec(:,:,k) = envseq2;
      end
   end
end

% SECTOR FORMATTING (STRAIN IMAGES), IF NECESSARY
for k=1:NN-(nskip+1)
   if strcmpi(DispFlag,'s')
      sRSeqsec(:,:,k) = sector(sRSeq(:,:,k),pivot,delay,angle,fs/WshiftR,K);
      sCSeqsec(:,:,k) = sector(sCSeq(:,:,k),pivot,delay,angle,fs/WshiftR,K);
      cSeqsec(:,:,k) = sector(cSeq(:,:,k),pivot,delay,angle,fs/WshiftR,K);
   else
      sRSeqsec(:,:,k) = imresize(rot90(sRSeq(:,:,k),rotK),[L L],'bicubic');
      sCSeqsec(:,:,k) = imresize(rot90(sCSeq(:,:,k),rotK),[L L],'bicubic');
      cSeqsec(:,:,k) =  imresize(rot90(cSeq(:,:,k),rotK),[L L],'bicubic');
   end
end
clear envseq sRSeq sCSeq cSeq

% NORMALIZE B-MODE AND STRAIN IMAGES TO THE SAME MAX
envseqsec = envseqsec/max(envseqsec(:))*236; % DATA RANGE SHOULD BE 1-236 FOR 'INDEO5'
sRSeqsec = sRSeqsec/max(sRSeqsec(:))*236;
sCSeqsec = sCSeqsec/max(sCSeqsec(:))*236;
cSeqsec = cSeqsec/max(cSeqsec(:))*236;

if strcmpi(CompositeFlag,'y') % SAVE B-MODE/STRAIN COMPOSITE IMAGES
   if (NumIm == 2) % CREATE COMPOSITE IMAGES OF sR AND env ONLY
      if strcmpi(VCatFlag,'y') % VERTICAL CONCATENATION
         [me,ne,oe] = size(envseqsec);
         [ms,ns,os] = size(sRSeqsec);
         m = (me <= ms)*me + (me > ms)*ms;
         n = (ne <= ns)*ne + (ne > ns)*ns;
         o = (oe <= os)*oe + (oe > os)*os;
         envseqsec = padarray(envseqsec(1:m,1:n,1:end-(nskip+1)),[16 0],0,'post');
         sRSeqsec = padarray(sRSeqsec(1:m,1:n,1:o),[16 0],0,'pre');
         combSeqsec = cat(1,envseqsec,sRSeqsec);
         
         % NAME OF THE AVI FILE(S) TO BE WRITTEN
         avifname = ['es_' filename '_2D_s' num2str(nskip) '.avi'];   % TO WRITE AVI VIA MOVIE
      else % HORIZONTAL CONCATENATION
         [me,ne,oe] = size(envseqsec);
         [ms,ns,os] = size(sRSeqsec);
         m = (me <= ms)*me + (me > ms)*ms;
         n = (ne <= ns)*ne + (ne > ns)*ns;
         o = (oe <= os)*oe + (oe > os)*os;
         envseqsec = padarray(envseqsec(1:m,1:n,1:end-(nskip+1)),[16 16]);
         sRSeqsec = padarray(sRSeqsec(1:m,1:n,1:o),[16 16]);
         combSeqsec = cat(2,envseqsec,sRSeqsec);
         
         % NAME OF THE AVI FILE(S) TO BE WRITTEN
         avifname = ['es_' filename '_2D_s' num2str(nskip) '_hor.avi'];
      end

      % FIRST CREATE STRAIN (MATLAB) MOVIE, THEN CONVERT TO AVI
      for k=1:NN-(nskip+1)
         sM(k) = im2frame(uint8(repmat(combSeqsec(:,:,k),[1 1 3])));
      end
      movie2avi(sM,avifname,'colormap',gray(236),'compression','Indeo5',...
         'fps',F,'keyframe',1,'quality',Q);

      % NORMALIZE FOR JPEG FILES
      combSeqsec = combSeqsec/max(combSeqsec(:))*255; % 65535 for 'Bitdepth' = 16

      % WRITE JPEG FILES
      for k=1:NN-(nskip+1)
         if strcmpi(VCatFlag,'y') % VERTICAL CONCATENATION
            imfname = ['es_' files{k} '_2D_s' num2str(nskip) '.jpg']; % COMPOSITE IMAGES
         else
            imfname = ['es_' files{k} '_2D_s' num2str(nskip) '_hor.jpg']; % COMPOSITE IMAGES
         end
         comment = ['Window Size 1-R:' num2str(Wsize1R) ', Window Size 2-R: ' num2str(Wsize2R)...
            ', Window Shift R: ' num2str(WshiftR) ', Window Size 1-C:' num2str(Wsize1C)...
            ', Window Size 2-C: ' num2str(Wsize2C) ', Window Shift C: ' num2str(WshiftC)...
            ', Applied (assumed) Strain: ' num2str(AppStrn) ', Minimum (displayed) Strain: '...
            num2str(MinStrn) ', Maximum (displayed) Strain: ',num2str(MaxStrn)...
            ', Strain Algorithm: ' AlgFlag ', Model Dimension: ',Dim...
            ', Correlation M ethod: ' CorrFlag '. JPEG Quality = ' num2str(Q) '.'];
         imwrite(combSeqsec(:,:,k),gray(256),imfname,'Quality',Q,'Comment',comment,'Mode','lossy');
      end
   else % n = 4. USE ALL 4 IMAGES
      [me,ne,oe] = size(envseqsec);
      [ms,ns,os] = size(sRSeqsec); % sCSeqsec IS OF SAME SIZE
      [mc,nc,oc] = size(cSeqsec);
      mse = (me <= ms)*me + (me > ms)*ms; % COMPARE B-MODE AND STRAIN IMAGE SIZES
      nse = (ne <= ns)*ne + (ne > ns)*ns;
      ose = (oe <= os)*oe + (oe > os)*os;
      m = (mc <= mse)*mc + (mc > mse)*mse; % COMPARE THAT WITH CORRELATION SIZE
      n = (nc <= nse)*nc + (nc > nse)*nse;
      o = (oc <= ose)*oc + (oc > ose)*ose;
      envseqsec = padarray(envseqsec(1:m,1:n,1:o),[16 16]); % PADD WITH ZEROS TO SEPARATE IMAGES
      sRSeqsec = padarray(sRSeqsec(1:m,1:n,1:o),[16 16]);
      sCSeqsec = padarray(sCSeqsec(1:m,1:n,1:o),[16 16]);
      cSeqsec = padarray(cSeqsec(1:m,1:n,1:o),[16 16]);
      
      % COMBINE ALL 4 IMAGES
      combSeqsec1 = cat(2,envseqsec,sRSeqsec);
      combSeqsec2 = cat(2,sCSeqsec,cSeqsec);
      combSeqsec = cat(1,combSeqsec1,combSeqsec2);
      
      % NAME OF THE AVI FILE(S) TO BE WRITTEN
      avifname = ['es_' filename '_2D_s' num2str(nskip) '_all.avi'];

      % FIRST CREATE STRAIN (MATLAB) MOVIE, THEN CONVERT TO AVI
      for k=1:NN-(nskip+1)
         sM(k) = im2frame(uint8(repmat(combSeqsec(:,:,k),[1 1 3])));
      end
      movie2avi(sM,avifname,'colormap',gray(236),'compression','Indeo5',...
         'fps',F,'keyframe',1,'quality',Q);

      % NORMALIZE FOR JPEG FILES
      combSeqsec = combSeqsec/max(combSeqsec(:))*255; % 65535 for 'Bitdepth' = 16

      % WRITE JPEG FILES
      for k=1:NN-(nskip+1)
         imfname = ['es_' files{k} '_2D_s' num2str(nskip) '_all.jpg']; % COMPOSITE IMAGES
         comment = ['Window Size 1-R:' num2str(Wsize1R) ', Window Size 2-R: ' num2str(Wsize2R)...
            ', Window Shift R: ' num2str(WshiftR) ', Window Size 1-C:' num2str(Wsize1C)...
            ', Window Size 2-C: ' num2str(Wsize2C) ', Window Shift C: ' num2str(WshiftC)...
            ', Applied (assumed) Strain: ' num2str(AppStrn) ', Minimum (displayed) Strain: '...
            num2str(MinStrn) ', Maximum (displayed) Strain: ',num2str(MaxStrn)...
            ', Strain Algorithm: ' AlgFlag ', Model Dimension: ',Dim...
            ', Correlation M ethod: ' CorrFlag '. JPEG Quality = ' num2str(Q) '.'];
         imwrite(combSeqsec(:,:,k),gray(256),imfname,'Quality',Q,'Comment',comment,'Mode','lossy');
      end
   end
else % SAVE THE IMAGES SEPARATELY
   % NAME OF THE AVI FILE(S) TO BE WRITTEN
   avifname_e = ['e_' filename '_s' num2str(nskip) '.avi']; % B-MODE MOVIE
   avifname_sR = ['sR_' filename '_s' num2str(nskip) '.avi']; % STRAIN (AXIAL) MOVIE
   avifname_sC = ['sC_' filename '_s' num2str(nskip) '.avi']; % STRAIN (LATERAL) MOVIE
   avifname_c = ['c_' filename '_s' num2str(nskip) '.avi']; % CORRELATION MOVIE

   % FIRST CREATE STRAIN (MATLAB) MOVIE, THEN CONVERT TO AVI
   %   ("PSEUDO-COLOR" PROBLEMS WITH ADDFRAME.M CONTINUES WITH STRAIN IMAGES)
   for k=1:NN-(nskip+1)
      sRM(k) = im2frame(uint8(repmat(sRSeqsec(:,:,k),[1 1 3])));
      sCM(k) = im2frame(uint8(repmat(sCSeqsec(:,:,k),[1 1 3])));
      cM(k) = im2frame(uint8(repmat(cSeqsec(:,:,k),[1 1 3])));
   end
   movie2avi(sRM,avifname_sR,'colormap',gray(236),'compression','Indeo5',...
      'fps',F,'keyframe',1,'quality',Q);
   movie2avi(sCM,avifname_sC,'colormap',gray(236),'compression','Indeo5',...
      'fps',F,'keyframe',1,'quality',Q);
   movie2avi(c,avifname_c,'colormap',gray(236),'compression','Indeo5',...
      'fps',F,'keyframe',1,'quality',Q);

   % WRITE AVI FILES DIRECTLY (FOR ENVELOPE)
   aviwrite(avifname_e,envseqsec,'colormap',gray(236),'compression','Indeo5',...
      'fps',F,'keyframe',1,'quality',Q);

   % NORMALIZE FOR JPEG FILES
   envseqsec = envseqsec/max(envseqsec(:))*255; % 65535 for 'Bitdepth' = 16
   sRSeqsec = sRSeqsec/max(sRSeqsec(:))*255;
   sCSeqsec = sCSeqsec/max(sCSeqsec(:))*255;
   cSeqsec = cSeqsec/max(cSeqsec(:))*255;

   % WRITE JPEG FILES
   for k=1:NN-(nskip+1)
      imfname_e = ['e_' files{k} '_s' num2str(nskip) '.jpg']; % B-MODE IMAGES
      imfname_sR = ['sR_' files{k} '_sR' num2str(nskip) '.jpg']; % STRAIN (AXIAL) IMAGES
      imfname_sC = ['sC_' files{k} '_sC' num2str(nskip) '.jpg']; % STRAIN (LATERAL) IMAGES
      imfname_c = ['c_' files{k} '_c' num2str(nskip) '.jpg']; % CORRELATION IMAGES
      comment_s = ['Window Size 1-R:' num2str(Wsize1R) ', Window Size 2-R: ' num2str(Wsize2R)...
         ', Window Shift R: ' num2str(WshiftR) ', Window Size 1-C:' num2str(Wsize1C)...
         ', Window Size 2-C: ' num2str(Wsize2C) ', Window Shift C: ' num2str(WshiftC)...
         ', Applied (assumed) Strain: ' num2str(AppStrn) ', Minimum (displayed) Strain: '...
         num2str(MinStrn) ', Maximum (displayed) Strain: ',num2str(MaxStrn)...
         ', Strain Algorithm: ' AlgFlag ', Model Dimension: ',Dim...
         ', Correlation M ethod: ' CorrFlag '. JPEG Quality = ' num2str(Q) '.'];
      imwrite(envseqsec(:,:,k),gray(256),imfname_e,'Quality',Q,'Comment',comment_s,'Mode','lossy'); % B-MODE IMAGES
      imwrite(sRSeqsec(:,:,k),gray(256),imfname_sR,'Quality',Q,'Comment',comment_s,'Mode','lossy');
      imwrite(sCSeqsec(:,:,k),gray(256),imfname_sC,'Quality',Q,'Comment',comment_s,'Mode','lossy');
      imwrite(cSeqsec(:,:,k),gray(256),imfname_c,'Quality',Q,'Comment',comment_s,'Mode','lossy');
   end

   % LAST B-MODE IMAGES
   for k=NN-(nskip+1):NN
      imfname_e = ['e_' files{k} '_' num2str(nskip) '.jpg']; % B-MODE IMAGES
      imwrite(envseqsec(:,:,k),gray(256),imfname_e,'Quality',Q,'Comment',comment_s,'Mode','lossy');
   end
end

% spahdr2cell; % convert STR parameters to cell array for pasing to writestr.m
% STRFname = [CurrentFname '.spa'];
% writestr(STRFname,hdr,mb,sl,in);