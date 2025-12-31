function [t, p, delta, error, sigma_hat] = simulate_L1_controller(time, p_ref, Lp, Ld, disturbance)
%% L1 적응 제어기 기반 Roll Autopilot 시뮬레이션
% L1 Adaptive Control은 불확실성과 외란에 대해 강인한 제어를 제공
%
% 입력:
%   time        - 시간 벡터
%   p_ref       - 목표 롤 레이트 [deg/s]
%   Lp          - Roll damping derivative [1/s]
%   Ld          - Roll control effectiveness [1/s]
%   disturbance - 외란 벡터 [deg/s^2]
%
% 출력:
%   t           - 시간 벡터
%   p           - 롤 레이트 [deg/s]
%   delta       - 에일러론 편향 [deg]
%   error       - 추적 오차 [deg/s]
%   sigma_hat   - 추정된 불확실성 [deg/s]

    N = length(time);
    dt = time(2) - time(1);

    %% L1 적응 제어기 파라미터 설정

    % Reference model (원하는 closed-loop 동특성)
    A_m = -10;      % Reference model pole (빠른 응답)
    B_m = 10;       % Reference model gain

    % State predictor
    A_s = A_m;      % Predictor dynamics (보통 A_m과 동일)

    % Adaptation gain
    Gamma = 5000;   % 적응 게인 (큰 값 = 빠른 적응)

    % Low-pass filter (제어 입력 필터링)
    omega_c = 50;   % Cutoff frequency [rad/s]
    % C(s) = omega_c / (s + omega_c)

    % Baseline controller gain (nominal)
    k_g = -A_m / Ld;  % 기본 피드백 게인

    %% 초기화
    p = zeros(1, N);              % 실제 롤 레이트
    p_hat = zeros(1, N);          % 예측된 롤 레이트 (state predictor)
    delta = zeros(1, N);          % 에일러론 편향
    delta_unfiltered = zeros(1, N); % 필터링 전 제어 입력
    error = zeros(1, N);          % 추적 오차
    sigma_hat = zeros(1, N);      % 추정된 불확실성 (matched + unmatched)

    % Low-pass filter 상태
    delta_f = 0;  % 필터링된 제어 입력

    %% 시뮬레이션 루프
    for i = 1:N
        % 추적 오차
        error(i) = p_ref(i) - p(i);

        % Prediction error
        e_tilde = p(i) - p_hat(i);

        % 적응 법칙: sigma_hat_dot = -Gamma * A_s^-1 * e_tilde
        % 이산화: sigma_hat(i+1) = sigma_hat(i) - Gamma * dt * (1/A_s) * e_tilde
        sigma_hat_dot = -Gamma * (1/A_s) * e_tilde;

        % State predictor: p_hat_dot = A_s * p_hat + B_m * r + sigma_hat
        % 여기서 r은 reference, sigma_hat은 불확실성 추정
        p_hat_dot = A_s * p_hat(i) + B_m * p_ref(i) + sigma_hat(i);

        % 제어 입력 계산 (적응 보상 포함)
        % delta = k_g * (r - p) - (1/Ld) * sigma_hat
        % Low-pass filter를 통과시켜 고주파 성분 제거
        delta_ad = -(1/Ld) * sigma_hat(i);  % 적응 보상
        delta_fb = k_g * (p_ref(i) - p(i)); % 피드백 제어

        delta_unfiltered(i) = delta_fb + delta_ad;

        % Low-pass filter: delta_f_dot = -omega_c * delta_f + omega_c * delta_unfiltered
        delta_f_dot = -omega_c * delta_f + omega_c * delta_unfiltered(i);
        delta_f = delta_f + delta_f_dot * dt;

        delta(i) = delta_f;

        % Actuator saturation
        delta_max = 30;  % [deg]
        delta(i) = max(-delta_max, min(delta_max, delta(i)));

        % 실제 시스템 동역학
        % True dynamics: p_dot = Lp * p + Ld * delta + disturbance
        % 불확실성: theta = (Lp - A_m), sigma = theta * p + disturbance
        p_dot = Lp * p(i) + Ld * delta(i) + disturbance(i);

        % 다음 상태 업데이트 (Euler integration)
        if i < N
            p(i+1) = p(i) + p_dot * dt;
            p_hat(i+1) = p_hat(i) + p_hat_dot * dt;
            sigma_hat(i+1) = sigma_hat(i) + sigma_hat_dot * dt;
        end
    end

    t = time;

    fprintf('L1 적응 제어기 파라미터:\n');
    fprintf('  Reference model: A_m = %.1f, B_m = %.1f\n', A_m, B_m);
    fprintf('  Adaptation gain: Gamma = %.0f\n', Gamma);
    fprintf('  Filter cutoff: omega_c = %.0f rad/s\n', omega_c);
    fprintf('  Baseline gain: k_g = %.6f\n', k_g);
end
