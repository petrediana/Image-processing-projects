function [] = filtru_invers( img_perturbata, masca_txt)
    % Aplicarea filtrului invers in cazul motion blur varianta continua
    %   img_perturbata -> imaginea perturbata
    %   prag_0 -> pragul sub care valorile din filtru sunt considerate nule
    
    % Exemplu apel:
        % filtru_invers('img_p_DC_1.8_axa y.png','filtru_vertical_ponderat_central.txt')
        % filtru_invers('img_p_DC_1.8_axa y.png', 'filtru_orizontal_val_unif.txt')

    [img, m, n] = citeste_img_initiala(img_perturbata);
    afisare_imagine(img, 'Img initiala');

    masca = load(masca_txt);
    
    suma = sum(sum(masca));
    masca = masca / suma;
    [m_masca, n_masca] = size(masca);
    
    % Pasul 1. Adaug n-1 linii si m-1 coloane => expandez imaginea (unde n, m -> dimensiunea mastii)
    linii = m + m_masca - 1;
    coloane = n + n_masca - 1;
    
    f = zeros(linii, coloane);
    f( (m_masca+1)/2 : m+(m_masca+1)/2-1, (n_masca+1)/2 : n+(n_masca+1)/2-1 ) = double(img);
    
    % Pasul 2. Centrez imaginea expandata
    fc = centrare(linii, coloane, f);
    
    % Pasul 3. Calculez TFD pt fc
    TFD_fc = fft2(fc);
    
    % Pasul 4. Calculez h  !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    h = zeros(linii, coloane);
    
    linie_centru = uint16(linii/2);
    coloana_centru = uint16(coloane/2);
    
    for i = -(m_masca-1)/2 : (m_masca -1)/2
        for j = -(n_masca-1)/2 : (n_masca-1)/2
            h(linie_centru + i, coloana_centru + j) = masca(i + (m_masca-1)/2 + 1, j + (n_masca-1)/2 + 1);
        end;
    end;
    
    % Pasul 5. Centrez pe h
    hc = centrare(linii, coloane, h);
    
    % Pasul 6. Calculez TFD pt hc si centrez 
    TFD_hc = fft2(hc);
    TFD_hc = centrare(linii, coloane, TFD_hc);
    
    % Pasul 7. -----  
    G = TFD_fc;
    for i = 1 : linii
        for j = 1 : coloane
            G(i, j) = TFD_hc(i, j) * TFD_fc(i, j);
        end;
    end;
    
    % revenire in domeniul spatial
    gc = ifft2(G);
    
    % eliminare centrare
    g = centrare(linii, coloane, gc);
    
    % eliminare eventuale reziduuri complexe
    g=abs(g);
    
    % extragere matrice (imagine) rezultat
    rez=uint8( g((m_masca+1)/2 : m+(m_masca+1)/2-1, (n_masca+1)/2 : n+(n_masca+1)/2-1));
    afisare_imagine(rez, 'Poza restaurata?');
end

function [fc] = centrare(linii, coloane, f)
    fc = f;
    
    for i = 1 : linii
        for j = 1 : coloane
            fc(i, j) = f(i, j) * (-1) ^ (i + j);
        end;
    end;
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
