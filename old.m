
%   ESSE AQUI ? O DE VERDADE VERDADEIRA
%   NICOLAS EYMAEL
%   RODRIGO RICHTER
%--------------------------------------------------------------

clear all;
close all;
clc;

% quantidade de bits amostrados
nbits = 8;

% vetor binario com n bits
%data = randi([0 1], nbits, 1);
data = [0 0 0 1 1 0 1 1]'; % s? pra ajudar os testes mesmo

% modula??o a ser utilizada 4-QAM, 16-QAM ou 64-QAM
M = 4;

%--------------- CODIFICA??O: ---------------------%
% Turbo Coding de acordo com o livro "Understanding LTE with MATLAB"
% por algum motivo ele insere 12 bits extras no final

trellis = poly2trellis(4,[13 15],13);
indices= randperm(nbits);

TurboEncoder = comm.TurboEncoder('TrellisStructure',trellis,'InterleaverIndices',indices);

encoded = TurboEncoder.step(data);


%--------------- MODULA??O: ---------------------%

% quebra o vetor em varias linhas
% cada linha tem log2(M) bits (o necessario para a modula?ao M-QAM)
binary_matrixT = reshape(encoded,log2(M),[])';

% converte cada linha de bits em um numero decimal
decimal_valuesT = bi2de(binary_matrixT, 'left-msb');

% executa a modula??o M-QAM
mod = qammod(decimal_valuesT, M);


%--------------- OFDM: ---------------------%
% provavelmente o OFDM vai ficar aqui
% mod ? um vetor coluna com numeros complexos
ifft_sig=ifft(mod,64);

% extensao ciclica %
sig_ext=zeros(80,1);
sig_ext(1:16)=ifft_sig(49:64);
for i=1:64
    sig_ext(i+16)=ifft_sig(i);
end



%--------------- TRANSMISS?O NO CANAL: ---------------------%
% inserir o ruido
snr = 100;
sig_ofdm=awgn(sig_ext,snr,'measured'); % Adding white Gaussian Noise


%--------------- DE-OFDM: ---------------------%
% remove extensao ciclica %
for i=1:64
	sig_rext(i)=sig_ofdm(i+16);
end

recv_sig = fft(sig_rext,64);
% arruma o sinal pra estar no formato da demodula??o
recv_sig = reshape(recv_sig,64,1);
recv_sig=recv_sig(1:18,:);



%--------------- DEMODULA??O: ---------------------%

% demod est? no mesmo formato do decimal_valuesT
demod = qamdemod(recv_sig, M);

binary_matrixR = de2bi(demod, 'left-msb');

% binary_vectorR DEVERIA SER IGUAL AO encoded' (se ignorar o ruido)
binary_vectorR = reshape(binary_matrixR',1,[]);



%--------------- DECODIFICA??O: ---------------------%

% as variaveis para o codigo turbo ja foram inicializadas na CODIFICA??O
% quanto mais itera??es, melhor a performance (valor arbitrario: 6)
TurboDecoder = comm.TurboDecoder('TrellisStructure',trellis,'InterleaverIndices',indices,'NumIterations',6);

decoded = TurboDecoder.step(binary_vectorR');


%--------------- PLOTS, DISPS E AFINS: ---------------------%

%disp(data);
%disp(encoded);
%disp(binary_matrixT);
%disp(decimal_valuesT);
%disp(mod);
%disp(demod);
%disp(binary_matrixR);
%disp(binary_vectorR');
%disp(decoded);
