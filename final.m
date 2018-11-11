
%   ESSE AQUI � O DE VERDADE VERDADEIRA
%   NICOLAS EYMAEL
%   RODRIGO RICHTER
%--------------------------------------------------------

clear all;
close all;
clc;

% quantidade de bits amostrados
nbits = 8;

% vetor binario com n bits
%data = randi([0 1], nbits, 1);
data = [0 0 0 1 1 0 1 1]'; % s� pra ajudar os testes mesmo

% modula��o a ser utilizada 4-QAM, 16-QAM ou 64-QAM
M = 4;

%------------ CODIFICA��O: ------------%
% Turbo Coding de acordo com o livro "Understanding LTE with MATLAB"
% por algum motivo ele insere 12 bits extras no final

trellis = poly2trellis(4,[13 15],13);
indices= randperm(nbits);

TurboEncoder = comm.TurboEncoder('TrellisStructure',trellis,'InterleaverIndices',indices);

encoded = TurboEncoder.step(data);


%------------ MODULA��O: ------------%

% quebra o vetor em varias linhas
% cada linha tem log2(M) bits (o necessario para a modula�ao M-QAM)
binary_matrixT = reshape(encoded,log2(M),[])';

% converte cada linha de bits em um numero decimal
decimal_valuesT = bi2de(binary_matrixT, 'left-msb');

% executa a modula��o M-QAM
mod = qammod(decimal_valuesT, M);


%------------ TRANSMISS�O NO CANAL: ------------%
% inserir o ruido


%------------ DEMODULA��O: ------------%

demod = qamdemod(mod, M);

decimal_valuesR = de2bi(demod, 'left-msb');

binary_matrixR = reshape(decimal_valuesR',1,[]);

%%%%%%%%
%disp(data);
%disp(encoded);
disp(binary_matrixT);
disp(decimal_valuesT);
%disp(mod);
%disp(demod);
disp(decimal_valuesR);
disp(binary_matrixR');


%------------ DECODIFICA��O: ------------%

%TurboDecoder = comm.TurboDecoder('TrellisStructure',trellis,'InterleaverIndices',indices,'NumIterations',6);

%decoded = TurboDecoder.step(encoded);




