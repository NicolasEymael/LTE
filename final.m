
%   ESSE AQUI É O DE VERDADE VERDADEIRA
%   NICOLAS EYMAEL
%   RODRIGO RICHTER
%--------------------------------------------------------------

clear all;
close all;
clc;

% modulação a ser utilizada
% opçoes: 4-QAM, 16-QAM ou 64-QAM
M = 4;

% largura de banda, utilizada na hora de fazer FFT no OFDM
% opçoes: 1.4, 3, 5, 10, 15 ou 20
BW = 3;

% "quantidade de bits amostrados"
nbits = 350;

% dependendo da modulação e da quantidade de bits, pode dar erro
% é preciso adaptar a quantidade de bits para a modulação escolhida
while( mod(nbits*3+12, log2(M)) ~= 0 )
    nbits = nbits + 1;
end

% vetor binario com n bits
data = randi([0 1], nbits, 1);
%data = [0 0 0 1 1 0 1 1]'; % só pra ajudar os testes mesmo

% signal to noise ratio
snr = 5;



%--------------- CODIFICAÇÃO: ---------------------%
% Turbo Coding de acordo com o livro "Understanding LTE with MATLAB"
% por algum motivo ele insere 12 bits extras no final

trellis = poly2trellis(4,[13 15],13);
indices= randperm(nbits);

TurboEncoder = comm.TurboEncoder('TrellisStructure',trellis,'InterleaverIndices',indices);

sig_encoded = TurboEncoder.step(data);


%--------------- MODULAÇÃO: ---------------------%

% quebra o vetor em varias linhas
% cada linha tem log2(M) bits (o necessario para a modulaçao M-QAM)
binary_matrixT = reshape(sig_encoded,log2(M),[])';

% converte cada linha de bits em um numero decimal
decimal_valuesT = bi2de(binary_matrixT, 'left-msb');

% executa a modulação M-QAM
sig_mod = qammod(decimal_valuesT, M);


%--------------- OFDM: ---------------------%

% pequenas alteraçoes para suportar uma quantidade arbitraria de bits
% relação bandwidth <-> NFFT e subcarriers
switch(BW)
    case 1.4
        subcarriers = 6 * 12;
        NFFT = 128;
    case 3
        subcarriers = 15 * 12;
        NFFT = 256;
    case 5
        subcarriers = 25 * 12;
        NFFT = 512;
    case 10
        subcarriers = 50 * 12;
        NFFT = 1024;
    case 15
        subcarriers = 75 * 12;
        NFFT = 1536;
    case 20
        subcarriers = 100 * 12;
        NFFT = 2048;
    otherwise
        disp('erro no switch');
end

iter_ifft = floor(length(sig_mod) / subcarriers);
resto = mod(length(sig_mod), subcarriers);

recv_stream = [];
for k = 1:iter_ifft
    %disp('entrei no FOR');
    % loop que faz tudo IFFT, PREFIXO, RUIDO, TIRA PREFIXO, FFT   
    
    % reparte o sig_mod em 'subcarriers*itter_ifft' linhas com 'subcarriers' elementos
    mod_matrix = reshape(sig_mod(1:subcarriers*iter_ifft),subcarriers,[]);
    % faz o ifft naquela linha
    ifft_sig = ifft(mod_matrix(:,k), NFFT);
    % prefixo ciclico tem 7% de overhead (vi no livro)
    prefix = floor(7/100*NFFT);

    % extensao ciclica %
    sig_ext = zeros(NFFT+prefix, 1);
    sig_ext(1:prefix) = ifft_sig(NFFT-prefix+1:NFFT);
    for i=1:NFFT
        sig_ext(i+prefix) = ifft_sig(i);
    end



    %--------------- TRANSMISSÃO NO CANAL: ---------------------%
    % inserir o ruido
    
    sig_ofdm=awgn(sig_ext,snr,'measured'); % Adding white Gaussian Noise
    %sig_ofdm = sig_ext;




    %--------------- DE-OFDM: ---------------------%
    % remove extensao ciclica %
    for i=1:NFFT
        sig_rext(i)=sig_ofdm(i+prefix);
    end

    recv_sig = fft(sig_rext, NFFT);
    % arruma o sinal pra estar no formato da demodulação
    recv_sig = reshape(recv_sig,NFFT,1);
    recv_sig = recv_sig(1:subcarriers,:);
    %disp(length(recv_sig));

 
    % a cada iteraçao, vai adicionando no recv_stream o sinal a ser
    % demodulado
    recv_stream = [recv_stream recv_sig.'];
end
    
    if(resto>0) % faz tuuuuuuuuuuuuuudo denovo
        %disp('entrei no IF');
        % resto que sobrou do FOR
        mod_resto = sig_mod(length(sig_mod)-resto+1:length(sig_mod));
        %mod_resto = reshape(sig_mod(length(sig_mod)-resto+1:length(sig_mod)),subcarriers,[])';
        % OFDM %
        ifft_sig = ifft(mod_resto, NFFT);
        prefix = floor(7/100*NFFT);
        sig_ext = zeros(NFFT+prefix, 1);
        sig_ext(1:prefix) = ifft_sig(NFFT-prefix+1:NFFT);
        for i=1:NFFT
            sig_ext(i+prefix) = ifft_sig(i);
        end
        % RUIDO %
        sig_ofdm=awgn(sig_ext,snr,'measured'); % Adding white Gaussian Noise
        %sig_ofdm = sig_ext;
        % DE-OFDM %
        for i=1:NFFT
            sig_rext(i)=sig_ofdm(i+prefix);
        end
        recv_sig = fft(sig_rext, NFFT);
        recv_sig = reshape(recv_sig,NFFT,1);
        recv_sig = recv_sig(1:resto,:);


        % agora recv_stream está pronto
        recv_stream = [recv_stream recv_sig.'];
    end
%--------------- DEMODULAÇÃO: ---------------------%

% demod está no mesmo formato do decimal_valuesT
demod = qamdemod(recv_stream, M);

binary_matrixR = de2bi(demod, 'left-msb');

% binary_vectorR DEVERIA SER IGUAL AO encoded' (se ignorar o ruido)
binary_vectorR = reshape(binary_matrixR',1,[]);



%--------------- DECODIFICAÇÃO: ---------------------%

% as variaveis para o codigo turbo ja foram inicializadas na CODIFICAÇÃO
% quanto mais iterações, melhor a performance (valor arbitrario: 6)
TurboDecoder = comm.TurboDecoder('TrellisStructure',trellis,'InterleaverIndices',indices,'NumIterations',12);

decoded = TurboDecoder.step(binary_vectorR');


%--------------- PLOTS, DISPS E AFINS: ---------------------%

%scatterplot(mod);
%scatterplot(recv_sig);

disp('diferença data-decoded'); disp(sum(data~=decoded));
disp('diferença encoded-vectorR'); disp(sum(sig_encoded~=binary_vectorR'));
disp('diferença decimal-demod'); disp(sum(decimal_valuesT~=demod'));


%disp('data'); disp(data');
%disp('sig_encoded'); disp(sig_encoded);
%disp('binary_matrixT'); disp(binary_matrixT);
%disp('decimal_valuesT'); disp(decimal_valuesT);
%disp('sig_mod'); disp(sig_mod);
%disp('demod'); disp(demod);
%disp('binary_matrixR'); disp(binary_matrixR);
%disp('binary_vectorR'); disp(binary_vectorR');
%disp('decoded'); disp(decoded');






