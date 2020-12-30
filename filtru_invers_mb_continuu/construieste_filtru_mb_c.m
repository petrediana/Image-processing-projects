    % Functia care construieste filtrul h pentru motion blur continuu
    
function [TFD_h] = construieste_filtru_mb_c(linii, coloane, T, axa)
    TFD_h = zeros(linii, coloane);
    
    alpha = 0.03;
    beta = 0.03;
    
    if axa == 'x' % miscare pe axa OX -> miscarea unei coloane pe axa OX
        for y = 1 : coloane
            for x = 1 : (linii-1)
                TFD_h(x+1, y) = ( (T * sin(pi * x * alpha)) / (pi * x * alpha) ) * ( exp(-1i * pi * x * alpha) );
            end;
            TFD_h(1, y) = 1;
        end;
    end;
    
    if axa == 'y' % miscare pe axa OY -> miscarea unei linii pe axa OY
        for x = 1 : linii
            for y = 1 : (coloane-1)
                TFD_h(x, y+1) = ( (T * sin(pi * y * beta)) / (pi * y * beta) ) * ( exp(-1i * pi * y * beta) );
            end;
            TFD_h(x, 1) = 1;
        end;
    end;
end

