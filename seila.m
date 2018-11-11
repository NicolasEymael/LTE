clear all;
close all;
clc;

FRM = 8;
Trellis = poly2trellis(4,[13 15],13);
Indices= randperm(FRM);

TurboEncoder = comm.TurboEncoder('TrellisStructure',Trellis,'InterleaverIndices',Indices);
TurboDecoder = comm.TurboDecoder('TrellisStructure',Trellis,'InterleaverIndices',Indices,'NumIterations',6);

u = randi([0 1],FRM,1);
encoded = TurboEncoder.step(u);
decoded = TurboDecoder.step(encoded);


M = 4;  % 4-QAM or QPSK
%u = randi([0 1],1,FRM);

i=1;
j=1;
for k=1:FRM
   A(i,j) = u(k);
   if(j==log2(M))
       j = 0;
       i = i+1;
   end
   j = j+1;
end
b = bi2de(A, 'left-msb');
bitOUT = qammod(b, M);
scatterplot(bitOUT);

disp(u);
disp(A);
disp(b);
disp(bitOUT);
