# Roll Autopilot: PD 제어기와 L1 적응 제어 설계

## 개요
이 프로젝트는 항공기 Roll Autopilot 시스템의 PD 제어기와 L1 적응 제어기를 MATLAB으로 구현하고 비교합니다.

### 시스템 파라미터
- **Lp = -3**: Roll damping derivative [1/s]
- **Ld = 2000**: Roll control effectiveness [1/s]

## 시스템 모델

### Roll Dynamics
```
ṗ = Lp · p + Ld · δ + d(t)
```

여기서:
- `p`: Roll rate [deg/s]
- `δ`: Aileron deflection [deg]
- `d(t)`: 외란 [deg/s²]

## 제어기 설계

### 1. PD 제어기 (Proportional-Derivative Controller)
```
δ = Kp · e + Kd · ė
```

**설계 방법:**
- 원하는 time constant (τ = 0.2s)를 기반으로 게인 계산
- Kp = (1/τ + Lp) / Ld
- Kd = 0.1 · Kp

**특징:**
- 간단한 구조
- 빠른 응답
- 외란에 대한 제한적 강인성

### 2. L1 적응 제어기 (L1 Adaptive Controller)
```
Reference Model: ṗm = Am · pm + Bm · r
State Predictor: ṗ̂ = As · p̂ + Bm · r + σ̂
Adaptation Law: σ̂̇ = -Γ · As⁻¹ · (p̂ - p)
Control Law: δ = C(s)[kg(r - p) - (1/Ld)σ̂]
```

**설계 파라미터:**
- Am = -10 (Reference model pole)
- Bm = 10 (Reference model gain)
- Γ = 5000 (Adaptation gain)
- ωc = 50 rad/s (Low-pass filter cutoff)

**특징:**
- 불확실성에 대한 강인성
- 외란 적응 및 보상
- 빠른 적응 성능
- 제어 입력의 부드러움 (low-pass filtering)

## 파일 구조

```
TestCSVrevie/
├── roll_autopilot_main.m              # 메인 시뮬레이션 스크립트
├── simulate_PD_controller.m           # PD 제어기 구현
├── simulate_L1_controller.m           # L1 적응 제어기 구현
├── analyze_frequency_response.m       # 주파수 응답 분석
└── README_Roll_Autopilot.md          # 이 문서
```

## 실행 방법

### 1. 메인 시뮬레이션 실행
```matlab
% MATLAB 커맨드 창에서:
run roll_autopilot_main.m
```

**출력:**
- 4개의 subplot을 포함한 비교 그래프
  1. Roll rate 응답 비교
  2. Aileron 제어 입력 비교
  3. 추적 오차 비교
  4. L1 적응 파라미터 추정
- 성능 지표 (IAE, ISE, Max Aileron)
- `roll_autopilot_comparison.png` 파일 저장

### 2. 주파수 응답 분석 실행
```matlab
run analyze_frequency_response.m
```

**출력:**
- Bode diagram 비교
- Step response 비교
- Pole-Zero map
- 안정성 마진 (Gain margin, Phase margin)
- `frequency_response_analysis.png` 파일 저장

## 시뮬레이션 시나리오

### 시나리오 1: Step Response
- t = 0~1s: 정상 상태
- t = 1~5s: 10 deg/s step 명령
- t = 5~10s: 외란 추가 (5 deg/s²)

### 성능 지표
1. **IAE (Integral Absolute Error)**: 추적 오차의 절대값 적분
2. **ISE (Integral Squared Error)**: 추적 오차의 제곱 적분
3. **Max Aileron**: 최대 제어 입력

## 예상 결과

### PD 제어기
- 빠른 초기 응답
- Step 명령에 대한 안정적인 추종
- 외란 발생 시 일시적인 오차 증가

### L1 적응 제어기
- Reference model을 추종하는 응답
- 외란에 대한 빠른 적응 및 보상
- 더 부드러운 제어 입력
- 전반적으로 낮은 추적 오차

## 추가 분석 및 튜닝

### PD 제어기 게인 조정
```matlab
% simulate_PD_controller.m 파일에서:
Kp = 0.01;    % 비례 게인 조정
Kd = 0.005;   % 미분 게인 조정
```

### L1 적응 제어기 파라미터 조정
```matlab
% simulate_L1_controller.m 파일에서:
Gamma = 5000;    % 적응 속도 조정 (클수록 빠름)
omega_c = 50;    % 필터 대역폭 조정
A_m = -10;       % Reference model 응답 속도 조정
```

## 이론적 배경

### L1 적응 제어의 장점
1. **Fast Adaptation**: 높은 적응 게인을 사용하여 빠른 적응
2. **Robustness**: Low-pass filter를 통해 고주파 성분 제거
3. **Performance Bounds**: 예측 가능한 성능 보장
4. **Decoupling**: 적응과 강인성을 분리하여 설계

### 적용 분야
- 항공기 자세 제어
- 미사일 유도
- 로봇 매니퓰레이터
- 자율 주행 차량

## 참고 문헌
1. Hovakimyan, N., & Cao, C. (2010). L1 Adaptive Control Theory. SIAM.
2. Stevens, B. L., & Lewis, F. L. (2003). Aircraft Control and Simulation.
3. Astrom, K. J., & Murray, R. M. (2008). Feedback Systems: An Introduction for Scientists and Engineers.

## 문의 및 개선사항
프로젝트 개선 사항이나 문의 사항이 있으시면 이슈를 등록해주세요.

---
**작성일**: 2025-12-31
**MATLAB 버전**: R2020a 이상 권장
