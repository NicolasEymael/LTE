clear;
clc;

A1 = [1 0 0 0 1 0];
disp(A1);

B1 = reshape(A1,3,[])';
disp(B1);
C1 = bi2de(B1, 'left-msb');
disp(C1)

%transformar de volta
B2 = de2bi(C1, 'left-msb');
disp(B2);

A2 = reshape(B2',1,[]);
disp(A2);


