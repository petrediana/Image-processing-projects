% test impartire blocuri
% apel: test_impartire_blocuri
m = 10;
n = 10;

m1 = 2;
n1 = 2;

matrice = unidrnd(30, [m, n]);
blocuri = zeros(m1, n1, m/m1, n/n1);

for i = 1:(m/m1)
    for j = 1:(n/n1)
        for l = 1:m1
            for c = 1:n1
                blocuri(l, c, i, j) = matrice( (i-1)*m1 + l, (j -1)*n1 + c);
            end;
        end;
    end;
end;