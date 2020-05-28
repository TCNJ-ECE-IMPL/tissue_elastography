%STR2AVI Compute strain images from a sequence of data files
%   This script prompts for all input including filenames.
%   It saves the strain images as JPEG files and also writes the
%   sequence of strain images to an AVI movie
%
%   See also: AVIFILE, AVIWRITE, EYE2AVI, MOVIE2AVI, READEYESEQ, STR2D2AVI

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 02-16-06
% Revised: 10-29-09 (SKA)
% Version: 3.00
%
% New in this version: Made opening EYE file sequence optional, now 3D data 
%          sequence can be provided.
%
% Copyright © 2006 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

fprintf('Compute and save 1D strain image(s) from data file sequence...\n\n')

% probeSurfaceLength = ( numElements - (2 * transmitoffset) ) * pitch (probe surface length in microns)
% probeAngle = probeSurfaceLength / probeRadius * 180 / PI (probe angle in radians)
% You can get the transmitoffset parameter from setup.exe under "Tx Offset".

clear envseq envseqsec sSeq sSeqsec combSeqsec; % CLEAR FROM PREVIOUS RUN

if exist('nointrct','var') & strcmpi(nointrct,'y') % ALL INPUTS ARE READ FROM A TEXT FILE
   fprintf('Opening elastography eye file sequence...\n\n');
   [RFSeq,files] = readeyeseq;
   [m,n,NN] = size(RFSeq);
   % NN=size(files,2);
