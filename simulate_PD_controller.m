function [t, p, delta, error] = simulate_PD_controller(time, p_ref, Lp, Ld, disturbance)
%% PD 제어기 기반 Roll Autopilot 시뮬레이션
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

    N = length(time);
    dt = time(2) - time(1);

    %% PD 제어기 게인 설정
    % 목표: Lp = -3, Ld = 2000
    % Closed-loop poles를 설정하여 게인 계산

    % 원하는 closed-loop 특성
    omega_n = 10;      % 자연 주파수 [rad/s]
    zeta = 0.8;        % 감쇠비

    % PD 제어기: delta = Kp * e + Kd * e_dot
    % Closed-loop: p_dot = Lp * p + Ld * (Kp * e + Kd * e_dot)
    % = Lp * p + Ld * Kp * (p_ref - p) + Ld * Kd * (p_ref_dot - p_dot)

    % 간단한 게인 설정 (trial and error 기반)
    Kp = 0.01;    % 비례 게인
    Kd = 0.005;   % 미분 게인

    % 또는 극 배치 방법:
    % 원하는 특성방정식: s^2 + 2*zeta*omega_n*s + omega_n^2 = 0
    % Closed-loop: p_dot = (Lp - Ld*Kp)*p + Ld*Kp*p_ref + Ld*Kd*p_ref_dot
    % 1차 시스템으로 근사: p_dot = -(Ld*Kp - Lp)*p + Ld*Kp*p_ref
    % Time constant: tau = 1/(Ld*Kp - Lp)

    % 원하는 time constant (예: 0.2초)
    tau_desired = 0.2;
    Kp = (1/tau_desired + Lp) / Ld;
    Kd = 0.1 * Kp;  % Kd는 Kp의 일정 비율

    %% 초기화
    p = zeros(1, N);          % 롤 레이트
    delta = zeros(1, N);      % 에일러론 편향
    error = zeros(1, N);      % 추적 오차
    p_dot_prev = 0;           % 이전 p_dot (미분 계산용)

    %% 시뮬레이션 루프
    for i = 1:N
        % 추적 오차 계산
        error(i) = p_ref(i) - p(i);

        % 오차 미분 (수치 미분)
        if i == 1
            e_dot = 0;
        else
            e_dot = (error(i) - error(i-1)) / dt;
        end

        % PD 제어 법칙
        delta(i) = Kp * error(i) + Kd * e_dot;

        % Actuator saturation (실제 에일러론 한계)
        delta_max = 30;  % [deg]
        delta(i) = max(-delta_max, min(delta_max, delta(i)));

        % Roll dynamics: p_dot = Lp * p + Ld * delta + disturbance
        p_dot = Lp * p(i) + Ld * delta(i) + disturbance(i);

        % 다음 상태 업데이트 (Euler integration)
        if i < N
            p(i+1) = p(i) + p_dot * dt;
        end
    end

    t = time;

    fprintf('PD 제어기 게인: Kp = %.6f, Kd = %.6f\n', Kp, Kd);
end
