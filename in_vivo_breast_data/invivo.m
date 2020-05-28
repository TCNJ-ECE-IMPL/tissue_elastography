clear all
close all

% FROM VT003/V0254
rfseq = RPread('10-58-09.rf');
rf_pre = double(rfseq(:,:,269)); % PRE COMPRESSION
rf_pst = double(rfseq(:,:,369)); % POST COMPRESSION
% COMPUTE STRAIN MAPS USING THE COMMON ROUTINES
%helpwin EstStrn

figure(100)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.04,'G'); % GRADIENT OF DISPLACEMENT MAP
subplot(2,5,1), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.04,'ls'); % LEAST SQUARES
subplot(2,5,2), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.04,'us'); % UNIFORM STRETCHING
subplot(2,5,3), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.04,'lsus'); % UNIFORM STRETCHING + LEAST SQUARES
subplot(2,5,4), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.04,'a'); % ADAPTIVE STRETCHING
subplot(2,5,5), imagesc(s)

% SAMPLING FREQUENCY IS 20 MHZ (FS = 20 MHZ)
% UPSAMPLE BY 2.5 TO MAKE THE EFFECTIVE FS = 50 MHZ
% ALSO CAN UPSAMPLE BY 5 (FS = 100 MHZ)

rf_pre2 = interpft(rf_pre,2580); % UPSAMPLING BY 2.5
rf_pst2 = interpft(rf_pst,2580);
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.04,'g');
subplot(2,5,6), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.04,'ls');
subplot(2,5,7), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.04,'us');
subplot(2,5,8), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.04,'lsus');
subplot(2,5,9), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.04,'a');
subplot(2,5,10), imagesc(s)

subplot(2,5,1)
title('Grad of Disp')
subplot(2,5,2)
title('Lst Sq')
subplot(2,5,3)
title('Unif Str')
subplot(2,5,4)
title('Unif Str + LS')
subplot(2,5,5)
title('Adapt Str')

subplot(2,5,6)
title('FS=50MHz, Grad of Disp')
subplot(2,5,7)
title('FS=50MHz, Lst Sq')
subplot(2,5,8)
title('FS=50MHz, Unif Str')
subplot(2,5,9)
title('FS=50MHz, Unif Str + LS')
subplot(2,5,10)
title('FS=50MHz, Adapt Str')

suptitle('From VT003/V0254/10-58-09.rf, Frames 269 vs. 369')


% FROM VT021/V0306
rfseq = RPread('08-33-19.rf');
rf_pre = double(rfseq(:,:,85));
rf_pst = double(rfseq(:,:,84));

figure(200)
[s,d,c] = EstStrn(rf_pre,rf_pst,192,128,64,0.0075,0,0.015,'g');
subplot(3, 5, 1), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,192,128,64,0.0075,0,0.015,'ls');
subplot(3, 5, 2), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,192,128,64,0.0075,0,0.015,'us');
subplot(3, 5, 3), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,192,128,64,0.0075,0,0.015,'lsus');
subplot(3, 5, 4), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,192,128,64,0.005,0,0.01,'a');
subplot(3, 5, 5), imagesc(s)

% UPSAMPLE BY 2.5 TO MAKE THE EFFECTIVE FS = 50 MHZ

rf_pre2 = interpft(rf_pre,2580);
rf_pst2 = interpft(rf_pst,2580);
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.0075,0,0.015,'g');
subplot(3, 5, 6), imagesc(s)
subplot(3, 5, 11), imagesc(medfilt2(d))
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.0075,0,0.015,'ls');
subplot(3, 5, 7), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.0075,0,0.015,'us');
subplot(3, 5, 8), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.0075,0,0.015,'lsus');
subplot(3, 5, 9), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.005,0,0.01,'a');
subplot(3, 5, 10), imagesc(s)

subplot(3, 5, 14), imagesc(medfilt2(d))
subplot(3, 5, 15), imagesc(medfilt2(d,[5 5]))

subplot(3, 5, 1)
title('Grad of Disp')
subplot(3, 5, 2)
title('Lst Sq')
subplot(3, 5, 3)
title('Unif Str')
subplot(3, 5, 4)
title('Unif Str + LS')
subplot(3, 5, 5)
title('Adapt Str')

