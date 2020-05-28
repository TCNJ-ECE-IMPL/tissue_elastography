function hdr = geteyehdr(filename,hdrname)
%GETEYEHDR  Reads individual header in EYE data file(s)
%
%   HDR = GETEYEHDR(FILENAME,HDRNAME), returns the header HDRNAME in eye 
%   file FILENAME. HDRNAME can be one of the following (case-insensitive): 
%   HEADER VERSION
%   'hver':    header version
%   'hlen':    header length
%   ADC INFO
%   'ppline':  rf points/line
%   'noline':  # A-lines/frame
%   'fs':      sampling freq (MHz)
%   'bits':    # A/D bits
%   'word':    # bytes per A/D word
%   'adtype':  A/D type
%   TRANSDUCER INFO
%   'bw':      Bandwidth
%   'f0':      Center freq (MHz)
%   'fi':      Start freq (MHz)
%   'tdrid':   Transducer ID
%   SCAN INFO
%   'delay':   Delay (mm)
%   'pivot':   Pivot distanc (mm)
%   'scnang':  Scan angle
%   'oper':    Operator initial
%   'mode':    Scan mode, i.e., linear, sector, 3-D, compound, etc.
%   'inst':    where scanned, e.g., RRI, CUMC, etc.
%   DATE TIME
%   'date':    Date scanned
%   'time':    Time scanned
%   RF FILE INFO
%   'datfile': Data file name
%   'datatn':  Data attenuation
%   RF CALIBRATION FILE INFO
%   'calfile': Calibration file name
%   'calatn':  Calibration attenuation
%   PATIENT INFO (ONLY USED FOR CLINICAL DATA)
%   'pat_id':  Patient ID
%   'ext_id':  Extended ID
%   'age':     Age
%   'sex':     Sex
%   'pscn':    previously scanned?
%   TISSSUE TYPE (NOT CURRENTLY USED)
%   'organ=':  Organ
%   'disease': Disease type
%   'd_loc':   Disease location
%   VOLTAGE SCALE INFO (DB VALUES TO RETURN TO 1 VPP)
%   'dscale':  Digitizer scale - zero dB is 1 Vpp mapping of binary, 6 dB 2 Vpp etc)
%   'gain':    Preamplifier value; gets subtracted from Dig scale to find true voltage
%   'atten':   Any attenuation values get added to
%   OBSOLETE - 'csinc':   Is calibration spectrum included in header (Y/N)? - OBSOLETE
%   OBSOLETE - 'ocal':    Offset of calibration spectrum from BOF - OBSOLETE
%   COMMENT
%   'comment': Comments

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 05-21-98
% Revised: 03-11-10 (SKA)
% Version: 2.0
%
% New in this version: Headers in new header version 5.0 implemented.
%
% Copyright © 1998 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________


fname_len=length(filename);	% if the ".eye" extension is not
                              % included in "filename", add it.
if ~strcmpi(filename(fname_len-3:fname_len),'.eye')
   filename=[filename '.eye'];
end

fid = fopen(filename,'r');

if strcmpi(hdrname,'hver')			% header version
   status=fseek(fid,0,'bof');
   hver=fread(fid,12,'int8');
   Hver=sprintf('%s',char(hver)); hdr = Hver;
elseif strcmpi(hdrname,'hlen')	% header length
   status=fseek(fid,12,'bof');
   hlen=fread(fid,1,'int16'); hdr = hlen;
elseif strcmpi(hdrname,'ppline')	% rf points/line
   status=fseek(fid,16,'bof');
   ppline=fread(fid,1,'int16'); hdr = ppline;
elseif strcmpi(hdrname,'noline')	% number of lines/frame
   status=fseek(fid,18,'bof');
   noline=fread(fid,1,'int16'); hdr = noline;
elseif strcmpi(hdrname,'fs')		% sampling frequency (MHz)
   status=fseek(fid,20,'bof');
   fs=fread(fid,1,'int16'); hdr = fs;
elseif strcmpi(hdrname,'bits')	% # A/D bits
   status=fseek(fid,22,'bof');
   bits=fread(fid,1,'int16'); hdr = bits;
elseif strcmpi(hdrname,'word')	% # bytes per A/D word
   status=fseek(fid,24,'bof');
   word=fread(fid,1,'int16'); hdr = word;
elseif strcmpi(hdrname,'adtype')	% A/D type
   status=fseek(fid,26,'bof');
   adtype=fread(fid,6,'int8');
   Adtype=sprintf('%s',adtype); hdr = Adtype;
elseif strcmpi(hdrname,'bw')		% BANDWIDTH
   status=fseek(fid,32,'bof');
   bw=fread(fid,1,'float32'); hdr = bw;
elseif strcmpi(hdrname,'f0')		% CTR FREQ (MHz)
   status=fseek(fid,36,'bof');
   f0=fread(fid,1,'float32'); hdr = f0;
elseif strcmpi(hdrname,'fi')		% START FREQ (MHz)
   status=fseek(fid,40,'bof');
   fi=fread(fid,1,'float32'); hdr = fi;
elseif strcmpi(hdrname,'tdrid')	% XDUCER ID
   status=fseek(fid,44,'bof');
   tdrid=fread(fid,1,'int32'); hdr = tdrid;
elseif strcmpi(hdrname,'delay')	% DELAY
   status=fseek(fid,48,'bof');
   delay=fread(fid,1,'float32'); hdr = delay;
elseif strcmpi(hdrname,'pivot')	% PIVOT DISTANCE (MM)
   status=fseek(fid,52,'bof');
   pivot=fread(fid,1,'float32'); hdr = pivot;
elseif strcmpi(hdrname,'scnang')	% SCAN ANGLE (DEG)
   status=fseek(fid,56,'bof');
   scan_angle=fread(fid,1,'float32'); hdr = scan_angle;
