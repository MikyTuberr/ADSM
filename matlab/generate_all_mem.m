clc; clearvars; close all;

%% Signal & Noise Parameters
fs = 96e3;              % Sampling frequency (96 kHz)
f_down = 13.5e3;        % Start frequency (13.5 kHz)
f_up = 16.5e3;          % End frequency (16.5 kHz)
A = 1;                  % Signal amplitude
fi_0 = 0;               % Initial phase

T_pre = 20e-3;          % Noise-only duration before chirp (20 ms)
T_post = 30e-3;         % Noise-only duration after chirp (30 ms)

durations = [50e-3, 150e-3, 200e-3, 500e-3]; % Chirp durations
modulations = {'LFM', 'HFM'};

SNR = 10;               % Signal-to-Noise Ratio in dB (Lower = more noise)

N_pre = round(T_pre * fs);
N_post = round(T_post * fs);

fprintf('=================================================================\n');
fprintf('     STARTING SONAR SIGNAL .MEM GENERATION FOR FPGA SIMULATION   \n');
fprintf('=================================================================\n\n');

for m = 1:length(modulations)
    phase_type = modulations{m};
    
    for d = 1:length(durations)
        T = durations(d);
        T_ms = round(T * 1e3);
        
        N_chirp = round(T * fs);
        N_total = N_pre + N_chirp + N_post;
        
        t = (0:N_chirp-1)/fs;
        
        if strcmp(phase_type, 'LFM')
            B = f_up - f_down;
            u = B/T;
            phi = 2*pi*f_down*t + pi*u*t.^2 + fi_0;
        elseif strcmp(phase_type, 'HFM')
            k = (1/f_up - 1/f_down)/T;
            phi = 2*pi * log(k.*t + 1/f_down) / k + fi_0;
        end
        
        signal_m = real(A * exp(1j * phi));
        
        signal_pad = [zeros(1, N_pre), signal_m, zeros(1, N_post)];
        
        signal_noised = awgn(signal_pad, SNR, 'measured');
        
        signal_scaled = round(signal_noised * 2047);
        
        signal_scaled(signal_scaled > 2047) = 2047;
        signal_scaled(signal_scaled < -2048) = -2048;
        
        signal_u2 = signal_scaled;
        idx_neg = signal_u2 < 0;
        signal_u2(idx_neg) = signal_u2(idx_neg) + 4096;
        
        filename = sprintf('%s_%dms.mem', phase_type, T_ms);
        fid = fopen(filename, 'w');
        
        for q = 1:N_total
            hex_str = dec2hex(signal_u2(q), 3);
            fprintf(fid, '%s\r\n', hex_str);
        end
        fclose(fid);
        
        fprintf('Created file: %-12s | Total samples: %5d [Pre: %4d, Chirp: %5d, Post: %4d]\n', ...
            filename, N_total, N_pre, N_chirp, N_post);
    end
    fprintf('-----------------------------------------------------------------\n');
end

fprintf('Generation completed successfully! All files are in the working directory.\n');