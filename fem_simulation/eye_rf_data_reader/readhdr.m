%READHDR  This script reads the header in data file in EYE format

% Version 1.0:
%
% Copyright (c) July 1998.
% Last revised July 31, 1998.
% This matlab program was developed by S. Kaisar Alam.
% Questions & suggestions to <kalam@rrinyc.org>
%___________________________________________________________

global Adtype adtype age bits bw Calib_atten calib_atten Calib_file calib_file Comment comment;
global Cspecincl_flag cspecincl_flag d_loc Data_atten data_atten Data_file data_file Date date;
global delay disease Ext_id ext_id f0 fi fs Hver hver hlen Institute institute Mode mode noline;
global offset_cal Oper oper organ Pat_id pat_id pivot ppline Pscn pscn scan_angle Sex sex tdrid;
global Time time word;	% needs to be a global for accessibility in called functions,
					% where it will again be declared global
               
status=fseek(fid,0,'bof');		% move file pointer at the start of file
hver=fread(fid,12,'int8');		% read the first 12 bytes
Hver=sprintf('%s',char(hver));		% convert into string to get header version
if isempty(Hver), Hver='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,12,'bof');	% move the file pointer to header length
hlen=fread(fid,1,'int16');
status=fseek(fid,16,'bof');	% move the file pointer to rf points/line
ppline=fread(fid,1,'int16');	
status=fseek(fid,18,'bof');	% move the file pointer to number of lines/frame
noline=fread(fid,1,'int16');
status=fseek(fid,20,'bof');	% move file pointer to sampling frequency
fs=fread(fid,1,'int16');
status=fseek(fid,22,'bof');	% move file pointer to # A/D bits
bits=fread(fid,1,'int16');
status=fseek(fid,24,'bof');	% move file pointer to # bytes per A/D word
word=fread(fid,1,'int16');
status=fseek(fid,26,'bof');	% move file pointer to A/D type
adtype=fread(fid,6,'int8');	% read 6 bytes
Adtype=sprintf('%s',char(adtype));	% convert into string
if isempty(Adtype), Adtype='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,32,'bof');
bw=fread(fid,1,'float32');
status=fseek(fid,36,'bof');
f0=fread(fid,1,'float32');
status=fseek(fid,40,'bof');
fi=fread(fid,1,'float32');
status=fseek(fid,44,'bof');
tdrid=fread(fid,1,'int32');
status=fseek(fid,48,'bof');
delay=fread(fid,1,'float32');
status=fseek(fid,52,'bof');
pivot=fread(fid,1,'float32');
status=fseek(fid,56,'bof');
scan_angle=fread(fid,1,'float32');
status=fseek(fid,60,'bof');
oper=fread(fid,4,'int8');
Oper=sprintf('%s',char(oper));	% convert into string
if isempty(Oper), Oper='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,64,'bof');
mode=fread(fid,7,'int8');	% Scan mode, i.e., linear, sector, 3-D, compound, etc.
Mode=sprintf('%s',char(mode));	% convert into string
if isempty(Mode), Mode='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,71,'bof');
institute=fread(fid,9,'int8');	% where scanned, e.g., RRI, CUMC, etc.
Institute=sprintf('%s',char(institute));	% convert into string
if isempty(Institute), Institute='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,80,'bof');
date=fread(fid,8,'int8');
Date=sprintf('%s',char(date));	% convert into string
if isempty(Date), Date='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,88,'bof');
time=fread(fid,8,'int8');
Time=sprintf('%s',char(time));	% convert into string
if isempty(Time), Time='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,96,'bof');
data_file=fread(fid,13,'int8');
Data_file=sprintf('%s',char(data_file));	% convert into string
if isempty(Data_file), Data_file='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,109,'bof');
data_atten=fread(fid,3,'int8');
Data_atten=sprintf('%s',char(data_atten));	% convert into string
if isempty(Data_atten), Data_atten='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,112,'bof');
calib_file=fread(fid,13,'int8');
Calib_file=sprintf('%s',char(calib_file));	% convert into string
if isempty(Calib_file), Calib_file='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,125,'bof');
calib_atten=fread(fid,3,'int8');
Calib_atten=sprintf('%s',char(calib_atten));	% convert into string
if isempty(Calib_atten), Calib_atten='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,128,'bof');
pat_id=fread(fid,6,'int8');
Pat_id=sprintf('%s',char(pat_id));	% convert into string
if isempty(Pat_id), Pat_id='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,134,'bof');
ext_id=fread(fid,10,'int8');
Ext_id=sprintf('%s',char(ext_id));	% convert into string
if isempty(Ext_id), Ext_id='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,144,'bof');
age=fread(fid,1,'int16');
status=fseek(fid,146,'bof');
sex=fread(fid,1,'int8');
Sex=sprintf('%s',char(sex));	% convert into string
if isempty(Sex), Sex='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,147,'bof');
pscn=fread(fid,1,'int8');	% previously scanned?
Pscn=sprintf('%s',char(pscn));	% convert into string
if isempty(Pscn), Pscn='Empty!!'; end;	% If zero, change to empty
status=fseek(fid,148,'bof');	% move file pointer to 12 character blank
status=fseek(fid,160,'bof');
organ=fread(fid,1,'int16');
status=fseek(fid,162,'bof');
disease=fread(fid,1,'int16');
status=fseek(fid,164,'bof');
d_loc=fread(fid,1,'int16');
status=fseek(fid,166,'bof');	% move file pointer to 12 character blank
status=fseek(fid,178,'bof');
cspecincl_flag=fread(fid,1,'int16');	% Is calibration spectrum included in header?
if cspecincl_flag==0		% It is NOT included
   Cspecincl_flag='N';
elseif cspecincl_flag==1	% It is included
   Cspecincl_flag='Y';
else
   Cspecincl_flag='I';	% invalid value
end
status=fseek(fid,180,'bof');
offset_cal=fread(fid,1,'int32');
status=fseek(fid,184,'bof');	% move file pointer to 10 character blank
status=fseek(fid,194,'bof');
comment=fread(fid,64,'int8');
Comment=sprintf('%s',char(comment));
if isempty(Comment), Comment='Empty!!'; end;	% If zero, change to empty