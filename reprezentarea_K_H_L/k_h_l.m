% setenv('MKL_DEBUG_CPU_TYPE', '4')

function [] = k_h_l(nrc, nrp)
    % Implementarea KL pentru seturi de imagini >= 250
    % nrc => numarul de componente pastrate ( << linii * coloane)
    % nrp => numarul de imagini
    
    % Incarc imaginile
    k = 0;
    while k < nrp
        k = k +1;
        nume_imagine_curenta = [num2str(k) '.jpeg'];
        
        [poza, m, n] = citeste_img_initiala(nume_imagine_curenta);
        
        if ~exist('imagini','var');
            imagini = uint8(zeros(m, n, nrp));
        end;
        
        % Adaug imaginea citita in colectia de imagini
        imagini(:, :, k) = poza;
        
    end;
    
    % afisez imaginile initiale din colectie
%     for k = 1:nrp
%         afisare_imagine(imagini(:, :, k), ['poza incarcata: ' num2str(k)]);
%     end;
    
    % prelucrez imaginile din colectie
        % lucrez pe blocuri de 50 x 50 din imagine

            
    nr_total_elemente_bloc = 50 * 50;
    m1 = m / 50;
    n1 = n / 50;
   
    %bloc_lin = zeros(nr_total_elemente_bloc, nrp, m1, n1);
    
    matrice_vp = zeros(nr_total_elemente_bloc, nrc, 25);
    matrice_rep = zeros(nrc, nrp, 25);
    vector_medie = zeros(nr_total_elemente_bloc, 25);
    
    im_noi_l = zeros(nr_total_elemente_bloc, nrp);
    im_noi = uint8( zeros(50, 50, nrp, 25) );
    
    for i = 1:m1
        for j = 1:n1
            % Aplic algoritmul pentru setul curent de blocuri (i, j)
            % Trebuie sa extrag setul de blocuri din cele nrp imagini
            A = zeros(50, 50, nrp);
            bloc_liniarizat = zeros(nr_total_elemente_bloc, nrp);
            
            for k = 1:nrp
                % Extrag blocul (i,j) din imaginea curenta (imaginea k)
                % Depun blocul extras in matricea A
                % Liniarizez blocurile extrase pe coloane
                
                img_k = imagini(:, :, k);
                blocuri_img_k = impartire_blocuri(img_k);
                
                A(:, :, k) = blocuri_img_k(:, :, i, j);
                bloc_liniarizat(:, k) = reshape(A(:, :, k), [1, nr_total_elemente_bloc]);
            end;
            % Aplic algoritmul Karhunen-Loeve pentru setul de imagini A
                % pentru fiecare bloc (i, j) din imaginea initiala
                
            % Calculez media si centrez datele
                % => un vector medie
                % => planul (i-1) * n1 + j din vector_medie
            medie = mean(bloc_liniarizat, 2);
            vector_medie(:, (i-1) * n1 + j) = medie;
            for k = 1:nrp
                bloc_liniarizat(:, k) = bloc_liniarizat(:, k) - medie;
            end;
            
            % Matricea de covarianta de selectie
            ss = cov(bloc_liniarizat.');
            
            % Determinarea componentelor principale si retinerea primelor nrc
                % => o matrice de vectori proprii
                % => (i-1) * n1 + j rangul elementului din matrice_vp
            
            % L = valori proprii
            % V = vectori proprii
            [V, L] = eig(ss);
            vp = V(:, nr_total_elemente_bloc : -1 : nr_total_elemente_bloc-nrc+1);
            
            matrice_vp(:, :,(i-1) * n1 + j) = vp;
            
            valp = diag(L);
            
            er_bloc = sum(valp(1:nr_total_elemente_bloc-nrc));
            
            % Reprezentarea folosind doar componentele retinute
                % => o matrice de reprezentare
                % => (i-1) * n1 + j indicele din matrice_rep            
           for k = 1:nrp
               matrice_rep(:, k, (i-1) * n1 + j) = vp' * bloc_liniarizat(:, k);
           end;
           
           % Reconstructia imaginilor din reprezentarea cu componentele principale
           for k = 1:nrp
               im_noi_l(:, k) = vp * matrice_rep(:, k, (i-1) * n1 + j);
           end;
           
           % Adaugare medie   
           for k = 1:nrp
               aux = im_noi_l(:, k) + medie;
               matrice = reshape(aux, [50 50]);
               
               im_noi(:, :, k, (i-1) * n1 + j) = uint8(matrice);
               %afisare_imagine(im_noi(:, :, k, (i-1) * n1 + j), '?');
           end;
        end;
    end;
   
    % Revenire la imaginea initiala restaurata
    for i = 1:nrp
        img_unita_i = uneste_imaginea(im_noi, i);
        afisare_imagine(img_unita_i, ['Imaginea ' num2str(i) ' reconstruita']);
        
        foo = [num2str(i) '_r.jpeg'];
        imwrite(img_unita_i, foo);
    end;
end

function [blocuri] = impartire_blocuri(img)
    [m, n] = size(img); % trebuie sa fie 250 x 250
    
    m1 = 50;
    n1 = 50;
    
    blocuri = zeros(m1, n1, m/m1, n/n1);
    for i = 1:(m/m1)
        for j = 1:(n/n1)
            for l = 1:m1
                for c = 1:n1
                    blocuri(l, c, i, j) = img( (i-1)*m1 + l, (j -1)*n1 + c);
                end;
            end;
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

function [imagine_unita] = uneste_imaginea(im_noi, k)
    imagine_unita = uint8(zeros(250, 250));
    
    imagine_unita(1:50, 1:50) = im_noi(:, :, k, 1);
    imagine_unita(1:50, 51:100) = im_noi(:, :, k, 2);
    imagine_unita(1:50, 101:150) = im_noi(:, :, k, 3);
    imagine_unita(1:50, 151:200) = im_noi(:, :, k, 4);
    imagine_unita(1:50, 201:250) = im_noi(:, :, k, 5);
    
    imagine_unita(51:100, 1:50) = im_noi(:, :, k, 6);
    imagine_unita(51:100, 51:100) = im_noi(:, :, k, 7);
    imagine_unita(51:100, 101:150) = im_noi(:, :, k, 8);
    imagine_unita(51:100, 151:200) = im_noi(:, :, k, 9);
    imagine_unita(51:100, 201:250) = im_noi(:, :, k, 10);
    
    imagine_unita(101:150, 1:50) = im_noi(:, :, k, 11);
    imagine_unita(101:150, 51:100) = im_noi(:, :, k, 12);
    imagine_unita(101:150, 101:150) = im_noi(:, :, k, 13);
    imagine_unita(101:150, 151:200) = im_noi(:, :, k, 14);
    imagine_unita(101:150, 201:250) = im_noi(:, :, k, 15);
    
    imagine_unita(151:200, 1:50) = im_noi(:, :, k, 16);
    imagine_unita(151:200, 51:100) = im_noi(:, :, k, 17);
    imagine_unita(151:200, 101:150) = im_noi(:, :, k, 18);
    imagine_unita(151:200, 151:200) = im_noi(:, :, k, 19);
    imagine_unita(151:200, 201:250) = im_noi(:, :, k, 20);
    
    imagine_unita(201:250, 1:50) = im_noi(:, :, k, 21);
    imagine_unita(201:250, 51:100) = im_noi(:, :, k, 22);
    imagine_unita(201:250, 101:150) = im_noi(:, :, k, 23);
    imagine_unita(201:250, 151:200) = im_noi(:, :, k, 24);
    imagine_unita(201:250, 201:250) = im_noi(:, :, k, 25);
end