elseif strcmpi(hdrname,'oper')	% OPERATOR INITIALS
   status=fseek(fid,60,'bof');
   oper=fread(fid,4,'int8');
   Oper=sprintf('%s',oper); hdr = Oper;
elseif strcmpi(hdrname,'mode')	% Scan mode, i.e., linear, sector, 3-D, compound, etc.
   status=fseek(fid,64,'bof');
   mode=fread(fid,7,'int8');
   Mode=sprintf('%s',mode); hdr = Mode;
elseif strcmpi(hdrname,'inst')	% where scanned, e.g., RRI, CUMC, etc.
   status=fseek(fid,71,'bof');
   institute=fread(fid,9,'int8');
   Institute=sprintf('%s',institute); hdr = Institute;
elseif strcmpi(hdrname,'date')	% DATE SCANNED
   status=fseek(fid,80,'bof');
   date=fread(fid,8,'int8');
   Date=sprintf('%s',date); hdr = Date;
elseif strcmpi(hdrname,'time')	% TIME SCANNED
   status=fseek(fid,88,'bof');
   time=fread(fid,8,'int8');
   Time=sprintf('%s',time); hdr = Time;
elseif strcmpi(hdrname,'datfile')	% DATA FILE NAME
   status=fseek(fid,96,'bof');
   data_file=fread(fid,13,'int8');
   Data_file=sprintf('%s',data_file); hdr = Data_file;
elseif strcmpi(hdrname,'datatn')		% DATA ATTENUATION
   status=fseek(fid,109,'bof');
   data_atten=fread(fid,3,'int8');
   Data_atten=str2num(sprintf('%s',char(data_atten))); hdr = Data_atten;
elseif strcmpi(hdrname,'calfile')	% CALIBRATION FILE NAME
   status=fseek(fid,112,'bof');
   calib_file=fread(fid,13,'int8');
   Calib_file=sprintf('%s',calib_file); hdr = Calib_file;
elseif strcmpi(hdrname,'calatn')		% CALIBRATION ATTENUATION
   status=fseek(fid,125,'bof');
   calib_atten=fread(fid,3,'int8');
   Calib_atten=sprintf('%s',calib_atten); hdr = Calib_atten;
elseif strcmpi(hdrname,'pat_id')		% PATIENT ID
   status=fseek(fid,128,'bof');
   pat_id=fread(fid,6,'int8');
   Pat_id=sprintf('%s',pat_id); hdr = Pat_id;
elseif strcmpi(hdrname,'ext_id')		% EXTENDED ID
   status=fseek(fid,134,'bof');
   ext_id=fread(fid,10,'int8');
   Ext_id=sprintf('%s',ext_id); hdr = Ext_id;
elseif strcmpi(hdrname,'age')			% AGE
   status=fseek(fid,144,'bof');
   age=fread(fid,1,'int16'); hdr = age;
elseif strcmpi(hdrname,'sex')			% SEX
   status=fseek(fid,146,'bof');
   sex=fread(fid,1,'int8');
   Sex=sprintf('%s',sex); hdr = sex;
elseif strcmpi(hdrname,'pscn')	% previously scanned?
   status=fseek(fid,147,'bof');
   pscn=fread(fid,1,'int8');
   Pscn=sprintf('%s',pscn); hdr = Pscn;
elseif strcmpi(hdrname,'organ')	% ORGAN
   status=fseek(fid,160,'bof');
   organ=fread(fid,1,'int16'); hdr = organ;
elseif strcmpi(hdrname,'disease')	% DISEASE
   status=fseek(fid,162,'bof');
   disease=fread(fid,1,'int16'); hdr = disease;
elseif strcmpi(hdrname,'d_loc')	% DISEASE LOCTION
   status=fseek(fid,164,'bof');
   d_loc=fread(fid,1,'int16'); hdr = d_loc;
elseif strcmpi(hdrname,'dscale')	% DIGITIZER SCALE (0 DB IS 1 VPP MAPPING OF BINARY, 6 DB 2 VPP ETC)
   status=fseek(fid,176,'bof');
   dscale=fread(fid,1,'float32'); hdr = dscale;
elseif strcmpi(hdrname,'gain')	% GAIN (PREAMPLIFIER VALUE; GETS SUBTRACTED FROM DIG SCALE TO FIND TRUE VOLTAGE)
   status=fseek(fid,180,'bof');
   gain=fread(fid,1,'float32'); hdr = gain;
elseif strcmpi(hdrname,'atten')	% ATTENUATION (ANY ATTENUATION VALUES GET ADDED TO)
   status=fseek(fid,184,'bof');
   atten=fread(fid,1,'float32'); hdr = atten;
% elseif strcmpi(hdrname,'csinc')	% Is calibration spectrum included in header?
%    status=fseek(fid,178,'bof');
%    cspecincl_flag=fread(fid,1,'int16');
%    if cspecincl_flag==0		% It is NOT included
%       Cspecincl_flag='N';
%    elseif cspecincl_flag==1	% It is included
%       Cspecincl_flag='Y';
%    else
%       Cspecincl_flag='I';	% invalid value
%    end
%    hdr = Cspecincl_flag;
% elseif strcmpi(hdrname,'ocal')	% OFFSET OF CALIBRATION SPECTRUM
%    status=fseek(fid,180,'bof');
%    offset_cal=fread(fid,1,'int32'); hdr = offset_cal;
elseif strcmpi(hdrname,'comment')	% COMMENT
   status=fseek(fid,192,'bof');
   comment=fread(fid,64,'int8');
   Comment=sprintf('%s',comment); hdr = Comment;
else
   error('Unknown header')
end

fclose(fid);