else
   % NEED TO OPEN EYE FILES FOR THE DATA?
   if exist('EyeOpen_flag','var'), clear EyeOpen_flag, end
   EyeOpen_flag = input('Compute applied strain from RF data? (y/n) [''n'']: ','s');
   if isempty(EyeOpen_flag), EyeOpen_flag = 'n'; end
   if ~strcmpi(EyeOpen_flag,'y')
      fprintf();
      files = ;
   end

   % IF DATA SEQUENCE IS PRESENT, MAKE SURE IT IS NAMED "RFSeq" AND...
   % A FILENAME files IS PRESENT FOR NAMING THE AVI FILE

   % SIGNAL-PROCESSING PARAMETERS
   if exist('Wsize1','var'), clear Wsize1, end
   Wsize1 = input('Window size I in sample(s)? [192]: ');
   if isempty(Wsize1), Wsize1 = 192; end
   if exist('Wsize2','var'), clear Wsize2, end
   Wsize2 = input('Window size II in sample(s)? [128]: ');
   if isempty(Wsize2), Wsize2 = 128; end
   if exist('Wshift','var'), clear Wshift, end
   Wshift=input('Window shift in samples(s)? [64]: ');
   if isempty(Wshift), Wshift = 64; end
   % Wshift=input('Window shift in samples(s)? [48]: ');
   % if isempty(Wshift), Wshift = 48; end

   % SHOULD THE APPLIED STRAINS BE COMPUTED FROM THE RF DATA?
   if exist('AppStrn_flag','var'), clear AppStrn_flag, end
   AppStrn_flag = input('Compute applied strain from RF data? (y/n) [''n'']: ','s');
   if isempty(AppStrn_flag), AppStrn_flag = 'n'; end
   
   % MINIMUM, APPLIED, AND MAXIMUM STRAINS, IF NOT COMPUTED FROM RF DATA
   if exist('MinStrn','var'), clear MinStrn, end
   MinStrn = input('(Expected) minimum percent strain in the image? [0]: ');
   if isempty(MinStrn), MinStrn=0; end
   if ~strcmpi(AppStrn_flag,'y')
      if exist('AppStrn','var'), clear AppStrn, end
      fprintf('If tissue was decompressed (relaxed after compression),...\n');
      fprintf('    ENTER -VE STRAIN...\n');
      fprintf('For processing, -ve strain will be treated as +ve, \n');
      fprintf('    by swapping pre- and post-compression scans...\n');
      AppStrn = input('(Estimated) percent applied strain? [1]: ');
      if isempty(AppStrn), AppStrn=1; end
      if exist('MaxStrn','var'), clear MaxStrn, end
      eval(['MaxStrn = input(''(Expected) maximum percent strain in the image? [' num2str(abs(2*AppStrn)) ']: ''' ');']);
      if isempty(MaxStrn), MaxStrn=abs(2*AppStrn); end
   end

   % STRAIN-ESTIMATION ALGORITHM
   if exist('AlgFlag','var'), clear AlgFlag, end
   fprintf('Available (implemented) Strain Estimation Algorithms:\n');
   fprintf('''g'': gradient of estimated displacements; \n''us'': gradient of displacements, uniform stretching (U/S);... \n');
   fprintf('''ls'': least squares (LSQ) fit of displacements; \n''lsus'': LSQ fit of displacements, U/S;... \n');
   fprintf('''lsus-2s'': 2-step LSQ fit of displacements, U/S;... \n');
   fprintf('''a'': adaptive stretching; \n''vs'': gradient of displacements, variable stretching (V/S);... \n');
   fprintf('''lsvs'': LSQ fit of displacements, V/S. \nType help eststrn if additional info is required... \n');
   AlgFlag = input('Enter Strain Estimation Algorithm to use [''lsus-2s'']: ','s');
   if isempty(AlgFlag), AlgFlag='lsus-2s'; end
   % AlgFlag = input('Enter Strain Estimation Algorithm to use [''lsus'']: ','s');
   % if isempty(AlgFlag), AlgFlag='lsus'; end

   % NUMBER OF SAMPLES FOR LEAST-SQUARES REGRESSION METHODS
   if exist('Lsz','var'), clear Lsz, end
   if strcmpi(AlgFlag,'ls') | strcmpi(AlgFlag,'lsus') | strcmpi(AlgFlag,'lsus-2s') | strcmpi(AlgFlag,'lsvs')
      Lsz = input('Number of samples used in LSQ fit [7]: ');
      if isempty(Lsz), Lsz = 7; end
   else
      Lsz = input('Number of samples used in LSQ fit []: ');
   end

   % CORRELATION METHOD USED IN DISPLACEMENT ESTIMATES
   if exist('CorrFlag','var'), clear CorrFlag, end
   fprintf('Correlation Methods for Displacement Estimates:\n')
   fprintf('MYXCORR unnormalized correlation (CF): ''none''/''n''; MYXCORR unnormalized CF: ''coeff''/''c''; \n');
   fprintf('MYXCORR unnormalized CF (fast impl.): ''fast''/''f''; MYXCORR normalized CF (fast impl.): ''fastcoeff''/''fc'';...\n')
   fprintf('MATLAB''s XCORR unnormalized CF: ''matlab''/''m''; XCORR CF (with ''coeff'' option): ''mcoeff''/''mc'';...\n')
   fprintf('SAD (sum-absolute-difference) instead of CF, minimized for displacement estimation: ''sad''; ...\n')
   fprintf('SSD (sum-squared-difference), also minimized: ''ssd''.\n')
   if exist('CorrFlag','var'), clear CorrFlag, end
   CorrFlag = input('Enter a choice for Correlation Method from above [''fc'']: ','s');
   if isempty(CorrFlag), CorrFlag = 'fc'; end

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
      rotK = strcmpi(rot,'y')*2; % 0º ROTATION IF 'N', 180º ROTATION IF 'Y'
   else
      if exist('K','var'), clear K; end
      K = input('Height of Sector Image [256]: ');
      if isempty(K), K = 256; end
   end

   % LOG COMPRESSION (B-MODE IMAGES)
   if exist('LogCompFlagB','var'), clear LogCompFlagB; end
   LogCompFlagB = input('Log-compress B-mode images? (y/n) [''y'']: ','s');
   if isempty(LogCompFlagB), LogCompFlagB = 'y'; end

   if strcmpi(LogCompFlagB,'y')
      if exist('lcB','var'), clear lcB; end
      lcB = input('B-mode log compress (A-law) factor [10]: ');
      if isempty(lcB), lcB = 10; end
   end

   % LOG COMPRESSION (STRAIN IMAGES)
   if exist('LogCompFlagS','var'), clear LogCompFlagS; end
   LogCompFlagS = input('Log-compress strain images? (y/n) [''y'']: ','s');
   if isempty(LogCompFlagS), LogCompFlagS = 'y'; end

   if strcmpi(LogCompFlagS,'y')
      if exist('lcS','var'), clear lcS; end
      lcS = input('Strain-image log compression (A-law) factor [5]: ');
      if isempty(lcS), lcS = 5; end
   end

   % CREATE COMPOSITE IMAGES (B-MODE & STRAIN IMAGES)?
   if exist('CompositeFlag','var'), clear CompositeFlag; end
   CompositeFlag = input('Combine B-mode and strain images on the same frame? (y/n) [''y'']: ','s');
   if isempty(CompositeFlag), CompositeFlag = 'y'; end

   if strcmpi(CompositeFlag,'y') % HORIZONTAL/VERTICAL CONCATENATION
      if exist('VCatFlag','var'), clear VCatFlag; end
      VCatFlag = input('Enter ''y'' to combine vertically (y/n) [''y'']: ','s');
      if isempty(VCatFlag), VCatFlag = 'y'; end
   end
   
   if exist('ImgandVidFlag','var'), clear ImgandVidFlag; end % SAVE BOTH IMAGE AND VIDEO
   ImgandVidFlag = input('Enter ''y'' to save video AND image...or only video will be saved (y/n) [''y'']: ','s');
   if isempty(ImgandVidFlag), ImgandVidFlag = 'y'; end
   

   % AVI FILE PARAMETERS
   if exist('F','var'), clear F; end
   F = input('AVI frames/sec [2] :');
   if isempty(F), F = 2; end
   if exist('Q','var'), clear Q; end
   Q = input('AVI quality factor [90]: ');
   if isempty(Q), Q = 90; end

   % SAVE ONLY IMAGES, OR ONLY VIDEO, OR BOTH
   if strcmpi(ImgandVidFlag,'y')
      if exist('ImgandVidFlag','var'), clear ImgandVidFlag; end
      ImgandVidFlag = input('Enter ''i'': save only images, ''v'': save only video, ''iv'': save video AND images [''iv'']: ','s');
      if isempty(ImgandVidFlag), ImgandVidFlag = 'iv'; end
   end

   if strcmpi(EyeOpen_flag,'y') % OPEN EYE FILE FOR DATA
      fprintf('Opening elastography eye file sequence...\n\n');
      [RFSeq,files] = readeyeseq;
   end
   [m,n,NN] = size(RFSeq);
   % NN=size(files,2);

   % SKIP FRAMES (IF COMPRESSION IS NOT LARGE ENOUGH)
   if exist('nskip','var'), clear nskip; end
   nskip = input('Number of files to skip [0 or NO SKIP]: ');
   if isempty(nskip), nskip = 0; end
end

% CONVERT STRAINS TO FRACTIONS
MinStrn = MinStrn/100;
if exist('AppStrn','var'), AppStrn = AppStrn/100; end
if exist('MaxStrn','var'), MaxStrn = MaxStrn/100; end

% DROPS THE ".EYE" EXTENSION FROM FILENAMES
for k=1:NN
   f=files{k};
   len=length(f);
   files{k}=f(1:len-4);
end
filename = files{1}; %IF NEED ARISES FOR READING HEADER

% SECTOR FORMATTING PARAMETERS
if strcmpi(DispFlag,'s')
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
   if ~strcmpi(AppStrn_flag,'y')
      if AppStrn >= 0
         [s,d,c] = eststrn(RFSeq(:,:,k),RFSeq(:,:,k+nskip+1),Wsize1,Wsize2,Wshift,AppStrn,MinStrn,MaxStrn,AlgFlag);
      else % -VE STRAIN...TISSUE RELAXING...CHANGE THE ORDER OF FILES
         [s,d,c] = eststrn(RFSeq(:,:,k+nskip+1),RFSeq(:,:,k),Wsize1,Wsize2,Wshift,-AppStrn,MinStrn,MaxStrn,AlgFlag);
      end
   else
      AppStrn = EstAppStrn(RFSeq(:,:,k),RFSeq(:,:,k+nskip+1));
      if AppStrn >= 0
         [s,d,c] = eststrn(RFSeq(:,:,k),RFSeq(:,:,k+nskip+1),Wsize1,Wsize2,Wshift,AppStrn,MinStrn,MaxStrn,AlgFlag);
      else % -VE STRAIN...TISSUE RELAXING...CHANGE THE ORDER OF FILES, THEN CHANGE SIGN OF STRAIN
         AppStrn1 = -AppStrn;
         MaxStrn = 2*AppStrn1;
         [s,d,c] = eststrn(RFSeq(:,:,k+nskip+1),RFSeq(:,:,k),Wsize1,Wsize2,Wshift,AppStrn1,MinStrn,MaxStrn,AlgFlag);
         %d = -d; s = -s; % CHANGE SIGN TO MAKE THEM NEGATIVE
      end
   end
   if strcmpi(LogCompFlagS,'y')
      sSeq(:,:,k) = 100*logcomp(s,'A',lcS); % PERCENT STRAIN
      %% SIGN CHANGE AFTER LOG-COMPRESSION, BECAUSE LOG OF NEGATIVE IS IMAGINARY
      %if AppStrn < 0, d = -d; s = -s; sSeq(:,:,k) = -sSeq(:,:,k); end
   else
      sSeq(:,:,k) = 100*s; % PERCENT STRAIN
      %if AppStrn < 0, d = -d; s = -s; sSeq(:,:,k) = -sSeq(:,:,k); end
   end
   %keyboard
end

clear RFSeq

% LOG COMPRESSION AND SECTOR FORMATTING (B-MODE), IF NECESSARY
for k=1:NN
   if strcmpi(DispFlag,'s')
      if strcmpi(LogCompFlagB,'y')
         envseqsec(:,:,k) = logcomp(sector(envseq(Wsize2/2+2*Wshift:8:Wshift*(fix((m-Wsize1+Wshift)/Wshift)-2),:,k),...
            pivot,delay,angle,fs/8,K),'A',lcB);
      else
         envseqsec(:,:,k) = sector(envseq(Wsize2/2+2*Wshift:8:Wshift*(fix((m-Wsize1+Wshift)/Wshift)-2),:,k),...
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
      sSeqsec(:,:,k) = sector(sSeq(:,:,k),pivot,delay,angle,fs/Wshift,K);
   else
      sSeqsec(:,:,k) = imresize(rot90(sSeq(:,:,k),rotK),[L L],'bicubic');
   end
end
clear envseq sSeq

% NORMALIZE B-MODE AND STRAIN IMAGES TO THE SAME MAX
envseqsec = envseqsec/max(envseqsec(:))*236; % DATA RANGE SHOULD BE 1-236 FOR 'INDEO5'
sSeqsec = (sSeqsec - min(sSeqsec(:)))/(max(sSeqsec(:)) - min(sSeqsec(:)))*236;

if strcmpi(CompositeFlag,'y') % SAVE B-MODE/STRAIN COMPOSITE IMAGES
   if strcmpi(VCatFlag,'y') % COMPOSITE IMAGES USING VERTICAL CONCATENATION
      [me,ne,oe] = size(envseqsec);
      [ms,ns,os] = size(sSeqsec);
      m = (me <= ms)*me + (me > ms)*ms;
      n = (ne <= ns)*ne + (ne > ns)*ns;
      o = (oe <= os)*oe + (oe > os)*os;
      envseqsec = padarray(envseqsec(1:m,1:n,1:end-(nskip+1)),[16 0],0,'post');
      sSeqsec = padarray(sSeqsec(1:m,1:n,1:o),[16 0],0,'pre');
      combSeqsec = cat(1,envseqsec,sSeqsec);

      % NAME OF THE AVI FILE(S) TO BE WRITTEN
      if AppStrn < 0
         avifname = ['es_' filename '_s' num2str(nskip) '_decomp.avi'];   % TO WRITE AVI VIA MOVIE
      else
         avifname = ['es_' filename '_s' num2str(nskip) '.avi'];   % TO WRITE AVI VIA MOVIE
      end
   else % HORIZONTAL CONCATENATION
      [me,ne,oe] = size(envseqsec);
      [ms,ns,os] = size(sSeqsec);
      m = (me <= ms)*me + (me > ms)*ms;
      n = (ne <= ns)*ne + (ne > ns)*ns;
      o = (oe <= os)*oe + (oe > os)*os;
      envseqsec = padarray(envseqsec(1:m,1:n,1:end-(nskip+1)),[16 16]);
      sSeqsec = padarray(sSeqsec(1:m,1:n,1:o),[16 16]);
      combSeqsec = cat(2,envseqsec,sSeqsec);

      % NAME OF THE AVI FILE(S) TO BE WRITTEN
      if AppStrn < 0
         avifname = ['es_' filename '_s' num2str(nskip) '_decomp_hor.avi'];
      else
         avifname = ['es_' filename '_s' num2str(nskip) '_hor.avi'];
      end
   end

   % WRITE B-MODE + STRAIN COMBINED MOVIE (AVI) USING 'AVIWRITE' THAT CREATES AVI VIA MATLAB MOVIE
   aviwrite(avifname,combSeqsec,'Colormap',gray(236),'Compression','Indeo5',...
      'Fps',F,'Keyframe',1,'Quality',Q);

   %    % FIRST CREATE STRAIN (MATLAB) MOVIE, THEN CONVERT TO AVI
   %    for k=1:NN-(nskip+1)
   %       sM(k) = im2frame(uint8(repmat(combSeqsec(:,:,k),[1 1 3])));
   %    end
   %    movie2avi(sM,avifname,'colormap',gray(236),'compression','Indeo5',...
   %       'fps',F,'keyframe',1,'quality',Q);

   % NORMALIZE FOR JPEG FILES
   combSeqsec = combSeqsec/max(combSeqsec(:))*255; % 65535 for 'Bitdepth' = 16

   % WRITE JPEG FILES
   for k=1:NN-(nskip+1)
      if strcmpi(VCatFlag,'y') % VERTICAL CONCATENATION
         if AppStrn < 0
            imfname = ['es_' files{k} '_s' num2str(nskip) '_decomp.jpg']; % COMPOSITE IMAGES
         else
            imfname = ['es_' files{k} '_s' num2str(nskip) '.jpg']; % COMPOSITE IMAGES
         end
      else
         if AppStrn < 0
            imfname = ['es_' files{k} '_s' num2str(nskip) '_decomp_hor.jpg']; % COMPOSITE IMAGES
         else
            imfname = ['es_' files{k} '_s' num2str(nskip) '_hor.jpg']; % COMPOSITE IMAGES
         end
      end
      comment = ['Window Size 1: ' num2str(Wsize1) ', Window Size 2: ' num2str(Wsize2)...
         ', Window Shift: ' num2str(Wshift) ', Applied (assumed) Strain: ' num2str(AppStrn)...
         ', Minimum (displayed) Strain: ' num2str(MinStrn) ', Maximum (displayed) Strain: '...
         num2str(MaxStrn) ', Strain Algorithm: ' AlgFlag '. JPEG Quality = ' num2str(Q) '.'];
      imwrite(combSeqsec(:,:,k),gray(256),imfname,'Quality',Q,'Comment',comment,'Mode','lossy');
   end
else % SAVE THE IMAGES SEPARATELY
   % NAME OF THE AVI FILE(S) TO BE WRITTEN
   avifname_e = ['e_' filename '_s' num2str(nskip) '.avi']; % B-MODE MOVIE
   avifname_s = ['s_' filename '_s' num2str(nskip) '.avi']; % ELASTOGRAPHY MOVIE

   % WRITE B-MODE AND STRAIN MOVIES (AVI) USING 'AVIWRITE' THAT CREATES AVI VIA MATLAB MOVIE
   aviwrite(avifname_e,envseqsec,'colormap',gray(236),'compression','Indeo5',...
      'fps',F,'keyframe',1,'quality',Q);
   aviwrite(avifname_s,sSeqsec,'colormap',gray(236),'compression','Indeo5',...
      'fps',F,'keyframe',1,'quality',Q);

   %    % FIRST CREATE STRAIN (MATLAB) MOVIE, THEN CONVERT TO AVI
   %    %   ("PSEUDO-COLOR" PROBLEMS WITH ADDFRAME.M CONTINUES WITH STRAIN IMAGES)
   %    for k=1:NN-(nskip+1)
   %       sM(k) = im2frame(uint8(repmat(sSeqsec(:,:,k),[1 1 3])));
   %    end
   %    movie2avi(sM,avifname_s,'colormap',gray(236),'compression','Indeo5',...
   %       'fps',F,'keyframe',1,'quality',Q);
   %
   %    % WRITE B-MODE AVI FILE DIRECTLY
   %    aviwrite(avifname_e,envseqsec,'colormap',gray(236),'compression','Indeo5',...
   %       'fps',F,'keyframe',1,'quality',Q);

   % NORMALIZE FOR JPEG FILES
   sSeqsec = sSeqsec/max(sSeqsec(:))*255; % 65535 for 'Bitdepth' = 16
   envseqsec = envseqsec/max(envseqsec(:))*255; % 65535 for 'Bitdepth' = 16

   % WRITE JPEG FILES
   for k=1:NN-(nskip+1)
      imfname_s = ['s_' files{k} '_s' num2str(nskip) '.jpg']; % STRAIN IMAGES
      comment_s = ['Window Size 1: ' num2str(Wsize1) ', Window Size 2: ' num2str(Wsize2)...
         ', Window Shift: ' num2str(Wshift) ', Applied (assumed) Strain: ' num2str(AppStrn)...
         ', Minimum (displayed) Strain: ' num2str(MinStrn) ', Maximum (displayed) Strain: '...
         num2str(MaxStrn) ', Strain Algorithm: ' AlgFlag '. JPEG Quality = ' num2str(Q) '.'];
      imwrite(sSeqsec(:,:,k),gray(256),imfname_s,'Quality',Q,'Comment',comment_s,'Mode','lossy');
      imfname_e = ['e_' files{k} '_s' num2str(nskip) '.jpg']; % B-MODE IMAGES
      imwrite(envseqsec(:,:,k),gray(256),imfname_e,'Quality',Q,'Comment',comment_s,'Mode','lossy');
   end

   % LAST B-MODE IMAGES
   for k=NN-(nskip+1):NN
      imfname_e = ['e_' files{k} '_' num2str(nskip) '.jpg']; % B-MODE IMAGES
      imwrite(envseqsec(:,:,k),gray(256),imfname_e,'Quality',Q,'Comment',comment_s,'Mode','lossy');
   end
end

if exist('nointrct','var'), clear nointrct; end

% spahdr2cell; % convert STR parameters to cell array for pasing to writestr.m
% STRFname = [CurrentFname '.spa'];
% writestr(STRFname,hdr,mb,sl,in);