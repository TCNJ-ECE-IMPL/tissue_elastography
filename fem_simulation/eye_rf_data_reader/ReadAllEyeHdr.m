%READALLEYEHDR  This script reads the header in data file in EYE format

% Author:  S. Kaisar Alam, Ph.D.
% Email:   kaisar.alam@ieee.org
% Written: 05-17-05
% Revised: 05-18-11 (SKA)
% Version: 1.1
%
% New in this version: Fixed sprintf format specifier warning
%
% Copyright © 2005 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

status=fseek(fid,0,'bof');          % move file pointer at the start of file
hver=fread(fid,12,'int8');          % read the first 12 bytes
Hver=sprintf('%s',char(hver));      % CONVERT INTO STRING TO GET HEADER VERSION
status=fseek(fid,12,'bof');         % move the file pointer to header length
hlen=fread(fid,1,'int16');
status=fseek(fid,16,'bof');         % move the file pointer to rf points/line
ppline=fread(fid,1,'int16');	
status=fseek(fid,18,'bof');         % move the file pointer to number of lines/frame
noline=fread(fid,1,'int16');
status=fseek(fid,20,'bof');         % move file pointer to sampling frequency
fs=fread(fid,1,'int16');
status=fseek(fid,22,'bof');         % move file pointer to # A/D bits
bits=fread(fid,1,'int16');
status=fseek(fid,24,'bof');         % move file pointer to # bytes per A/D word
word=fread(fid,1,'int16');
status=fseek(fid,26,'bof');         % move file pointer to A/D type
adtype=fread(fid,6,'int8');         % read 6 bytes
Adtype=sprintf('%s',char(adtype));  % CONVERT INTO STRING
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
Oper=sprintf('%s',char(oper));      % CONVERT INTO STRING
status=fseek(fid,64,'bof');
mode=fread(fid,7,'int8');           % Scan mode, i.e., linear, sector, 3-D, compound, etc.
Mode=sprintf('%s',char(mode));      % convert into string
status=fseek(fid,71,'bof');
institute=fread(fid,9,'int8');      % where scanned, e.g., RRI, CUMC, etc.
Institute=sprintf('%s',char(institute)); % convert into string
status=fseek(fid,80,'bof');
dDate=fread(fid,8,'int8'); % VARIABLE NAME CHANGED BECAUSE FUNCTION date EXISTS
DDate=sprintf('%s',char(dDate));	% convert into string
status=fseek(fid,88,'bof');
time=fread(fid,8,'int8');
Time=sprintf('%s',char(time));	% convert into string
status=fseek(fid,96,'bof');
data_file=fread(fid,13,'int8');
Data_file=sprintf('%s',char(data_file));	% convert into string
status=fseek(fid,109,'bof');
data_atten=fread(fid,3,'int8');
Data_atten=sprintf('%s',char(data_atten));	% convert into string
status=fseek(fid,112,'bof');
calib_file=fread(fid,13,'int8');
Calib_file=sprintf('%s',char(calib_file));	% convert into string
status=fseek(fid,125,'bof');
calib_atten=fread(fid,3,'int8');
Calib_atten=sprintf('%s',char(calib_atten));	% convert into string
status=fseek(fid,128,'bof');
pat_id=fread(fid,6,'int8');
Pat_id=sprintf('%s',char(pat_id));	% convert into string
status=fseek(fid,134,'bof');
ext_id=fread(fid,10,'int8');
Ext_id=sprintf('%s',char(ext_id));	% convert into string
status=fseek(fid,144,'bof');
age=fread(fid,1,'int16');
status=fseek(fid,146,'bof');
sex=fread(fid,1,'int8');
Sex=sprintf('%s',char(sex));	% convert into string
status=fseek(fid,147,'bof');
pscn=fread(fid,1,'int8');	% previously scanned?
Pscn=sprintf('%s',char(pscn));	% convert into string
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
status=fseek(fid,180,'bof');
offset_cal=fread(fid,1,'int32');
status=fseek(fid,184,'bof');	% move file pointer to 10 character blank
status=fseek(fid,194,'bof');
comment=fread(fid,64,'int8');
Comment=sprintf('%s',char(comment));