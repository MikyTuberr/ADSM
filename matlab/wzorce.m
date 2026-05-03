clc, clearvars
close all

%% Parametry sygnału
fs = 96e3; 
f_down = 13.5e3;
f_up = 16.5e3;
A = 1;
fi_0 = 0;
T = 50e-3;
T_pre = 20e-3;
T_post = 30e-3;

N_chirp = 100; %liczba chirpów w pliku wynikowym
phase = 'L';  % L -> LFM,   H -> HFM,   inne -> f=const
SNR = 10;
N = T*fs;

disp("Modulacja: " + phase + "FM")
disp("fs = " + fs + "Hz")
disp("N = "+ N);

%% Sygnał - 1 chirp
B = f_up - f_down;
u = B/T;
k = (1/f_up - 1/f_down)/T;
t = 0:1/fs:(T-1/fs);

phi_LFM = 2*pi*f_down*t + pi*u*t.^2 + fi_0;
phi_HFM = 2*pi * log(k.*t + 1/f_down) / k;

phi = 2*pi*f_down*t + fi_0;

if phase == 'L'
    phi = phi_LFM;
elseif phase == 'H'
    phi = phi_HFM;
end

% Sygnał modelowy
signal_m = real(A*exp(1j*phi));
figure(1);
plot(t*1e3,signal_m);
xlabel('t [ms]');
ylabel('Amplituda');

% Sygnał z szumem
signal_n = awgn(signal_m, SNR, 'measured');
figure(2);
plot(t*1e3,signal_n);
xlabel('t [ms]');
ylabel('Amplituda');

%% Zmiany częstotliwości
inst_freq = diff(unwrap(phi)) * fs / (2*pi);
inst_freq(end+1) = inst_freq(end);
figure(3);
plot(t*1e3, inst_freq/1e3);
xlabel('t [ms]');
ylabel('f [kHz]');

%% Gotowy sygnał
N_pre = round(T_pre * fs);
N_post = round(T_post * fs);
signal_pad = [zeros(1, N_pre), signal_m, zeros(1, N_post)];
signal = awgn(signal_pad, SNR, 'measured');
figure(4);
plot((0:1/fs:T_pre+T+T_post-1/fs)*1e3, signal);
xlabel('t [ms]');
ylabel('Amplituda');

%% Generowanie serii sygnałów i zapis do pliku RAW

filename = 'signals.bin';
fid = fopen(filename, 'w');

for i = 1:N_chirp
    signal = awgn(signal_pad, SNR, 'measured');
    signal_q = int16(signal * 32767);
    fwrite(fid, signal_q, 'int16');
end

fclose(fid);

disp("Zapisano plik: " + filename);
