function [Im,header] = RPread(filename,frm_range,im_flag)
%RPREAD loads the ultrasound RF data saved from the Sonix software
%%
%% Inputs:
%%     filename - The path of the data to open
%%     im_flag  - Displays B-mode image(s), if 'y'. (Default: 'n'.)
%%
%% Return:
%%     Im -         The image data returned into a 3D array (h, w, numframes)
%%     header -     The file header information
%%
%% Corina Leung, corina.leung@ultrasonix.com
%% Ultrasonix Medical Corporation Nov 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Version:       1.6
% Date:          05-09-2011
% New in this v: returns RF data in int16 type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% IF IMAGE FLAG IS NOT PASSED and 'Y', NO IMAGE WILL BE DISPLAYED
if exist('frm_range','var')
   if ischar(frm_range) % IT IS REALLY im_flag
      im_flag = frm_range;
      clear frm_range
   end
end

if ~exist('im_flag','var'), im_flag = 'n'; end;

if ~exist('filename','var') % NO FILE NAME SPECIFIED
   [filename,pathname]=uigetfile('*.rf','Select file to open','MultiSelect','on');
   filename=[pathname char(filename)];
end

fid= fopen(filename, 'r');
%fileExt = filename(end-2:end);

if( fid == -1)
   error('Cannot open file');
end

% read the header info
hinfo = fread(fid, 19, 'int32');

% load the header information into a structure and save under a separate file
header = struct('filetype', 0, 'nframes', 0, 'w', 0, 'h', 0, 'ss', 0, 'ul', [0,0], 'ur', [0,0], 'br', [0,0], 'bl', [0,0], 'probe',0, 'txf', 0, 'sf', 0, 'dr', 0, 'ld', 0, 'extra', 0);
header.filetype = hinfo(1);
header.nframes = hinfo(2);
header.w = hinfo(3);
header.h = hinfo(4);
header.ss = hinfo(5);
header.ul = [hinfo(6), hinfo(7)];
header.ur = [hinfo(8), hinfo(9)];
header.br = [hinfo(10), hinfo(11)];
header.bl = [hinfo(12), hinfo(13)];
header.probe = hinfo(14);
header.txf = hinfo(15);
header.sf = hinfo(16);
header.dr = hinfo(17);
header.ld = hinfo(18);
header.extra = hinfo(19);

fprintf('Total Number of Frames: %d...\n',header.nframes);

if ~exist('frm_range','var') % READ ALL FRAMES
   frm_range = [1 header.nframes];
end

%v=[];
%Im =[];
%Im2=[];
% NOT INITIALIZING THE ABOVE TWO ALLOWS THEM TO BE IN THE PROPER FORMAT
% (int16 FOR RF), INSTEAD OF BEING FORCED TO DOUBLE. 

