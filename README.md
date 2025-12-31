# TestCSVrevie
비행시험 후 결과 분석에 사용하는 프로그램을 생성한다.

## Roll Autopilot: PD 제어기와 L1 적응 제어

### 프로젝트 개요
항공기 Roll Autopilot 시스템의 PD 제어기와 L1 적응 제어기를 MATLAB으로 구현하고 성능을 비교합니다.

**시스템 파라미터:**
- Lp = -3 (Roll damping derivative)
- Ld = 2000 (Roll control effectiveness)

### 파일 목록
- `roll_autopilot_main.m` - 메인 시뮬레이션 스크립트
- `simulate_PD_controller.m` - PD 제어기 구현
- `simulate_L1_controller.m` - L1 적응 제어기 구현
- `analyze_frequency_response.m` - 주파수 응답 분석
- `README_Roll_Autopilot.md` - 상세 설명서

### 빠른 시작
```matlab
% MATLAB에서 실행:
run roll_autopilot_main.m
```

자세한 내용은 [README_Roll_Autopilot.md](README_Roll_Autopilot.md)를 참조하세요.
