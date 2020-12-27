function [] = filtru_low_pass_gauss(img, D0)
    [plan, m, n] = citeste_img_initiala(img);
    afisare_imagine(plan, 'Imagine initiala grayscale');
    
    % Pasul 1. Expandare imagine
    l = 2 * m;
    c = 2 * n;
    
    m1 = fix(m/2) + 1;
    n1 = fix(n/2) + 1;
    
    f = zeros(l, c);
    f( m1:m+m1-1, n1:n+n1-1) = double(plan);
    
    % Pasul 2. Centrarea imaginii expandate
    fcp = centrare_img(f);
    
    % Pasul 3. Transformare in domeniul frecventelor
    fcpTFD = fft2(fcp);
    
    % Pasul 4. Construiesc filtrul H
    h = zeros(l, c);
    for i = 1:l
        for j = i:c
            D_m_n = distanta(i, j, l, c);
            D_m_n_patrat = D_m_n ^ 2;
            
            h(i, j) = exp( ((-1) * D_m_n_patrat) / (2 * D0 * D0) );
        end;
    end;
    
    % Pasul 5. Aplicare functie filtru calculand matricea G
    gTFD = fcpTFD .* h;
    
    % Pasul 6. Reconstruirea imaginii filtrate
    gc = real(ifft2(gTFD));
    
    % Pasul 7. Elimin centrarea
    g = centrare_img(gc);
    
    % Pasul 8. Extrag imaginea rezultat
    img_rezultat = uint8( g(m1:m+m1-1, n1:n+n1-1) );
    
    afisare_imagine(img_rezultat, 'Imagine cu filtru low pass gaussian');
end

function [dist] = distanta(i, j, l, c)
    l1 = l / 2;
    c1 = c / 2;
    
    dist = sqrt((i-l1)^2+(j-c1)^2);
end

function [g] = centrare_img(f)
    [m, n] = size(f);
    g = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            g(i, j) = f(i, j) * (-1) ^ (i + j);
        end;
    end
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
