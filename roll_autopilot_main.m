%% Roll Autopilot 시뮬레이션 - PD 제어기와 L1 적응 제어 비교
% 목표: Lp = -3, Ld = 2000
% 작성일: 2025-12-31

clear all;
close all;
clc;

%% 시스템 파라미터
% Roll dynamics: p_dot = Lp * p + Ld * delta + disturbance
Lp = -3;      % Roll damping derivative [1/s]
Ld = 2000;    % Roll control effectiveness [1/s]

% 시뮬레이션 파라미터
dt = 0.001;           % 시간 간격 [s]
t_final = 10;         % 시뮬레이션 시간 [s]
time = 0:dt:t_final;  % 시간 벡터
N = length(time);     % 샘플 수

%% 목표 롤 레이트 (Reference)
% Step response test
p_ref = zeros(1, N);
p_ref(time >= 1) = 10;  % 1초 후 10 deg/s 롤 레이트 명령

%% 외란 설정
disturbance = zeros(1, N);
% 5초 후 외란 추가
disturbance(time >= 5) = 5;

%% PD 제어기 시뮬레이션
fprintf('PD 제어기 시뮬레이션 시작...\n');
[t_pd, p_pd, delta_pd, e_pd] = simulate_PD_controller(time, p_ref, Lp, Ld, disturbance);

%% L1 적응 제어기 시뮬레이션
fprintf('L1 적응 제어기 시뮬레이션 시작...\n');
[t_l1, p_l1, delta_l1, e_l1, sigma_hat] = simulate_L1_controller(time, p_ref, Lp, Ld, disturbance);

%% 결과 플롯
figure('Position', [100, 100, 1200, 800]);

% 1. 롤 레이트 비교
subplot(4, 1, 1);
plot(t_pd, p_ref, 'k--', 'LineWidth', 2); hold on;
plot(t_pd, p_pd, 'b-', 'LineWidth', 1.5);
plot(t_l1, p_l1, 'r-', 'LineWidth', 1.5);
grid on;
ylabel('Roll Rate p [deg/s]');
legend('Reference', 'PD Controller', 'L1 Adaptive Controller', 'Location', 'best');
title(sprintf('Roll Autopilot Performance (Lp=%.1f, Ld=%.0f)', Lp, Ld));

% 2. 제어 입력 (Aileron deflection)
subplot(4, 1, 2);
plot(t_pd, delta_pd, 'b-', 'LineWidth', 1.5); hold on;
plot(t_l1, delta_l1, 'r-', 'LineWidth', 1.5);
grid on;
ylabel('Aileron \delta [deg]');
legend('PD Controller', 'L1 Adaptive Controller', 'Location', 'best');

% 3. 추적 오차
subplot(4, 1, 3);
plot(t_pd, e_pd, 'b-', 'LineWidth', 1.5); hold on;
plot(t_l1, e_l1, 'r-', 'LineWidth', 1.5);
grid on;
ylabel('Tracking Error [deg/s]');
legend('PD Controller', 'L1 Adaptive Controller', 'Location', 'best');

% 4. L1 적응 파라미터 추정
subplot(4, 1, 4);
plot(t_l1, sigma_hat, 'r-', 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Estimated \sigma [deg/s]');
title('L1 Adaptive Parameter Estimation');

%% 성능 지표 계산
% PD 제어기
IAE_pd = sum(abs(e_pd)) * dt;  % Integral Absolute Error
ISE_pd = sum(e_pd.^2) * dt;     % Integral Squared Error
max_delta_pd = max(abs(delta_pd));

% L1 제어기
IAE_l1 = sum(abs(e_l1)) * dt;
ISE_l1 = sum(e_l1.^2) * dt;
max_delta_l1 = max(abs(delta_l1));

fprintf('\n=== 성능 비교 ===\n');
fprintf('PD 제어기:\n');
fprintf('  IAE: %.4f\n', IAE_pd);
fprintf('  ISE: %.4f\n', ISE_pd);
fprintf('  Max Aileron: %.4f deg\n', max_delta_pd);
fprintf('\nL1 적응 제어기:\n');
fprintf('  IAE: %.4f\n', IAE_l1);
fprintf('  ISE: %.4f\n', ISE_l1);
fprintf('  Max Aileron: %.4f deg\n', max_delta_l1);
fprintf('\n개선율:\n');
fprintf('  IAE 감소: %.2f%%\n', (IAE_pd - IAE_l1) / IAE_pd * 100);
fprintf('  ISE 감소: %.2f%%\n', (ISE_pd - ISE_l1) / ISE_pd * 100);

%% 결과 저장
saveas(gcf, 'roll_autopilot_comparison.png');
fprintf('\n결과가 roll_autopilot_comparison.png에 저장되었습니다.\n');
