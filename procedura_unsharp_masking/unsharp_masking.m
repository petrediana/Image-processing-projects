% exemple de rulare:
%       unsharp_masking('img.png', 11);
%       unsharp_masking('img.png', 5);


function [ ] = unsharp_masking( img, dimensiune_masca )
    [img_initiala, ~, ~] = citeste_img_initiala(img);
    afisare_imagine(img_initiala, 'Imagine initiala grayscale');
    
    masca = zeros(dimensiune_masca, dimensiune_masca) + 1;
    suma = sum(sum(masca)); 
    masca = masca/suma;
    
    img_nivelata = filtru_c(img_initiala, masca);
    
    img_nivelata = uint8(img_nivelata);
    afisare_imagine(img_nivelata, 'Img nivelata cu filtru medie');
    
    unsharp_mask = (img_initiala - img_nivelata) + img_initiala;
    afisare_imagine(unsharp_mask, 'Varianta unsharp masking');
end

function [img_initiala, m, n] = citeste_img_initiala(img)
    img_initiala = imread(img);
        [m, n, p] = size(img_initiala);

        if p>1
            img_initiala = rgb2gray(img_initiala);
        end;
end

function [] = afisare_imagine(imagine, titlu)
    figure
        imshow(imagine);
        title(titlu);
end


function [ R ] = filtru_c( I, w )    
    [m, n] = size(I);
    [m1, n1] = size(w);
   
    a = (m1-1) / 2; 
    b = (n1-1) / 2;
    
    l = m+2 * a;
    c = n+2 * b;
    
    f = zeros(l, c);
    f(a+1:m+a, b+1:n+b) = double(I);
    
    R = zeros(m, n);   
    for i = 1:m
        for j = 1:n
            for s = -a:a
                for t = -b:b
                    R(i,j) = R(i,j) +w(1+a+s, 1+b+t) * f(i+a+s, j+b+t);
                end;
            end;
        end;
    end;
end

