% FROM VT003/V0254
rfseq = RPread('10-58-09.rf');
rf_pre = double(rfseq(:,:,269)); % PRE COMPRESSION
rf_pst = double(rfseq(:,:,369)); % POST COMPRESSION
% COMPUTE STRAIN MAPS USING THE COMMON ROUTINES
helpwin EstStrn
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.04,'G'); % GRADIENT OF DISPLACEMENT MAP
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.04,'ls'); % LEAST SQUARES
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.04,'us'); % UNIFORM STRETCHING
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.04,'lsus'); % UNIFORM STRETCHING + LEAST SQUARES
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.04,'a'); % ADAPTIVE STRETCHING
imagesc(s), colorbar
% SAMPLING FREQUENCY IS 20 MHZ (FS = 20 MHZ)
% UPSAMPLE BY 2.5 TO MAKE THE EFFECTIVE FS = 50 MHZ
% ALSO CAN UPSAMPLE BY 5 (FS = 100 MHZ)
rf_pre2 = interpft(rf_pre,2580); % UPSAMPLING BY 2.5
rf_pst2 = interpft(rf_pst,2580);
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.04,'g');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.04,'ls');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.04,'us');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.04,'lsus');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.04,'a');
imagesc(s), colorbar

% FROM VT021/V0306
rfseq = RPread('08-33-19.rf');
rf_pre = double(rfseq(:,:,85));
rf_pst = double(rfseq(:,:,84));
[s,d,c] = EstStrn(rf_pre,rf_pst,192,128,64,0.0075,0,0.015,'g');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,192,128,64,0.0075,0,0.015,'ls');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,192,128,64,0.0075,0,0.015,'us');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,192,128,64,0.0075,0,0.015,'lsus');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,192,128,64,0.005,0,0.01,'a');
imagesc(s), colorbar
% UPSAMPLE BY 2.5 TO MAKE THE EFFECTIVE FS = 50 MHZ
rf_pre2 = interpft(rf_pre,2580);
rf_pst2 = interpft(rf_pst,2580);
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.0075,0,0.015,'g');
figure(1), imagesc(s), colorbar
figure(2), imagesc(medfilt2(d)), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.0075,0,0.015,'ls');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.0075,0,0.015,'us');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.0075,0,0.015,'lsus');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.005,0,0.01,'a');
imagesc(s), colorbar
imagesc(medfilt2(d)), colorbar
imagesc(medfilt2(d,[5 5])), colorbar

% VT0019/V0301
rfseq = RPread('10-40-02.rf');
rf_pre = double(rfseq(:,:,85));
rf_pst = double(rfseq(:,:,84));
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.005,0,0.01,'g');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.005,0,0.01,'ls');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.005,0,0.01,'a');
imagesc(s), colorbar
% UPSAMPLE BY 2.5 TO MAKE THE EFFECTIVE FS = 50 MHZ
rf_pre2 = interpft(rf_pre,2580);
rf_pst2 = interpft(rf_pst,2580);
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.005,0,0.01,'g');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.005,0,0.01,'ls');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.005,0,0.01,'a');
imagesc(s), colorbar

% VT022/V0307
rfseq = RPread('13-40-57.rf');
rf_pre = double(rfseq(:,:,24));
rf_pst = double(rfseq(:,:,124));
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.025,'g');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.025,'us');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.025,'ls');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.025,'a');
imagesc(s), colorbar
rf_pre2 = interpft(rf_pre,2580);
rf_pst2 = interpft(rf_pst,2580);
% UPSAMPLE BY 2.5 TO MAKE THE EFFECTIVE FS = 50 MHZ
rf_pre2 = interpft(rf_pre,2580);
rf_pst2 = interpft(rf_pst,2580);
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.025,'g');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.025,'ls');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.025,'us');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.025,'lsus');
imagesc(s), colorbar
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.025,'a');
imagesc(s), colorbar
