% NICOLAS EYMAEL DA SILVA
% 262506

%-------------------------------------------------------------

clear;
close all;

% SEI LÁ TEM NO T2 E PARECE IMPORTANTE

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
% COISAS NOVAS


% gera vetores com 8 bits aleatorios de 1 ou -1               
user1_bits = randi([0,1],1,Nb);
user2_bits = randi([0,1],1,Nb);
user3_bits = randi([0,1],1,Nb);
user4_bits = randi([0,1],1,Nb);
for(i=1:Nb)
    if(user1_bits(i) == 0)  user1_bits(i) = -1; end
    if(user2_bits(i) == 0)  user2_bits(i) = -1; end
    if(user3_bits(i) == 0)  user3_bits(i) = -1; end
    if(user4_bits(i) == 0)  user4_bits(i) = -1; end
end


% gera a matriz de walsh-hadamard e as sequencias de espalhamento
seqMat = hadamard(4);
seq1 = seqMat(1,:); 
seq2 = seqMat(2,:); 
seq3 = seqMat(3,:); 
seq4 = seqMat(4,:);


% espalha os bits na sequencia (ou a sequencia nos bits sei la)
user1_spread = reshape(repmat(user1_bits(1),4,1), [1,4]) .* seq1; 
user2_spread = reshape(repmat(user2_bits(1),4,1), [1,4]) .* seq2;
user3_spread = reshape(repmat(user3_bits(1),4,1), [1,4]) .* seq3;
user4_spread = reshape(repmat(user4_bits(1),4,1), [1,4]) .* seq4;
for i=2:Nb
    user1_spread = cat(2,user1_spread, reshape(repmat(user1_bits(i),4,1), [1,4]) .* seq1); 
    user2_spread = cat(2,user2_spread, reshape(repmat(user2_bits(i),4,1), [1,4]) .* seq2);
    user3_spread = cat(2,user3_spread, reshape(repmat(user3_bits(i),4,1), [1,4]) .* seq3);
    user4_spread = cat(2,user4_spread, reshape(repmat(user4_bits(i),4,1), [1,4]) .* seq4);
end


% sinal no meio é a soma dos espalhamentos de cada usuario
sinalR = user1_spread + user2_spread + user3_spread + user4_spread;


% itera por todos os bits transmitidos (8), o spread de cada usuario é dado por R*Seq
% com os spreads, só precisa somar os chips e checar o sinal da soma para obter o bit recebido 
for i=1:Nb
    received1_spread(4*i-3:4*i) = sinalR(4*i-3:4*i) .* seq1;
    if(sum(received1_spread(4*i-3:4*i)) > 0) 
        received1_bits(i) = 1;
    else
        received1_bits(i) = -1;
    end
    
    received2_spread(4*i-3:4*i) = sinalR(4*i-3:4*i) .* seq2;
    if(sum(received2_spread(4*i-3:4*i)) > 0) 
        received2_bits(i) = 1;
    else
        received2_bits(i) = -1;
    end
    
    received3_spread(4*i-3:4*i) = sinalR(4*i-3:4*i) .* seq3;
    if(sum(received3_spread(4*i-3:4*i)) > 0) 
        received3_bits(i) = 1;
    else
        received3_bits(i) = -1;
    end
    
    received4_spread(4*i-3:4*i) = sinalR(4*i-3:4*i) .* seq4;
    if(sum(received4_spread(4*i-3:4*i)) > 0) 
        received4_bits(i) = 1;
    else
        received4_bits(i) = -1;
    end
end


% replica os elementos dos vetores pra "transformar" em uma onda (no tempo) e conseguir plotar
% o Tb/Ts é porque o vetor original é de 8 elementos
user1_bits_wave = reshape(repmat(user1_bits, Tb/Ts, 1), [1,L]);
user2_bits_wave = reshape(repmat(user2_bits, Tb/Ts, 1), [1,L]);
user3_bits_wave = reshape(repmat(user3_bits, Tb/Ts, 1), [1,L]);
user4_bits_wave = reshape(repmat(user4_bits, Tb/Ts, 1), [1,L]);
% o Tb/Ts/4 é porque o vetor original é de 32 elementos
user1_spread_wave = reshape(repmat(user1_spread, Tb/Ts/4, 1), [1,L]);
user2_spread_wave = reshape(repmat(user2_spread, Tb/Ts/4, 1), [1,L]);
user3_spread_wave = reshape(repmat(user3_spread, Tb/Ts/4, 1), [1,L]);
user4_spread_wave = reshape(repmat(user4_spread, Tb/Ts/4, 1), [1,L]);
% o Tb/Ts é porque o vetor original é de 8 elementos
received1_bits_wave = reshape(repmat(received1_bits, Tb/Ts, 1), [1,L]);
received2_bits_wave = reshape(repmat(received2_bits, Tb/Ts, 1), [1,L]);
received3_bits_wave = reshape(repmat(received3_bits, Tb/Ts, 1), [1,L]);
received4_bits_wave = reshape(repmat(received4_bits, Tb/Ts, 1), [1,L]);



