function [] = perturba_mb_continuu( img_originala, T, axa )
    % Perturbarea unei imagini prin inducerea efectului de miscare in cazul continuu 
        % img_originala -> imaginea initiala pe care o voi perturba
        
     % Exemple apel: 
        % perturba_mb_continuu('img.png', 1, 'y');
        % perturba_mb_continuu('img.png', 1, 'x');
        
    [img, m, n] = citeste_img_initiala(img_originala);
    afisare_imagine(img, 'Imaginea initiala originala');
    
    f = double(img);
    
    % Cacul TFD a imaginii originale
    TFD_f = fft2(f);
    
    % Construiesc filtrul -> motion blur pe domeniul continuu
    TFD_h = construieste_filtru_mb_c(m, n, T, axa);
    
    % Aplicarea perturbarii in domeniul frecventelor
    TFD_g = TFD_h .* TFD_f;
    
    % Calculez imaginea perturbata
    img_perturbata = uint8( abs( ifft2(TFD_g) ) );
    
    nume_img_originala = strtok(img_originala, '.');
    foo = [nume_img_originala '_p_DC_' num2str(T) '_axa_' axa '.png'];
    imwrite(img_perturbata, foo);
    
    titlu = ['Perturbare motion blur DC, axa: ' axa ' cu T: ' num2str(T)];
    afisare_imagine(img_perturbata, titlu);
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

