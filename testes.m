
%------------ MODULAÇÃO: ------------%

M = 4;  % 4-QAM or QPSK
M = 16; % 16-QAM
M = 64; % 64-QAM

bitsIN = randi([0,M-1],1,12);   % IN -> vetor de inteiros, cada elemento é formado por log2(M) bits

bitOUT = qammod(bitsIN, M);     % OUT -> vetor complexo, cada elemento é um ponto na constelação QAM


%------------ CODIFICAÇÃO: ------------%

%turboIN = randi([0,1],1,12);

%turboOUT = lteTurboEncode(turboIN); % matlab fdp só implementou o turbo
%encoding em 2014 agora to triste

%------------ OFDM SENDER: ------------%
ifft_sig=ifft(bitOUT',64);

snr = 2;
ofdm_sig=awgn(ifft_sig,snr,'measured'); % Adding white Gaussian Noise


%------------ OFDM RECEIVER: ------------%
recv_sig = fft(ofdm_sig,64);


%------------ DEMODULAÇÃO: ------------%
dem_data= qamdemod(recv_sig,M);



