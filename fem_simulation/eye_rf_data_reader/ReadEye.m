function [rf_frame,fname]=ReadEye(filename,op_flag,varargin)
%READEYE  Read (Riverside Research) EYE data files
%  READEYE(FILENAME,OP_FLAG,VARARGIN) will read the data file in EYE format. 
%  "filename" is the name of data file, AND op_flag (always numeric),
%  if passed, will perform the following operations: 
%   -1: remove mean from each A-line (column-by-column operation)
%    0: bring up the image/signal GUI
%    1: bring up the header GUI
%    2: remove mean from each A-line AND bring up the image/signal GUI
%    3: remove mean from each A-line AND bring up the header GUI
%  If only one argument is passed, and is not a string (signifying 
%  file name) but a number, the routine can figure out that it is 
%  "op_flag" and NOT "filename". When file name is not given, a 
%  dialog box comes up for the filename.
%
%  VARARGIN can be used to input values of noline (# of RF A-lines) 
%    and ppline (points/line), if the header values are incorrect. 
%
%  EXAMPLES:
%  RF=readeye; will bring up a dialog box for the file name, and
%              will put the RF frame in "RF" with correct reshaping
%  RF=readeye('liv01.eye'); will read file "liv01.eye", if in the 
%                           MATLAB path, and will put the RF frame 
%                           in "RF" with correct reshaping
%                           RF=readeye('liv01'); will do the same
%  RF=readeye('liv01.eye',-1); will read file "liv01.eye", if in the 
%                             MATLAB path, will put the RF frame in 
%                             "RF" with correct reshaping, and will 
%                             remove mean from each A-line (column-by-
%                             column operation)
%                             RF=readeye('liv01',-1); will do the same
%  RF=readeye('liv01.eye',0); will read file "liv01.eye", if in the 
%                             MATLAB path, will put the RF frame in 
%                             "RF" with correct reshaping, and will 
%                             bring up the echo GUI
%                             RF=readeye('liv01',0); will do the same
%  RF=readeye('liv01.eye',1); will read file "liv01.eye", if in the 
%                             MATLAB path, will put the RF frame in 
%                             "RF" with correct reshaping, and will 
%                             bring up the header GUI
%                             RF=readeye('liv01',1); will do the same
%  RF=readeye('liv01.eye',2); will read file "liv01.eye", if in the 
%                             MATLAB path, will put the RF frame in 
%                             "RF" with correct reshaping, will remove 
%                             mean from each A-line (column-by-column 
%                             operation), and will bring up echo GUI
%                             RF=readeye('liv01',2); will do the same
%  RF=readeye('liv01.eye',3); will read file "liv01.eye", if in the 
%                             MATLAB path, will put the RF frame in 
%                             "RF" with correct reshaping, will remove 
%                             mean from each A-line (column-by-column 
%                             operation), and will bring up header GUI 
%                             RF=readeye('liv01',3); will do the same
%  RF=readeye('liv01.eye',0,'noline',575); will read file "liv01.eye", if 
%                                        in the MATLAB path, will put the 
%                                        RF frame in "RF" with reshaping
%                                        the matrix assuming 575 RF A-lines, 
%                                        and will bring up the echo GUI
%                                        RF=readeye('liv01',0,'noline',575); 
%                                        will do the same
%  RF=readeye(-1); will bring up a dialog box for the file name, will 
%                 put the RF frame in "RF" with correct reshaping, and 
%                 will remove mean from each A-line (column-by-column 
%                 operation 
%  RF=readeye(0); will bring up a dialog box for the file name, will 
%                 put the RF frame in "RF" with correct reshaping, and 
%                 will bring up the echo GUI
%  RF=readeye(1); will bring up a dialog box for the file name, will 
%                 put the RF frame in "RF" with correct reshaping, and 
%                 will bring up the header GUI
%  RF=readeye(2); will bring up a dialog box for the file name, will 
%                 put the RF frame in "RF" with correct reshaping, 
%                 will remove mean from each A-line (column-by-column 
%                 operation, and will bring up the echo GUI
%  RF=readeye(3); will bring up a dialog box for the file name, will 
%                 put the RF frame in "RF" with correct reshaping, 
%                 will remove mean from each A-line (column-by-column 
%                 operation, and will bring up the header GUI
%
%  See also READEYE_HDI, READEYESEQ

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 07-98
% Revised: 05-18-11 (SKA)
% Version: 3.2.2
%
% New in this version: Can return file name if read inside ReadEye. 
%
% Copyright © 1998 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

if nargin==0	% If no argument is given, ask for the filename
   [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
   filename=[pathname char(filename)];
elseif nargin==1 % CANNOT BE varargin
   if isnumeric(filename)
      op_flag=filename;
      clear filename;
      [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
      filename=[pathname char(filename)];
   end
elseif nargin==2
   if strcmpi(filename,'noline')
      noline = op_flag;
      clear filename op_flag;
      [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
      filename=[pathname char(filename)];
   elseif strcmpi(filename,'ppline')
      ppline = op_flag;
      clear filename op_flag;
      [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
      filename=[pathname char(filename)];
   end
elseif nargin==3
   if isnumeric(filename) %  1ST ARGUMENT OP_FLAG
      eval([op_flag ' = varargin{1};']); % NOLINE/PPLINE
      op_flag=filename;
      clear filename varargin;
      [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
      filename=[pathname char(filename)];
   else
      eval([op_flag ' = varargin{1};']); % NOLINE/PPLINE
      clear op_flag varargin;
   end
elseif nargin==4
   if strcmpi(filename,'noline')
      noline = op_flag;
      eval([varargin{1} ' = varargin{2};']); % PPLINE
      clear filename op_flag varargin;
      [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
      filename=[pathname char(filename)];
   elseif strcmpi(filename,'ppline')
      ppline = op_flag;
      eval([varargin{1} ' = varargin{2};']); % NOLINE
      clear filename op_flag varargin;
      [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
      filename=[pathname char(filename)];
   end
elseif nargin==5 % ONLY ONE OF FILENAME & OP_FLAG IS PASSED
   if isnumeric(filename) %  1ST ARGUMENT OP_FLAG
      eval([op_flag ' = varargin{1};']); % NOLINE/PPLINE
      op_flag=filename;
      eval([varargin{2} ' = varargin{3};']); % PPLINE/NOLINE
      clear filename varargin;
      [filename,pathname]=uigetfile('*.eye','Select file to open','MultiSelect','on');
      filename=[pathname char(filename)];
   else
      eval([op_flag ' = varargin{1};']); % NOLINE/PPLINE
      eval([varargin{2} ' = varargin{3};']); % PPLINE/NOLINE
      clear op_flag varargin;
   end
end

fname_len=length(filename);	% if the ".eye" extension is not
                              % included in "filename", add it.
if fname_len < 5
   filename=[filename '.eye'];
elseif ~strcmpi(filename(fname_len-3:fname_len),'.eye')
   filename=[filename '.eye'];
end

% CHECK IF FILE IS IN HDI/CUMC FORMAT
hv = geteyehdr(filename,'hver');
if isempty(hv)
   error('HDI format! Use READEYE_HDI to read this.')
elseif strcmpi(hv,'HEADER_V1.0')
   precision = 'int8';
elseif strcmpi(hv,'header S1.0') || ...
      strcmpi(hv,'HEADER_V1.0 ') || strncmpi(hv,'HEADER_V2.0',11) || ...
      strncmpi(hv,'HEADER_V3.0',11) || strncmpi(hv,'HEADER_v3.1',11) || ...
      strncmpi(hv,'HEADER_V4.0',11) || strncmpi(hv,'HEADER_V4.1',11) || strncmpi(hv,'HEADER_V4.2',11) || ...
      strncmpi(hv,'HEADER_V5.0',11)
   precision = ['int' num2str(geteyehdr(filename,'word')*8)];
else   
   error('CUMC format! Convert w/ CMEDLIN2RRI before processing.')
end

global rf;	% needs to be a global for accessibility
				% in called functions, where it will again be declared global


fid=fopen(filename,'r');
% header=fread(fid,1024,'uint8');	% Read the 1024 byte header, abandoned 
% because no ready made solution exists in MATLAB for converting different 
% bytes to appropriate formats. We are now reading the necassary data in 
% the proper formats.

% IF DATA DIMENSION(S) ARE PROVIDED as INPUT ARGUMENTS 
if exist('varargin','var') % WILL EXECUTE ONLY WHEN nargin = 6
   for k=1:2:length(varargin), eval([varargin{k} ' = varargin{k+1};']); end
end

% Read the header info necessary for reading and preparing data
status=fseek(fid,12,'bof');	% move the file pointer to header length
hlen=fread(fid,1,'int16');
if hlen==0, hlen=1024; end
% READ LINES/SCAN AND POINTS/LINE, UNLESS PASSED AN INPUT PARAMETERS
if exist('ppline','var')
   ppline_passed = 1;
else
   ppline_passed = 0;
   status = fseek(fid,16,'bof');	% move the file pointer to rf points/line
   ppline = fread(fid,1,'int16');
   if ppline == 0, ppline = 2048; end
end
if exist('noline','var')
   noline_passed = 1;
else
   noline_passed = 0;
   status = fseek(fid,18,'bof');	% move the file pointer to number of lines/frame
   noline = fread(fid,1,'int16');
   if noline == 0, noline = 128; end
end
% READ THE HEADER VALUES
status = fseek(fid,16,'bof');	% move the file pointer to rf points/line
ppline_hdr = fread(fid,1,'int16');
status = fseek(fid,18,'bof');	% move the file pointer to number of lines/frame
noline_hdr = fread(fid,1,'int16');
% points/line and lines/frame will always be read (unless they are input
% parameters to reshape data after reading EYE file

% scale RF data to account for voltage scale settings
status = fseek(fid,176,'bof');
VSgain = fread(fid,1,'single');
VoltScl = 10^(VSgain/20);

status=fseek(fid,hlen,'bof');	% skip header to read data 
[rfimg,n]=fread(fid,inf,precision);	% data read into rfimg array
% position=ftell(fid);	% gives the file position
% CORRECT noline, IF POSSIBLE/NECESSARY. THE IMPLICIT ASSUMPTION IS THAT 
% ppline IN THE HEADER IS CORRECT, UNLESS SUPPLIED AS AN INPUT PARAMETER. 
%if length(rfimg) ~= (ppline*noline)
if length(rfimg) ~= (ppline*noline_hdr)
   fprintf('Incorrect ''NOLINE'' (%d) in the header of EYE file: ''%s''...\n',noline_hdr,filename);
   if noline_passed == 1;
      fprintf('Using the value %d passed as input parameter...\n',noline);
   end
end
if length(rfimg) ~= (ppline*noline)
   if noline_passed ~= 1;
      if n == (ppline*fix(n/ppline)) % ppline*noline = n
         noline = fix(n/ppline);
         fprintf('Correct number of A-line: %d; using this value...\n',noline);
      else
         fprintf(['# data samples (%d) != ppline (%d) * noline (header: %d, n/ppline: %d). \n'...
            'EXITING with error...\n'],...
            n,ppline,noline,fix(n/ppline));
      end
   else
      fprintf(['!*&$!!!..# data samples (%d) != ppline (%d: from header) * noline (%d: input parameter). \n'...
         'EXITING with error...\n'],n,ppline,noline);
   end
end
rf=VoltScl*reshape(rfimg,ppline,noline); % data reshaped to A-lines and voltage scale applied

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

rf_frame=rf;
if nargout > 1, fname = filename; end