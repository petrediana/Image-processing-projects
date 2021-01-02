% test_verificare_imagini

nrp = 3;
for i = 1:nrp
    nume_img_original = [num2str(i) '.jpeg'];
    nume_img_restaurata = [num2str(i) '_r.jpeg'];
    
    a = rgb2gray(imread(nume_img_original));
    b = imread(nume_img_restaurata);
 
    c = double(a) - double(b);
    d = length(find(c ~= 0));
    
    disp(['Pentru imaginea ' num2str(i) ' difera: ' num2str(d) ' pixeli']);
end;