subplot(3, 5, 6)
title('FS=50MHz, Grad of Disp')
subplot(3, 5, 7)
title('FS=50MHz, Lst Sq')
subplot(3, 5, 8)
title('FS=50MHz, Unif Str')
subplot(3, 5, 9)
title('FS=50MHz, Unif Str + LS')
subplot(3, 5, 10)
title('FS=50MHz, Adapt Str')

subplot(3, 5, 11)
title('FS=50MHz, Grad of Disp, DISP w/Med Filt')
subplot(3, 5, 14)
title('FS=50MHz, Adapt Str, DISP w/Med Filt')
subplot(3, 5, 15)
title('FS=50MHz, Adapt Str, DISP w/5x5 Med Filt')

suptitle('From VT021/V0306/08-33-19.rf, Frames 85 vs. 84')


% VT0019/V0301
rfseq = RPread('10-40-02.rf');
rf_pre = double(rfseq(:,:,85));
rf_pst = double(rfseq(:,:,84));

figure(300)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.005,0,0.01,'g');
subplot(2, 3, 1), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.005,0,0.01,'ls');
subplot(2, 3, 2), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.005,0,0.01,'a');
subplot(2, 3, 3), imagesc(s)

% UPSAMPLE BY 2.5 TO MAKE THE EFFECTIVE FS = 50 MHZ
rf_pre2 = interpft(rf_pre,2580);
rf_pst2 = interpft(rf_pst,2580);
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.005,0,0.01,'g');
subplot(2, 3, 4), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.005,0,0.01,'ls');
subplot(2, 3, 5), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.005,0,0.01,'a');
subplot(2, 3, 6), imagesc(s)

subplot(2, 3, 1)
title('Grad of Disp')
subplot(2, 3, 2)
title('Lst Sq')
subplot(2, 3, 3)
title('Adapt Str')

subplot(2, 3, 4)
title('FS=50MHz, Grad of Disp')
subplot(2, 3, 5)
title('FS=50MHz, Lst Sq')
subplot(2, 3, 6)
title('FS=50MHz, Adapt Str')
suptitle('From VT0019/V0301/10-40-02.rf, Frames 85 vs. 84')


% VT022/V0307
rfseq = RPread('13-40-57.rf');
rf_pre = double(rfseq(:,:,24));
rf_pst = double(rfseq(:,:,124));

figure(400)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.025,'g');
subplot(2, 5, 1), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.025,'us');
subplot(2, 5, 2), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.025,'ls');
subplot(2, 5, 3), imagesc(s)
[s,d,c] = EstStrn(rf_pre,rf_pst,96,64,32,0.01,0,0.025,'a');
subplot(2, 5, 5), imagesc(s)

rf_pre2 = interpft(rf_pre,2580);
rf_pst2 = interpft(rf_pst,2580);

% UPSAMPLE BY 2.5 TO MAKE THE EFFECTIVE FS = 50 MHZ

rf_pre2 = interpft(rf_pre,2580);
rf_pst2 = interpft(rf_pst,2580);
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.025,'g');
subplot(2, 5, 6), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.025,'ls');
subplot(2, 5, 7), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.025,'us');
subplot(2, 5, 8), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.025,'lsus');
subplot(2, 5, 9), imagesc(s)
[s,d,c] = EstStrn(rf_pre2,rf_pst2,192,128,64,0.01,0,0.025,'a');
subplot(2, 5, 10), imagesc(s)

subplot(2, 5, 1)
title('Grad of Disp')
subplot(2, 5, 2)
title('Lst Sq')
subplot(2, 5, 3)
title('Unif Str')
subplot(2, 5, 5)
title('Adapt Str')

subplot(2, 5, 6)
title('FS=50MHz, Grad of Disp')
subplot(2, 5, 7)
title('FS=50MHz, Lst Sq')
subplot(2, 5, 8)
title('FS=50MHz, Unif Str')
subplot(2, 5, 9)
title('FS=50MHz, Unif Str + LS')
subplot(2, 5, 10)
title('FS=50MHz, Adapt Str')

suptitle('From VT022/V0307/13-40-57.rf, Frames 24 vs. 124')
