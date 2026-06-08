clear; clc;

fs = 100000;
fft_size = 8192;
f_start = 13500;
f_end = 16500;
durations = [0.05, 0.15, 0.2, 0.5]; 
scale = 32767;

generate_hfm = @(t, T, f1, f2) ...
    cos(2*pi * ( (f1*f2*T)/(f2-f1) * log( (f2 - f1)*t/T + f1 ) ));

for type = ["LFM", "HFM"]
    for d = durations
        fprintf('Generating PACKED COE: %s %.0f ms\n', type, d*1000);
        
        t = 0:1/fs:d-1/fs;
        
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
        
        filename = sprintf('pattern_%s_%dms_packed.coe', type, round(d*1000));
        fid = fopen(filename, 'w');
        
        fprintf(fid, 'memory_initialization_radix=16;\n');
        fprintf(fid, 'memory_initialization_vector=\n');
        
        for i = 1:fft_size
            r = real_q(i);
            if r < 0
                r = r + 65536;
            end
            hex_real = dec2hex(r, 4);
            
            im = imag_q(i);
            if im < 0
                im = im + 65536;
            end
            hex_imag = dec2hex(im, 4);
            
            fprintf(fid, '%s%s', hex_real, hex_imag);
 
            if i ~= fft_size
                fprintf(fid, ',\n');
            else
                fprintf(fid, ';\n');
            end
        end
        
        fclose(fid);
    end
end
fprintf('All PACKED COE files generated successfully!\n');