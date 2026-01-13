import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/router_service.dart';
import 'services/traffic_tracking_service.dart';
import 'services/scroll_tracking_service.dart';
import 'services/data_storage_service.dart';
import 'services/email_service.dart';
import 'services/google_sheets_service.dart';
import 'services/fraud_stats_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 서비스 초기화
  await _initializeServices();
  
  // 시스템 UI 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const BojeungJikimiApp());
}

/// 서비스 초기화
Future<void> _initializeServices() async {
  // 데이터 저장소 초기화
  await DataStorageService.instance.init();
  
  // 트래픽 추적 서비스 초기화
  TrafficTrackingService.instance.init();
  
  // 스크롤 추적 서비스 초기화
  ScrollTrackingService.instance.init();
  
  // 전세사기 통계 서비스 초기화
  await FraudStatsService.instance.init();
}

/// 보증지킴이 메인 앱
class BojeungJikimiApp extends StatelessWidget {
  const BojeungJikimiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '보증지킴이',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
        useMaterial3: true,
      ),
      // 라우터 서비스 사용
      onGenerateRoute: RouterService.generateRoute,
      initialRoute: RouterService.home,
      navigatorObservers: [
        // 네비게이션 추적을 위한 옵저버
        RouterService.routeObserver,
      ],
    );
  }
}
