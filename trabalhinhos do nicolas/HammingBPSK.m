
% NICOLAS EYMAEL DA SILVA
% 262506

% OBS PRO NAZAR: o programa ta beeeem lento, de verdade, tipo uns 500 mil
% bits demora uns 15 minutos pra simular

%-------------------------------------------------------------
% VARIAVEIS UTILIZADAS NO DECORRER DO CÓDIGO E SUAS DIMENSÕES
% 1 - bits_transmissor_vector            1 x (num_b / n * k)
% 2 - bits_transmissor_matrix            (num_b / n) x k
% 3 - bits_transmissor_matrix_coded      (num_b / n) x n   
% 4 - bits_transmissor_vector_coded      1 x num_b
% 5 - bits_transmissor_complex           1 x num_b
% 6 - bits_receptor_vector               1 x num_b
% 7 - bits_receptor_matrix               (num_b / n) x n
% 8 - bits_receptor_matrix_correct       (num_b / n) x n
% 9 - bits_receptor_vector_correct       1 x num_b
% 10 - bits_receptor_matrix_decoded      (num_b / n) x k
% 11 - bits_receptor_vector_decoded      1 x (num_b / n * k) 

%-------------------------------------------------------------
clear all;
close all;
clc;

% ALGUMAS VARIÁVEIS DE SETUP
k = 4; %% bits da mensagem
n = 7; %% bits totais (mensagem + paridade)

num_b = 1000; %quantidade de bits TOTAIS simulados
num_b = round(num_b/n)*n; %% agora a quantidade de bits é multipla de n
num_bitsMsg = num_b / n * k;  %% quantidade de bits de mensagem (sem contar paridade)

%bits = complex(2*randi(2, 1, num_b)-3, 0); %vetor complexo com parte real {-1, 1} e parte imaginária = 0

