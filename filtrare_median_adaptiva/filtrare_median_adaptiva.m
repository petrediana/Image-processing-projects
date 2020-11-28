function [] = filtrare_median_adaptiva( img )

    [img_initiala, m, n] = citeste_img_initiala(img);

    imagine_perturbata = imnoise(img_initiala, 'salt & pepper', 0.5);
    imagine_filtrata = zeros(m, n);
    
    afisare_imagine(img_initiala, 'Imagine initiala grayscale');
    afisare_imagine(imagine_perturbata, 'Imaginea initiala perturbata');
    
    d_max = 11;
    
    for i = 1:m
        for j = 1:n
            
            d = 3;
            fc = extinde_imagine(d, imagine_perturbata, m, n);
            
            while 1
                masca = fc(i:i+d-1, j:j+d-1);
                masca_liniarizata = reshape(masca, [d*d, 1]);
                masca_liniarizata = sort(masca_liniarizata);

                val_min = min(masca_liniarizata);
                val_max = max(masca_liniarizata);
                val_mediana = masca_liniarizata( (d*d + 1) / 2 );

                alpha1 = val_mediana - val_min;
                alpha2 = val_mediana - val_max;

                if alpha1 > 0 && alpha2 < 0
                    beta1 = fc(i, j) - val_min;
                    beta2 = fc(i, j) - val_max;

                    if beta1 > 0 && beta2 < 0
                        imagine_filtrata(i, j) = fc(i, j);
                        break;
                    else
                        imagine_filtrata(i, j) = val_mediana;
                        break;
                    end;

                else
                    d = d + 2;
                    fc = extinde_imagine(d, imagine_perturbata, m, n);

                    if d <= d_max
                        disp('Repeta pasul 1 pentru pixelul de coordonate: ');
                        disp([i j]);
                    else
                        imagine_filtrata(i, j) = val_mediana;
                        break;
                    end;
                end;
            end;
        end;
    end;
    
    afisare_imagine(uint8(imagine_filtrata), 'Imaginea filtrata');
    imwrite(uint8(imagine_filtrata), 'img_filtrata.png', 'png');
end

function [img_extinsa] = extinde_imagine(d, imagine_perturbata, m, n)
    l = m + d - 1;
    c = n + d - 1;
    t = (d + 1) / 2;

    img_extinsa = zeros(l, c);
    img_extinsa(t:m+t-1, t:n+t-1) = double(imagine_perturbata(:, :));
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