% as mesmas ondas, mas no dominio frequencia (usando FFT) pro item 3
user1_bits_freq = fftshift(fft(user1_bits_wave, NFFT)/L);
user2_bits_freq = fftshift(fft(user2_bits_wave, NFFT)/L);
user3_bits_freq = fftshift(fft(user3_bits_wave, NFFT)/L);
user4_bits_freq = fftshift(fft(user4_bits_wave, NFFT)/L);

user1_spread_freq = fftshift(fft(user1_spread_wave, NFFT)/L);
user2_spread_freq = fftshift(fft(user2_spread_wave, NFFT)/L);
user3_spread_freq = fftshift(fft(user3_spread_wave, NFFT)/L);
user4_spread_freq = fftshift(fft(user4_spread_wave, NFFT)/L);


%-------------------------------------------------------------
                % PLOTS %
                
                
figure('Name', 'Item 1: Bits Originais');
subplot(4,1,1); plot(t, user1_bits_wave); ylabel('user 1'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,1,2); plot(t, user2_bits_wave); ylabel('user 2'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,1,3); plot(t, user3_bits_wave); ylabel('user 3'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,1,4); plot(t, user4_bits_wave); ylabel('user 4'); xlabel('t'); ylim([-1.5 1.5]);

figure('Name', 'Item 2: Chips Espalhados');
subplot(4,1,1); plot(t, user1_spread_wave); ylabel('user 1'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,1,2); plot(t, user2_spread_wave); ylabel('user 2'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,1,3); plot(t, user3_spread_wave); ylabel('user 3'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,1,4); plot(t, user4_spread_wave); ylabel('user 4'); xlabel('t'); ylim([-1.5 1.5]);

figure('Name', 'Item 3: Tempo e Frequência dos Bits Originais');
subplot(4,2,1); plot(t, user1_bits_wave); ylabel('user 1 (t)'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,2,2); plot(f, real(user1_bits_freq)); ylabel('user 1 (f)'); xlabel('f'); ylim([-0.05 0.2]);
subplot(4,2,3); plot(t, user2_bits_wave); ylabel('user 2 (t)'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,2,4); plot(f, real(user2_bits_freq)); ylabel('user 2 (f)'); xlabel('f'); ylim([-0.05 0.2]);
subplot(4,2,5); plot(t, user3_bits_wave); ylabel('user 3 (t)'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,2,6); plot(f, real(user3_bits_freq)); ylabel('user 3 (f)'); xlabel('f'); ylim([-0.05 0.2]);
subplot(4,2,7); plot(t, user4_bits_wave); ylabel('user 4 (t)'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,2,8); plot(f, real(user4_bits_freq)); ylabel('user 4 (f)'); xlabel('f'); ylim([-0.05 0.2]);

figure('Name', 'Item 3: Tempo e Frequência dos Chips Espalhados');
subplot(4,2,1); plot(t, user1_spread_wave); ylabel('user 1 (t)'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,2,2); plot(f, real(user1_spread_freq)); ylabel('user 1 (f)'); xlabel('f'); ylim([-0.05 0.2]);
subplot(4,2,3); plot(t, user2_spread_wave); ylabel('user 2 (t)'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,2,4); plot(f, real(user2_spread_freq)); ylabel('user 2 (f)'); xlabel('f'); ylim([-0.05 0.2]);
subplot(4,2,5); plot(t, user3_spread_wave); ylabel('user 3 (t)'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,2,6); plot(f, real(user3_spread_freq)); ylabel('user 3 (f)'); xlabel('f'); ylim([-0.05 0.2]);
subplot(4,2,7); plot(t, user4_spread_wave); ylabel('user 4 (t)'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,2,8); plot(f, real(user4_spread_freq)); ylabel('user 4 (f)'); xlabel('f'); ylim([-0.05 0.2]);

figure('Name', 'Item 4: Bits Recuperados');
subplot(4,1,1); plot(t, received1_bits_wave); ylabel('received 1'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,1,2); plot(t, received2_bits_wave); ylabel('received 2'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,1,3); plot(t, received3_bits_wave); ylabel('received 3'); xlabel('t'); ylim([-1.5 1.5]);
subplot(4,1,4); plot(t, received4_bits_wave); ylabel('received 4'); xlabel('t'); ylim([-1.5 1.5]);

