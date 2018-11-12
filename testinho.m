clear;
clc;

A1 = [1 0 0 0 1 0 0 0];
%disp(A1);

B1 = reshape(A1,4,[])';
%disp(B1);




C1 = bi2de(B1, 'left-msb');
%disp(C1)

%transformar de volta
B2 = de2bi(C1, 'left-msb');
%disp(B2);

A2 = reshape(B2',1,[]);
%disp(A2);


a = [1 2];
%disp(a);
b = [a 3];
%disp(b);
b = [b 4 5 6];
%disp(b);


A = [1 2 3];
B = [4 5 6];
C = [7 8 9];

M(1,:) = A;
M(2,:) = B;
M(3,:) = C;

disp(M);























