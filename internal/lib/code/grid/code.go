package grid

import (
	"math"
)

type RepresentativeGrid struct {
	AreaCode string
	Name     string
	Nx       int
	Ny       int
}

var RepresentativeGrids = []RepresentativeGrid{
	{"1100000000", "서울특별시", 60, 127},
	{"2600000000", "부산광역시", 98, 76},
	{"2700000000", "대구광역시", 89, 90},
	{"2800000000", "인천광역시", 55, 124},
	{"2900000000", "광주광역시", 58, 74},
	{"3000000000", "대전광역시", 67, 100},
	{"3100000000", "울산광역시", 102, 84},
	{"3600000000", "세종특별자치시", 66, 103},
	{"4100000000", "경기도", 60, 120},
	{"4300000000", "충청북도", 69, 107},
	{"4400000000", "충청남도", 55, 107},
	{"4600000000", "전라남도", 51, 67},
	{"4700000000", "경상북도", 87, 106},
	{"4800000000", "경상남도", 91, 77},
	{"5000000000", "제주특별자치도", 52, 38},
	{"5019000000", "이어도", 28, 8},
	{"5019099000", "이어도", 28, 8},
	{"5100000000", "강원특별자치도", 73, 134},
	{"5200000000", "전북특별자치도", 63, 89},
}

func GetAreaCodeFromGrid(targetNx, targetNy int) RepresentativeGrid {
	minDistance := math.Inf(1)
	var data = RepresentativeGrids[0]

	for _, gridInfo := range RepresentativeGrids {
		// 격자 좌표 간 유클리드 거리 calculate
		dx := float64(targetNx - gridInfo.Nx)
		dy := float64(targetNy - gridInfo.Ny)

		distance := math.Sqrt(math.Pow(dx, 2) + math.Pow(dy, 2))

		if distance < minDistance {
			minDistance = distance
			data = gridInfo
		}
	}
	return data
}
