package calculate

import (
	"db_sync/internal/lib/code"
)

// WashEval 빨래지수. 각 인자값은 평균값일 경우에만 해당됨.
func WashEval(reh int8, temp float64, wind float64, sky code.Sky, pty code.Pty) code.Wash {
	re := rehEval(reh)
	te := temEval(temp)
	we := windEval(wind)
	se := skyEval(sky)
	pe := ptyEval(pty)

	wash := (re * 0.2) + (te * 0.2) + (we * 0.18) + (se * 0.1) + (pe * 0.32)

	switch {
	case wash >= 85:
		return code.REC
	case wash >= 65:
		return code.NORMAL
	case wash >= 50:
		return code.CONS
	default:
		return code.NO
	}
}

func temEval(temp float64) float64 {
	switch {
	case temp >= 30.0: // 30도 이상
		return 80.0 // 높은 온도는 마르긴 해도 불쾌감 등으로 점수를 조절
	case temp >= 25.0: // 25도 이상 30도 미만 (이전 case에 걸리지 않으므로 자동적으로 25~29.999... 처리)
		return 100.0
	case temp >= 20.0: // 20도 이상 25도 미만
		return 90.0
	case temp >= 15.0: // 15도 이상 20도 미만
		return 70.0
	case temp >= 10.0: // 10도 이상 15도 미만
		return 50.0
	case temp >= 5.0: // 5도 이상 10도 미만
		return 30.0
	default: // 5도 미만
		return 10.0
	}
}

func rehEval(reh int8) float64 {
	switch {
	case reh < 40.0: // 40 미만은 매우 건조하여 빨래하기 매우 좋음
		return 100.0
	case reh >= 40.0 && reh <= 60.0: // 적정 습도 구간
		return 100.0
	case reh > 60.0 && reh <= 70.0: // 다소 습한 구간
		return 60.0
	case reh > 70.0 && reh <= 80.0: // 습한 구간
		return 30.0
	default: // reh > 80.0 이거나 기타 예외 (매우 습함)
		return 0.0
	}
}

func windEval(windSpeed float64) float64 {
	switch {
	case windSpeed >= 3.0 && windSpeed < 6.0: // 적당한 바람 (빨래하기 가장 좋음)
		return 100.0
	case windSpeed >= 6.0 && windSpeed < 9.0: // 다소 강한 바람 (건조는 빠르나, 안전성/엉킴 고려)
		return 80.0
	case windSpeed >= 1.0 && windSpeed < 3.0: // 약한 바람 (바람 없는 것보단 좋음)
		return 70.0
	case windSpeed >= 9.0: // 매우 강한 바람 (빨래 날아갈 위험)
		return 30.0
	case windSpeed < 1.0: // 바람 거의 없음 (건조 느림)
		return 10.0 // 무풍
	default: // 그 외 (음수 등 예외적인 값)
		return 0.0
	}
}

func skyEval(sky code.Sky) float64 {
	switch sky {
	case code.SUNNY:
		return 100
	case code.MOSTLY:
		return 60
	default:
		return 0
	}
}

func ptyEval(pty code.Pty) float64 {
	switch pty {
	case code.NONE:
		return 100
	case code.RS:
		return 30.0
	default:
		return 0
	}
}
