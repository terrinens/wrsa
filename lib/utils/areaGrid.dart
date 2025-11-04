import 'dart:math';

class RepresentativeGrid {
  final String areaCode;
  final String name;
  final int nx;
  final int ny;

  const RepresentativeGrid({
    required this.areaCode,
    required this.name,
    required this.nx,
    required this.ny,
  });
}

const representativeGrids = [
  RepresentativeGrid(areaCode: "1100000000", name: "서울특별시", nx: 60, ny: 127),
  RepresentativeGrid(areaCode: "2600000000", name: "부산광역시", nx: 98, ny: 76),
  RepresentativeGrid(areaCode: "2700000000", name: "대구광역시", nx: 89, ny: 90),
  RepresentativeGrid(areaCode: "2800000000", name: "인천광역시", nx: 55, ny: 124),
  RepresentativeGrid(areaCode: "2900000000", name: "광주광역시", nx: 58, ny: 74),
  RepresentativeGrid(areaCode: "3000000000", name: "대전광역시", nx: 67, ny: 100),
  RepresentativeGrid(areaCode: "3100000000", name: "울산광역시", nx: 102, ny: 84),
  RepresentativeGrid(areaCode: "3600000000", name: "세종특별자치시", nx: 66, ny: 103),
  RepresentativeGrid(areaCode: "4100000000", name: "경기도", nx: 60, ny: 120),
  RepresentativeGrid(areaCode: "4300000000", name: "충청북도", nx: 69, ny: 107),
  RepresentativeGrid(areaCode: "4400000000", name: "충청남도", nx: 55, ny: 107),
  RepresentativeGrid(areaCode: "4600000000", name: "전라남도", nx: 51, ny: 67),
  RepresentativeGrid(areaCode: "4700000000", name: "경상북도", nx: 87, ny: 106),
  RepresentativeGrid(areaCode: "4800000000", name: "경상남도", nx: 91, ny: 77),
  RepresentativeGrid(areaCode: "5000000000", name: "제주특별자치도", nx: 52, ny: 38),
  RepresentativeGrid(areaCode: "5019000000", name: "이어도", nx: 28, ny: 8),
  RepresentativeGrid(areaCode: "5019099000", name: "이어도", nx: 28, ny: 8),
  RepresentativeGrid(areaCode: "5100000000", name: "강원특별자치도", nx: 73, ny: 134),
  RepresentativeGrid(areaCode: "5200000000", name: "전북특별자치도", nx: 63, ny: 89),
];

RepresentativeGrid getAreaCodeFromGrid(int targetNx, int targetNy) {
  double minDistance = double.infinity;
  RepresentativeGrid data = representativeGrids[0];

  for (final gridInfo in representativeGrids) {
    // 격자 좌표 간 유클리드 거리 calculate
    final dx = (targetNx - gridInfo.nx).toDouble();
    final dy = (targetNy - gridInfo.ny).toDouble();

    final distance = sqrt(pow(dx, 2) + pow(dy, 2));

    if (distance < minDistance) {
      minDistance = distance;
      data = gridInfo;
    }
  }
  return data;
}
