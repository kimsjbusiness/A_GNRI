// lib/core/utils.dart

// 날짜를 실행시킨 날 형태로 변환
String formatDate(DateTime date) {
  return '${date.year}년 ${date.month}월 ${date.day}일';
}

// 날짜 + 요일 표시
String formatDateWithDay(DateTime date) {
  const days = ['월', '화', '수', '목', '금', '토', '일'];
  final day = days[date.weekday - 1];

  return '${date.year}년 ${date.month}월 ${date.day}일 ($day)';
}

// 감성 상태 텍스트 변환 (나중에 사용)
String sentimentToKorean(String sentiment) {
  switch (sentiment) {
    case 'bright':
      return '밝음';
    case 'neutral':
      return '보통';
    case 'dark':
      return '어두움';
    default:
      return '보통';
  }
}