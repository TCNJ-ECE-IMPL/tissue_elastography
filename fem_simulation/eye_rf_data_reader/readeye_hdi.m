function [rf_frame,tgc] = readeye_hdi(filename,op_flag,tgc_flag)
%READEYE_HDI  Read ATL HDI data files in .EYE format
%  READEYE_HDI(filename,op_flag) will read the data file in EYE 
%  format. "filename" is the name of data file, AND op_flag,
%  if passed, will bring up the header GUI if 1, and the image/
%  signal GUI otherwise. If only one argument is passed, and is 
%  not a string (signifying file name) but a number, the routine 
%  can figure out that it is "op_flag" and NOT "filename". When 
%  file name is not given, a dialog box comes up for the filename.
%  READEYE_HDI(filename,op_flag,tgc_flag) will remove the TGC 
%  correction from the data ONLY IF tgc_flag='y'. 
%  IMPORTANT: tgc_flag HAS TO BE single character, if nargin<3. 
%  Otherwise, the code will interpret it as filename (error).
%
%  EXAMPLES:
%  RF=readeye_hdi; will bring up a dialog box for the file name, and
%                  put the RF frame in "RF" with correct reshaping
%
%  RF=readeye_hdi('liv01.eye'); will read file "liv01.eye", if in the 
%  Or RF=readeye_hdi('liv01');  MATLAB path, and will put the RF frame 
%                               in "RF" with correct reshaping
%
%  RF=readeye_hdi('liv01.eye','y'); will read file "liv01.eye", if in 
%  Or RF=readeye_hdi('liv01','y');  the MATLAB path, will put the RF 
%                                   frame in "RF" with correct reshaping, 
%                                   and correct for the TGC.
%
%  RF=readeye_hdi('liv01.eye',-1); will read file "liv01.eye", if in the 
%  Or RF=readeye_hdi('liv01',-1);     MATLAB path, will put the RF frame 
%                                     in "RF" with correct reshaping, and 
%                                     will remove mean from each A-line
%                                     (column-by-column operation)
%
%  RF=readeye_hdi('liv01.eye',0); will read file "liv01.eye", if in the 
%  Or RF=readeye_hdi('liv01',0);      MATLAB path, will put the RF frame 
%                                     in "RF" with correct reshaping, and 
%                                     will bring up the echo GUI
%
%  RF=readeye_hdi('liv01.eye',1); will read file "liv01.eye", if in the 
%  Or RF=readeye_hdi('liv01',1);      MATLAB path, will put the RF frame 
%                                     in "RF" with correct reshaping, and 
%                                     will bring up the header GUI
%
%  RF=readeye_hdi('liv01.eye',2); will read file "liv01.eye", if in the 
%  Or RF=readeye_hdi('liv01',2);      MATLAB path, will put the RF frame 
%                                     in "RF" with correct reshaping, will 
%                                     remove mean from each A-line (column-
%                                     by-column operation and will bring up 
%                                     the echo GUI
%
%  RF=readeye_hdi('liv01.eye',3); will read file "liv01.eye", if in the 
%  Or RF=readeye_hdi('liv01',3);      MATLAB path, will put the RF frame 
%                                     in "RF" with correct reshaping, will 
%                                     remove mean from each A-line (column-
%                                     by-column operation and will bring up 
%                                     the header GUI
%
%  RF=readeye_hdi('liv01.eye',-1,'y'); will read file "liv01.eye", if in 
%  Or RF=readeye_hdi('liv01',-1,'y'); the MATLAB path, will put the RF 
%                                     frame in "RF" with correct reshaping, 
%                                     correct for the TGC, and will remove 
%                                     mean from each A-line (column-by-column
%                                     operation)
%
%  RF=readeye_hdi('liv01.eye',0,'y'); will read file "liv01.eye", if in 
%  Or RF=readeye_hdi('liv01',0,'y');  the MATLAB path, will put the RF 
%                                     frame in "RF" with correct reshaping, 
%                                     correct for the TGC, and will bring 
%                                     up the echo GUI
%
%  RF=readeye_hdi('liv01.eye',1,'y'); will read file "liv01.eye", if in 
%  Or RF=readeye_hdi('liv01',1,'y');  the MATLAB path, will put the RF 
%                                     frame in "RF" with correct reshaping, 
%                                     correct for the TGC and will bring 
%                                     up the header GUI
%
%  RF=readeye_hdi('liv01.eye',2,'y'); will read file "liv01.eye", if in 
%  Or RF=readeye_hdi('liv01',2,'y');  the MATLAB path, will put the RF 
%                                     frame in "RF" with correct reshaping, 
%                                     correct for the TGC, will remove mean 
%                                     from each A-line (column-by-column 
%                                     operation), and will bring up echo GUI
%
%  RF=readeye_hdi('liv01.eye',3,'y'); will read file "liv01.eye", if in 
%  Or RF=readeye_hdi('liv01',3,'y');  the MATLAB path, will put the RF 
%                                     frame in "RF" with correct reshaping, 
%                                     correct for the TGC, will remove mean 
%                                     from each A-line (column-by-column 
%                                     operation), and will bring up header GUI
%
%  RF=readeye_hdi(-1,'y'); will bring up a dialog box for the file name, will
%                         put the RF frame in "RF" with correct reshaping,
%                         correct for TGC, and will remove mean from each A-line
%                         (column-by-column operation)
%  RF=readeye_hdi(0,'y'); will bring up a dialog box for the file name, 
%                         will put the RF frame in "RF" with correct
%                         reshaping, correct for TGC, and will bring up
%                         the echo GUI
%  RF=readeye_hdi(1,'y'); will bring up a dialog box for the file name, will
%                         put the RF frame in "RF" with correct reshaping,
%                         correct for TGC, and will bring up the header GUI
%  RF=readeye_hdi(2,'y'); will bring up a dialog box for the file name, will
%                         put the RF frame in "RF" with correct reshaping,
%                         correct for TGC, will remove mean from each A-line 
%                         (column-by-column operation), and will bring up the 
%                         echo GUI
%  RF=readeye_hdi(3,'y'); will bring up a dialog box for the file name, will
%                         put the RF frame in "RF" with correct reshaping,
%                         correct for TGC, will remove mean from each A-line 
%                         (column-by-column operation), and will bring up the 
%                         header GUI
%
%  RF=readeye_hdi(-1); will bring up a dialog box for the file name, and will 
%                         put the RF frame in "RF" with correct reshaping,
%                         and will remove mean from each A-line (column-by-
%                         column operation)
%  RF=readeye_hdi(0); will bring up a dialog box for the file name, and will 
%                         put the RF frame in "RF" with correct reshaping,
%                         and will bring up the echo GUI
%  RF=readeye_hdi(1); will bring up a dialog box for the file name, and will 
%                         put the RF frame in "RF" with correct reshaping,
%                         and will bring up the header GUI
%  RF=readeye_hdi(2); will bring up a dialog box for the file name, and will 
%                         put the RF frame in "RF" with correct reshaping,
%                         will remove mean from each A-line (column-by-column 
%                         operation), and will bring up the echo GUI
%  RF=readeye_hdi(3); will bring up a dialog box for the file name, and will 
%                         put the RF frame in "RF" with correct reshaping,
%                         will remove mean from each A-line (column-by-column 
%                         operation), and will bring up the header GUI
%
%  RF=readeye_hdi('Yes'); will give an error message unless a file named 
%                         yes.eye exists.
%
%  See also READEYE

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 10-98
% Revised: 01-22-09 (SKA)
% Version: 3.1
%
% New in this version: Test for HDI format on line 199 updated.  
%
% Copyright © 1998 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if nargin==0	% If no argument is given, ask for the filename
   [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
   filename=[pathname char(filename)];
elseif nargin==1
   if isnumeric(filename)
      op_flag=filename;
      clear filename;
      [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
      filename=[pathname char(filename)];
   end
   if sum(isletter(filename))==1
      tgc_flag=filename;
      clear filename;
      [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
      filename=[pathname char(filename)];
   end
elseif nargin==2
   if isnumeric(filename)
      tgc_flag=op_flag;
      op_flag=filename;
      clear filename;
      [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
      filename=[pathname char(filename)];
   end
   if sum(isletter(op_flag))==1
      tgc_flag=op_flag;
      clear op_flag;
   end
end

%if ~exist('tgc_flag','var') % tgc_flag NOT PASSED
%   tgc_flag=questdlg('Correct for TGC?','TGC correction query','Yes','No','Yes');
%else % tgc_flag PASSED
%   if tgc_flag=='y',tgc_flag='Yes';end
%end
if ~exist('tgc_flag','var') % tgc_flag NOT PASSED
   warning('TGC_flag not passed! No TGC correction will be applied...')
   tgc_flag = 'No';
else % tgc_flag PASSED
   if tgc_flag=='y',tgc_flag='Yes';end
end

fname_len=length(filename);	% if the ".eye" extension is not
                              % included in "filename", add it.
if ~strcmpi(filename(fname_len-3:fname_len),'.eye')
   filename=[filename '.eye'];
end

% CHECK IF FILE IS IN HDI FORMAT
hv = geteyehdr(filename,'hver');
if sum(hv) % NOT EMPTY CHARACTERS
   error('NOT in HDI format! Use READEYE to read this.')
end

global rf;	% needs to be a global for accessibility
				% in called functions, where it will again be declared global


fid=fopen(filename,'r');
% header=fread(fid,1024,'uint8');	% Read the 1024 byte header, abandoned 
% because no ready made solution exists in MATLAB for converting different 
% bytes to appropriate formats. We are now reading the necassary data in 
% the proper formats.

% Read the header info necessary for reading and preparing data
status=fseek(fid,12,'bof');	% move the file pointer to header length
hlen=fread(fid,1,'int16');
if hlen==0, hlen=1024; end
status=fseek(fid,16,'bof');	% move the file pointer to rf points/line
ppline=fread(fid,1,'int16');	
if ppline==0, ppline=2048; end
status=fseek(fid,18,'bof');	% move the file pointer to number of lines/frame
noline=fread(fid,1,'int16');
if noline==0, noline=128; end
% points/line and lines/frame will always be read to reshape data after reading

status=fseek(fid,hlen,'bof');	% skip header to read data 
% [rfimg,n]=fread(fid,inf,'int8');	% data read into rfimg array
[rfimg,n]=fread(fid,noline*ppline,'int16');	% data read into rfimg array
tgc=fread(fid,Inf,'float32');	% Read TGC values
% position=ftell(fid);	% gives the file position
rf=reshape(rfimg,ppline,noline); % data reshaped to A-lines

clear hlen noline ppline;	% clears the header info necessary to read data

readhdr; % read the header info
fclose(fid);

% ADDITIONAL OPERATIONS
if exist('op_flag','var')
   % could use "menu" for simpler programming, but uicontrol is far more elegant
   if op_flag==-1
      rf=rf-ones(ppline,1)*mean(rf); % remove mean from A-lines
   elseif op_flag==0
      echodisp; % signal GUI will be called
   elseif op_flag==1
      hdrdisp; % header GUI will be called
   elseif op_flag==2
      rf=rf-ones(ppline,1)*mean(rf); % remove mean from A-lines
      echodisp; % signal GUI will be called
   elseif op_flag==3
      rf=rf-ones(ppline,1)*mean(rf); % remove mean from A-lines
      hdrdisp; % header GUI will be called
   else
      warning('Unknown value for op_flag!')
   end
end

% UNDO TGC COMPENSATION
if strcmpi(tgc_flag,'Yes')
   TGC=tgc*ones(1,noline);
   rf = rf./TGC;
end

rf_frame=rf;