package weather

type Category string

//goland:noinspection GoUnusedConst
const (
	POP Category = "POP" // 강수확률 (%)
	PTY Category = "PTY" // 강수형태 (코드값)
	PCP Category = "PCP" // 1시간 강수량 (범주 1 mm)
	REH Category = "REH" // 습도 (%)
	SNO Category = "SNO" // 1시간 신적설 (범주 1 cm)
	SKY Category = "SKY" // 하늘상태 (코드값)
	TMP Category = "TMP" // 1시간 기온 (℃)
	TMN Category = "TMN" // 일 최저기온 (℃)
	TMX Category = "TMX" // 일 최고기온 (℃)
	UUU Category = "UUU" // 풍속(동서성분) (m/s)
	VVV Category = "VVV" // 풍속(남북성분) (m/s)
	WAV Category = "WAV" // 파고 (M)
	VEC Category = "VEC" // 풍향 (deg)
	WSD Category = "WSD" // 풍속 (m/s)
)

type Pty int8

//goland:noinspection GoUnusedConst
const (
	NONE    Pty = 0 // 없음
	RAIN    Pty = 1 // 비
	RS      Pty = 2 // 비/눈
	SNOW    Pty = 3 // 눈
	SHOWERS Pty = 4
)

type Wash string

//goland:noinspection GoUnusedConst
const (
	REC    Wash = "추천"  // 추천
	NORMAL Wash = "보통"  // 보통
	CONS   Wash = "고려"  // 고려
	NO     Wash = "비추천" // 비추천
)

type Sky int8

//goland:noinspection GoUnusedConst
const (
	SUNNY  Sky = 1 // 맑음
	MOSTLY Sky = 3 // 구름 많음
	BLUR   Sky = 4 // 흐림
)
