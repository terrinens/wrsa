package calculate

import (
	"db_sync/internal/lib/code/weather"
	"testing"
)

var tests = []struct {
	name string
	reh  int8
	temp float64
	wind float64
	sky  weather.Sky
	pty  weather.Pty
	want weather.Wash
}{
	{
		name: "맑은날",
		reh:  50,
		temp: 23.5,
		wind: 2.3,
		sky:  weather.SUNNY,
		pty:  weather.NONE,
		want: weather.REC,
	},
	{
		name: "비오는날",
		reh:  90,
		temp: 18.2,
		wind: 5.1,
		sky:  weather.BLUR,
		pty:  weather.RAIN,
		want: weather.NO,
	},
	{
		name: "강풍",
		reh:  45,
		temp: 25.0,
		wind: 10.5,
		sky:  weather.MOSTLY,
		pty:  weather.NONE,
		want: weather.NORMAL,
	},
	{
		name: "추운날",
		reh:  30,
		temp: 5.5,
		wind: 3.2,
		sky:  weather.SUNNY,
		pty:  weather.NONE,
		want: weather.REC,
	},
	{
		name: "춥고 눈 옴",
		reh:  50,
		temp: 23.5,
		wind: 2.3,
		sky:  weather.MOSTLY,
		pty:  weather.SNOW,
		want: weather.CONS,
	},
}

func TestWashEval(t *testing.T) {
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := WashEval(tt.reh, tt.temp, tt.wind, tt.sky, tt.pty); got != tt.want {
				t.Errorf("평가 결과 = 출력값 %v, 예상값 %v", got, tt.want)
			} else {
				t.Logf("평가 결과 = 출력값 %v, 예상값 %v", got, tt.want)
			}
		})
	}
}
