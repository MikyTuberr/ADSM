clear; clc;

%PARAMETRY GLOBALNE
fs = 100000;
fft_size = 8192;

f_start = 13500;
f_end = 16500;

durations = [0.05, 0.15, 0.2, 0.5]; 
scale = 32767;

%FUNKCJA HFM 
generate_hfm = @(t, T, f1, f2) ...
    cos(2*pi * ( (f1*f2*T)/(f2-f1) * log( (f2 - f1)*t/T + f1 ) ));

%PĘTLA PO WSZYSTKICH PRZYPADKACH
for type = ["LFM", "HFM"]
    for d = durations
        fprintf('Generowanie: %s %.0f ms\n', type, d*1000);
        
        %CZAS
        t = 0:1/fs:d-1/fs;
        
        %GENERACJA CHIRPA
        if type == "LFM"
            pattern_time = chirp(t, f_start, d, f_end);
        else
            pattern_time = generate_hfm(t, d, f_start, f_end);
        end
        
        
        pattern_time = pattern_time .* hamming(length(pattern_time))';
        pattern_fft = conj(fft(pattern_time, fft_size));
        pattern_fft = pattern_fft / max(abs(pattern_fft));
        
        real_q = round(real(pattern_fft) * scale);
        imag_q = round(imag(pattern_fft) * scale);
        
        filename = sprintf('pattern_%s_%dms.coe', type, round(d*1000));
        fid = fopen(filename, 'w');
        
        fprintf(fid, 'memory_initialization_radix=10;\n');
        fprintf(fid, 'memory_initialization_vector=\n');
        
        for i = 1:fft_size
            fprintf(fid, '%d, %d', real_q(i), imag_q(i));
 
            if i ~= fft_size
                fprintf(fid, ',\n');
            else
                fprintf(fid, ';\n');
            end
        end
        
        fclose(fid);
        
    end
end
