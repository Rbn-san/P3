% ----------------- FULL SIGNAL ---------------------

% -------- Record analysis
FileName='rl002.wav'; 

% -------- A/D Convertion
[y_voice,Fs] = audioread(FileName);

% -------- Time Plot data parameters
N_samples = length(y_voice);
n = 1:N_samples;
Eje_t_ms = n/Fs*1000;

% -------- Time Plot Configuration
subplot(3,1,1);
graph_title = 'Full signal';
plot(Eje_t_ms,y_voice);
grid;
title(graph_title);
xlabel('time in ms.');
ylabel('Voice');
axis tight;

% ----------------- FONEMA SONORO ---------------------

% -------- Extracción del fonema 

t_ini = 1330; %ms
t_fin = 1360; %ms

n_ini = t_ini*Fs/1000;
n_fin = t_fin*Fs/1000;

voiced_fonema = y_voice(n_ini:n_fin);

% -------- Time Plot data parameters
N_fon = length(voiced_fonema);
n_fon = 1:N_fon;
t_ms = n_fon/Fs*1000 + t_ini;

% -------- Time Plot Configuration
subplot(3,1,2);
graph_title = 'Voiced 30 ms';
plot(t_ms,voiced_fonema);
grid;
title(graph_title);
xlabel('time in ms.');
ylabel('Voice');
axis tight;

% -------- Cálculo Autocorrelación 
[c,lags] = xcorr(voiced_fonema);

% -------- Autocorrelaction Plot data parameters
ta_ms = lags/Fs*1000;

% -------- Autocorrelation Plot Configuration
subplot(3,1,3);
graph_title = 'Autocorrelación';
plot(lags,c);
%xlim([-4.5 25.5]);
xlim([-89 511]);
grid;
title(graph_title);
xlabel('n');
ylabel('Autocor. value');