bits_transmissor_vector = randi([0,1],1,num_bitsMsg); %% 'num_b' bits gerados aleatoriamente 0 ou 1
%bits_transmissor_vector = ones(1, num_bitsMsg);
%bits_transmissor_vector = [1 0 1 0];
rows = num_bitsMsg/k; % quantas linhas tem a matriz que veio do vetor
bits_transmissor_matrix = reshape(bits_transmissor_vector.', [k,rows]).'; %% agora o vetor 1 x NUMBMSG -> matriz NUMBMSG/K x K onde cada linha é uma mensagem de tamanho K
bits_transmissor_matrix_coded = zeros(rows, n); %inicializa a matriz que vai ser preenchida no hamming

% pre-alocaçoes que serao usadas futuramente
bits_transmissor_complex = zeros(1,num_b);
bits_receptor_vector = zeros(1,num_b);
bits_receptor_matrix_decoded = zeros(rows,k);
%----------------------------------------------------------------------------------------------------------
% IT'S HAMMING TIME (CODIFICA COM HAMMING)
for i = 1:rows %% preenche os D's do hamming
    indexK = 1;
    for indexN = 1:n 
        if( floor(log2(indexN)) ~= log2(indexN) ) %% "pula" os bits de paridade (potencias de 2) ft: Dorneles
            bits_transmissor_matrix_coded(i,indexN) = bits_transmissor_matrix(i,indexK);
            indexK = indexK + 1;
        end
    end
end

for i = 1:rows %% preenche os P's do hamming
    %bits_p = bits_transmissor_matrix_coded(i, :); % coisas do PARFOR
    
    for p = 1:n-k
        indexP = 2^(p-1); 
        result = 0;
        
        for indexN = 1:n 
            test = bitget(floor(indexN/indexP), 1);
            if(test == 1)
                result = xor(bits_transmissor_matrix_coded(i,indexN), result);
                %result = xor(bits_p(indexN), result); %coisas do PARFOR
            end
        end
        
       % bits_p(indexP) = result; % coisas do PARFOR
        bits_transmissor_matrix_coded(i, indexP) = result;
    end
    
    %bits_transmissor_matrix_coded(i, :) = bits_p; % coisas do PARFOR
end



% Nesse ponto, os bits estão codificados e dispostos em uma matriz com
% varias linhas, hora de transformar em um VETOR de bits
bits_transmissor_vector_coded = reshape(bits_transmissor_matrix_coded.', 1, []);


%--------------------------------------------------------------------------------------------------
% mapeia os bits para simbolos complexos


for i = 1:num_b
    if(bits_transmissor_vector_coded(i) == 0)
        bits_transmissor_complex(i) = complex(-1, 0);
    else
        bits_transmissor_complex(i) = complex(1, 0);
    end
end


% coisas de ruido
Eb_N0_dB = 0:1:10; %faixa de Eb/N0 a ser simulada (em dB)
Eb_N0_lin = 10 .^ (Eb_N0_dB/10); %Eb/N0 linearizado
Eb = 1; %energia por símbolo é constante (1^2 = (-1)^2 = 1), 1 bit por símbolo (caso geral: energia média por símbolo / bits por símbolo)
NP = (Eb / (k/n)) ./ (Eb_N0_lin); %potência do ruído LEVANDO EM CONTA A RAZÃO DO CODIGO
NA = sqrt(NP); %amplitude é a raiz quadrada da potência



% ADICIONA O RUIDO AO SINAL E CALCULA O BIT ERROR RATE 
ber = zeros(size(Eb_N0_lin)); %pre-allocates BER vector
    
for j = 1:length(Eb_N0_lin)
    ruido = NA(j)*complex(randn(1, num_b), randn(1, num_b))*sqrt(0.5); %vetor de ruído com desvio padrão igual à amplitude do ruído
    sinal = bits_transmissor_complex + ruido; % canal AWGN
    demod = sign(real(sinal)); % sinal da parte real determina o valor do bit
    
    % demod é um vetor com num_b elementos indicando -1 ou 1 após passar
    % pelo canal AWGN
    %-----------------------------------------------------------------------------
    % HORA DE CORRIGIR OS BITS CODIFICADOS
    
    % transforma os numeros complexos em bits
    for i = 1:num_b
        if(demod(i) > 0)
            bits_receptor_vector(i) = 1;
        else
            bits_receptor_vector(i) = 0;
        end
    end
    
    % transforma em uma matriz em que cada linha é um bloco de hamming
    bits_receptor_matrix = reshape(bits_receptor_vector.', [n,rows]).'; 
    bits_receptor_matrix_correct = bits_receptor_matrix; % vai ser usado logo logo
    
    
    % passa por todas as linhas da matriz e corrige possiveis erros
    for i = 1:rows 
    %error_vector = zeros(1,n-k); % coisas do PARFOR
    %bits_correction = bits_receptor_matrix_correct(i, :); % coisas do PARFOR
    
        for p = 1:n-k       % detecta erro em algum bit e corrige
            indexP = 2^(p-1); 
            result = 0;

            for indexN = 1:n 
                test = bitget(floor(indexN/indexP), 1);
                if(test == 1)
                    result = xor(bits_receptor_matrix(i,indexN), result);
                end
            end

            error_vector(p) = result; % vetor binario indicando QUAL O BIT que está incorreto

        end

        error_index = bi2de(error_vector);

        if(error_index > 0)     % houve um erro, entao precisa flipar o bit errado
            if(bits_receptor_matrix(i, error_index) == 1)
                %bits_correction(error_index) = 0; coisas do PARFOR
                bits_receptor_matrix_correct(i, error_index) = 0;
            else
                %bits_correction(error_index) = 1; coisas do PARFOR
                bits_receptor_matrix_correct(i, error_index) = 1;
            end
        end

        %bits_receptor_matrix_correct(i, :) = bits_correction; % coisas do PARFOR
    end
    
    % transforma a matriz de volta em um VETOR (corrigido contra possiveis
    % erros do ruido)
    % É ESSE VETOR QUE É USADO NO PLOT DO BER
    bits_receptor_vector_correct = reshape(bits_receptor_matrix_correct.', 1, []);
    
    % decodifica hamming (nao sei porque, eu nem uso)
    for i = 1:rows      %% faz a decodificaçao n -> k
        %bits_d = zeros(1,k); % coisas do PARFOR

        indexK = 1;
        for indexN = 1:n 
            if( floor(log2(indexN)) ~= log2(indexN) ) %% "pula" os bits de paridade (potencias de 2) ft: Dorneles
                %bits_d(indexK) = bits_receptor_matrix_correct(i,indexN); coisas do PARFOR
                bits_receptor_matrix_decoded(i,indexK) = bits_receptor_matrix_correct(i,indexN);
                indexK = indexK + 1;
            end
        end

        %bits_receptor_matrix_decoded(i,:) = bits_d; coisas do PARFOR
    end
    
    % agora é um vetor, se tudo deu certo entao: 
    % bits_receptor_vector_decoded == bits_transmissor_vector
    bits_receptor_vector_decoded = reshape(bits_receptor_matrix_decoded.', 1, []);
    
    
    ber(j) = sum(bits_transmissor_vector_coded ~= bits_receptor_vector_correct) / num_b; % conta erros e calcula o BER
end


%-------------------------------------------------------------------------------------------------------
% PLOTS E AFINS

ber_theoretical = 0.5*erfc(sqrt(Eb_N0_lin)); %BER teórico

semilogy(Eb_N0_dB, ber, Eb_N0_dB, ber_theoretical, 'LineWidth', 2);
grid on;
title('Taxa de erros para BPSK');
legend('Medido', 'Teórico');
ylabel('BER');
xlabel('Eb/N0 (dB)');

oi = ber*num_b;
disp(oi.');