% load the data and save into individual .mat files
for frame_count = 1:frm_range(2)

   frame_count_NEW = frame_count - frm_range(1) + 1; % START SAVING AFTER SKIPPING FIRST frm_range(1)-1 FRAMES

   if(header.filetype == 2) %.bpr
      %Each frame has 4 byte header for frame number
      tag = fread(fid,1,'int32');
      [v,count] = fread(fid,header.w*header.h,'uchar=>uchar');
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = reshape(v,header.h,header.w);
      end

   elseif(header.filetype == 4) %postscan B .b8
      tag = fread(fid,1,'int32');
      [v,count] = fread(fid,header.w*header.h,'int8');
      temp = int16(reshape(v,header.w,header.h));
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = imrotate(temp, -90);
      end

   elseif(header.filetype == 8) %postscan B .b32
      tag = fread(fid,1,'int32');
      [v,count] = fread(fid,header.w*header.h,'int32');
      temp = reshape(v,header.w,header.h);
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = imrotate(temp, -90);
      end

   elseif(header.filetype == 16) %rf
      tag = fread(fid,1,'int32');
      [v,count] = fread(fid,header.w*header.h,'*int16'); % *int16 IS EQUIVALENT TO 'int16=>int16'
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = int16(reshape(v,header.h,header.w));
      end

   elseif(header.filetype == 32) %.mpr
      tag = fread(fid,1,'int32');
      [v,count] = fread(fid,header.w*header.h,'int16');
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,frame_count_NEW) = v;%int16(reshape(v,header.h,header.w));
      end

   elseif(header.filetype == 64) %.m
      [v,count] = fread(fid,'uint8');
      temp = reshape(v,header.w,header.h);
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = imrotate(temp,-90);
      end

   elseif(header.filetype == 128) %.drf
      tag = fread(fid,1,'int32');
      [v,count] = fread(fid,header.h,'int16');
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = int16(reshape(v,header.w,header.h));
      end

   elseif(header.filetype == 512) %crf
      tag = fread(fid,1,'int32');
      [v,count] = fread(fid,header.extra*header.w*header.h,'int16');
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = reshape(v,header.h,header.w*header.extra);
      end
      %to obtain data per packet size use
      % Im(:,:,:,frame_count_NEW) = reshape(v,header.h,header.w,header.extra);

   elseif(header.filetype == 256) %.pw
      [v,count] = fread(fid,'uint8');
      temp = reshape(v,header.w,header.h);
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = imrotate(temp,-90);
      end

      %     elseif(header.filetype == 1024) %.col        %The old file format for SONIX version 3.0X
      %          [v,count] = fread(fid,header.w*header.h,'int');
      %          temp = reshape(v,header.w,header.h);
      %          temp2 = imrotate(temp, -90);
      %          Im(:,:,frame_count_NEW) = mirror(temp2,header.w);
      %
      %     elseif((header.filetype == 2048) & (fileExt == '.sig')) %color .sig  %The old file format for SONIX version 3.0X
      %         %Each frame has 4 byte header for frame number
      %         tag = fread(fid,1,'int32');
      %         [v,count] = fread(fid,header.w*header.h,'uchar=>uchar');
      %         temp = reshape(v,header.w,header.h);
      %         temp2 = imrotate(temp, -90);
      %         Im(:,:,frame_count_NEW) = mirror(temp2,header.w);

   elseif(header.filetype == 1024) %.col
      [v,count] = fread(fid,header.w*header.h,'int');
      temp = reshape(v,header.w,header.h);
      temp2 = imrotate(temp, -90);
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = mirror(temp2,header.w);
      end

   elseif((header.filetype == 2048)) %color .cvv (the new format as of SONIX version 3.1X)
      % velocity data
      [v,count] = fread(fid,header.w*header.h,'uint8');
      temp = reshape(v,header.w,header.h);
      temp2 = imrotate(temp, -90);
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = mirror(temp2,header.w);
      end

      % sigma
      [v,count] =fread(fid, header.w*header.h,'uint8');
      temp = reshape(v,header.w, header.h);
      temp2 = imrotate(temp, -90);
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im2(:,:,frame_count_NEW) = mirror(temp2,header.w);
      end

   elseif(header.filetype == 4096) %color vel
      %Each frame has 4 byte header for frame number
      tag = fread(fid,1,'int32');
      [v,count] = fread(fid,header.w*header.h,'uchar=>uchar');
      temp = reshape(v,header.w,header.h);
      temp2 = imrotate(temp, -90);
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = mirror(temp2,header.w);
      end

   elseif(header.filetype == 8192) %.el
      [v,count] = fread(fid,header.w*header.h,'int32');
      temp = reshape(v,header.w,header.h);
      temp2 = imrotate(temp, -90);
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = mirror(temp2,header.w);
      end

   elseif(header.filetype == 16384) %.elo
      [v,count] = fread(fid,header.w*header.h,'uchar=>uchar');
      temp = int16(reshape(v,header.w,header.h));
      temp2 = imrotate(temp, -90);
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = mirror(temp2,header.w);
      end

   elseif(header.filetype == 32768) %.epr
      [v,count] = fread(fid,header.w*header.h,'uchar=>uchar');
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im(:,:,frame_count_NEW) = int16(reshape(v,header.h,header.w));
      end

   elseif(header.filetype == 65536) %.ecg
      [v,count] = fread(fid,header.w*header.h,'uchar=>uchar');
      if (frame_count >= frm_range(1)) % READ AND DISCARD FIRST frm_range(1)-1 FRAMES
         Im = v;
      end

   else
      disp('Data not supported');
   end

   %whos

end

fclose(fid);

if strcmpi(im_flag,'y')
   % for RF data, plot both the RF center line and image
   if(header.filetype == 16 || header.filetype == 512)
      RPviewrf(Im, header, min([24 size(Im,3)]));

   elseif(header.filetype == 128)
      PDRFLine = Im(:,:,1);
      figure, plot(PDRFLine, 'b');
      title('PW RF');

   elseif(header.filetype == 256)
      figure, imagesc(Im(:,:,1));
      colormap(gray);
      title('PW spectrum');
   end
end
