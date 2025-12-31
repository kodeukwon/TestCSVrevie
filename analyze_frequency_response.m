%% Roll Autopilot 주파수 응답 분석
% PD 제어기와 L1 적응 제어기의 주파수 특성 비교
% Lp = -3, Ld = 2000

clear all;
close all;
clc;

%% 시스템 파라미터
Lp = -3;      % Roll damping derivative [1/s]
Ld = 2000;    % Roll control effectiveness [1/s]

%% PD 제어기 설계
% 원하는 time constant
tau_desired = 0.2;
Kp = (1/tau_desired + Lp) / Ld;
Kd = 0.1 * Kp;

% Open-loop 전달함수: p(s) / delta(s) = Ld / (s - Lp)
num_ol = Ld;
den_ol = [1, -Lp];
G_ol = tf(num_ol, den_ol);

% PD 제어기: C(s) = Kp + Kd*s
num_pd = [Kd, Kp];
den_pd = 1;
C_pd = tf(num_pd, den_pd);

% Closed-loop 전달함수
G_cl_pd = feedback(G_ol * C_pd, 1);

fprintf('=== PD 제어기 ===\n');
fprintf('Kp = %.6f, Kd = %.6f\n', Kp, Kd);
fprintf('Open-loop 전달함수:\n');
G_ol

fprintf('PD 제어기:\n');
C_pd

fprintf('Closed-loop 전달함수:\n');
G_cl_pd

%% L1 적응 제어기 설계
% Reference model
A_m = -10;
B_m = 10;
G_ref = tf(B_m, [1, -A_m]);

fprintf('\n=== L1 적응 제어기 ===\n');
fprintf('Reference model:\n');
G_ref

% Low-pass filter
omega_c = 50;
C_lpf = tf(omega_c, [1, omega_c]);

fprintf('Low-pass filter (cutoff = %.0f rad/s):\n', omega_c);
C_lpf

%% Bode plot 비교
figure('Position', [100, 100, 1200, 600]);

subplot(1, 2, 1);
bode(G_cl_pd, 'b-', G_ref, 'r--', {0.1, 1000});
grid on;
legend('PD Closed-loop', 'L1 Reference Model', 'Location', 'best');
title('Bode Diagram Comparison');

%% Step response 비교
subplot(1, 2, 2);
[y_pd, t_pd] = step(G_cl_pd, 5);
[y_ref, t_ref] = step(G_ref, 5);
plot(t_pd, y_pd, 'b-', 'LineWidth', 1.5); hold on;
plot(t_ref, y_ref, 'r--', 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Roll Rate Response');
legend('PD Controller', 'L1 Reference Model', 'Location', 'best');
title('Step Response');

% 성능 지표
info_pd = stepinfo(G_cl_pd);
info_ref = stepinfo(G_ref);

fprintf('\n=== Step Response 특성 ===\n');
fprintf('PD 제어기:\n');
fprintf('  Rise time: %.4f s\n', info_pd.RiseTime);
fprintf('  Settling time: %.4f s\n', info_pd.SettlingTime);
fprintf('  Overshoot: %.2f %%\n', info_pd.Overshoot);
fprintf('  Peak: %.4f\n', info_pd.Peak);

fprintf('\nL1 Reference Model:\n');
fprintf('  Rise time: %.4f s\n', info_ref.RiseTime);
fprintf('  Settling time: %.4f s\n', info_ref.SettlingTime);
fprintf('  Overshoot: %.2f %%\n', info_ref.Overshoot);
fprintf('  Peak: %.4f\n', info_ref.Peak);

%% Pole-Zero Map
figure('Position', [100, 100, 800, 400]);

subplot(1, 2, 1);
pzmap(G_cl_pd);
grid on;
title('PD Controller Pole-Zero Map');

subplot(1, 2, 2);
pzmap(G_ref);
grid on;
title('L1 Reference Model Pole-Zero Map');

%% 안정성 마진
[Gm_pd, Pm_pd, Wcg_pd, Wcp_pd] = margin(G_ol * C_pd);
fprintf('\n=== 안정성 마진 (PD 제어기) ===\n');
fprintf('Gain margin: %.2f dB (at %.2f rad/s)\n', 20*log10(Gm_pd), Wcg_pd);
fprintf('Phase margin: %.2f deg (at %.2f rad/s)\n', Pm_pd, Wcp_pd);

saveas(gcf, 'frequency_response_analysis.png');
fprintf('\n주파수 응답 분석 결과가 저장되었습니다.\n');
