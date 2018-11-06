
% NICOLAS EYMAEL DA SILVA
% 262506

%-------------------------------------------------------------
                % DADOS QUE COPIEI DA ESPECIFICAÇÃO %

clear;
close all;

%Constantes definidas pelo usuário
Fs=100; %frequência de amostragem
Tb=1; %tempo de um bit
Nb=8; %número de bits
Fc = 10; %frequência da portadora

%Constantes derivadas
Ts=1/Fs; %período de amostragem
t=0:Ts:(Nb*Tb-Ts); %vetor do tempo
L = length(t); %comprimento do vetor tempo
NFFT = 2^nextpow2(L); %número de pontos a serem utilizados na FFT
f = Fs/2*linspace(-1,1,NFFT); %vetor frequência (para sinais no domínio frequência)


%-------------------------------------------------------------
                % TRANSMISSOR %

% gera um vetor com 8 bits aleatorios               
bits = randi([0,1],1,Nb);
disp(bits);

A = 1;


% percorre o vetor de bits e decodifica os simbolos (1 simb = 2 bits)
j = 1;
for(i=1:Nb/2)
    if(bits(j)==0 && bits(j+1)==0) fase(i)=45*pi/180; end
    if(bits(j)==0 && bits(j+1)==1) fase(i)=135*pi/180; end
    if(bits(j)==1 && bits(j+1)==1) fase(i)=225*pi/180; end
    if(bits(j)==1 && bits(j+1)==0) fase(i)=315*pi/180; end
    
    % cria um vetor com as fases de cada simbolo
    I(i) = A*cos(fase(i));
    Q(i) = A*sin(fase(i));
    
    j = j + 2;
end

% "fase" é um vetor com Nb/2 elementos
disp(fase);

% replica os elementos dos vetores pra "transformar" em uma onda (no tempo)
faseOnda = reshape(repmat(fase, 2*Tb/Ts, 1), [1,L]);
I_transmissor = reshape(repmat(I, 2*Tb/Ts, 1), [1,L]);
Q_transmissor = reshape(repmat(Q, 2*Tb/Ts, 1), [1,L]);


% as mesmas ondas, mas no dominio frequencia (usando FFT)
I_transmissorF = fftshift(fft(I_transmissor, NFFT)/L);
Q_transmissorF = fftshift(fft(Q_transmissor, NFFT)/L);


% modula I e Q em uma unica onda a ser transmitida
sinal = I_transmissor .* cos(2*pi*Fc*t) - Q_transmissor .* sin(2*pi*Fc*t);

% a mesma onda, mas no dominio frequencia (usando FFT)
sinalF = fftshift(fft(sinal, NFFT)/L);


%-------------------------------------------------------------
                % RECEPTOR %

% demodula o sinal recebido em duas ondas (I e Q)
I_receptor = sinal .* cos(2*pi*Fc*t);
Q_receptor = sinal .* (-sin(2*pi*Fc*t));

% as mesmas ondas, mas no dominio frequencia (usando FFT)
I_receptorF = fftshift(fft(I_receptor, NFFT)/L);
Q_receptorF = fftshift(fft(Q_receptor, NFFT)/L);


% para fazer a filtragem, precisa "cortar" os sinais na faixa de frequencia
% desejada [-Fc, Fc], entao eu fiz um vetor com 0s onde eu quero cortar e 1s
% onde eu quero manter. É necessario fazer um mapeamento da frequencia para
% os indices do vetor frequencia.
% no mapeamento, usei a formula de normalizaçao com minimos e maximos
vMin = round(1 + (-Fc - f(1))/(f(NFFT) - f(1))*(NFFT - 1));
vMax = round(1 + (+Fc - f(1))/(f(NFFT) - f(1))*(NFFT - 1));
vecAux = zeros(1,NFFT);
vecAux([vMin:vMax]) = 1;

% multiplica ponto a ponto o sinal recebido pelo "vetor filtro"
I_filtradoF = I_receptorF .* vecAux;
Q_filtradoF = Q_receptorF .* vecAux;


% agora só resta voltar para o dominio tempo usando FFT inverso
I_filtrado = ifft(ifftshift(I_filtradoF)*L);
Q_filtrado = ifft(ifftshift(Q_filtradoF)*L);

% como NFFT > L, é preciso cortar o "lixo" que apareceu no final
I_filtrado = I_filtrado(1:L);
Q_filtrado = Q_filtrado(1:L);


%-------------------------------------------------------------
                % PLOTS %

% plots no dominio tempo
figure('Name', 'Tempo');
subplot(8,1,1); plot(t, faseOnda); ylabel('FASE rad'); xlabel('t');
subplot(8,1,2); plot(t, I_transmissor); ylabel('I(t) tra'); xlabel('t');
subplot(8,1,3); plot(t, Q_transmissor); ylabel('Q(t) tra'); xlabel('t');
subplot(8,1,4); plot(t, sinal); ylabel('SINAL(t)'); xlabel('t');
subplot(8,1,5); plot(t, I_receptor); ylabel('I(t) rec'); xlabel('t');
subplot(8,1,6); plot(t, Q_receptor); ylabel('Q(t) rec'); xlabel('t');
subplot(8,1,7); plot(t, real(I_filtrado)); ylabel('I(t) filt'); xlabel('t');
subplot(8,1,8); plot(t, real(Q_filtrado)); ylabel('Q(t) filt'); xlabel('t');

% plots no dominio frequencia
figure('Name', 'Frequencia');
subplot(8,1,1); plot(t, faseOnda); ylabel('FASE rad'); xlabel('t');
subplot(8,1,2); plot(f, real(I_transmissorF)); ylabel('I(f) tra'); xlabel('f'); ylim([-0.05 0.2]);
subplot(8,1,3); plot(f, real(Q_transmissorF)); ylabel('Q(f) tra'); xlabel('f'); ylim([-0.05 0.2]);
subplot(8,1,4); plot(f, real(sinalF)); ylabel('SINAL(f)'); xlabel('f'); ylim([-0.05 0.2]);
subplot(8,1,5); plot(f, real(I_receptorF)); ylabel('I(f) rec'); xlabel('f'); ylim([-0.05 0.2]);
subplot(8,1,6); plot(f, real(Q_receptorF)); ylabel('Q(f) rec'); xlabel('f'); ylim([-0.05 0.2]);
subplot(8,1,7); plot(f, real(I_filtradoF)); ylabel('I(f) filt'); xlabel('f'); ylim([-0.05 0.2]);
subplot(8,1,8); plot(f, real(Q_filtradoF)); ylabel('Q(f) filt'); xlabel('f'); ylim([-0.05 0.2]);


