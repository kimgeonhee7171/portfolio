import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/app_colors.dart';
import '../../models/report.dart';
import '../../repositories/report_repository.dart';
import 'report_result_screen.dart';

/// 리포트 지도 보기 (마커 + Bottom Sheet)
class ReportMapScreen extends StatelessWidget {
  const ReportMapScreen({super.key});

  static const LatLng _initialCenter = LatLng(37.498, 127.027); // 강남
  static const double _initialZoom = 11.5;

  Color _markerColorByScore(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.amber;
    return Colors.red;
  }

  LatLng _reportPoint(Report report) {
    if (report.lat != null && report.lng != null) {
      return LatLng(report.lat!, report.lng!);
    }
    return _initialCenter;
  }

  @override
  Widget build(BuildContext context) {
    final reports = ReportRepository.reports;
    final markers = <Marker>[];

    for (final report in reports) {
      final point = _reportPoint(report);
      final color = _markerColorByScore(report.score);

      markers.add(
        Marker(
          point: point,
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: () => _showReportBottomSheet(context, report),
            child: Icon(
              Icons.location_on,
              size: 48,
              color: color,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _initialCenter,
          initialZoom: _initialZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'bojeung_jikimi',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
      appBar: AppBar(
        title: const Text(
          '리포트 지도',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: AppColors.textDark),
            tooltip: '목록 보기',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showReportBottomSheet(BuildContext context, Report report) {
    final color = _markerColorByScore(report.score);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportResultScreen(
                  contractType: report.contractType,
                  deposit: report.deposit,
                  monthlyRent: report.monthlyRent,
                  marketPrice: report.marketPrice,
                  priorCredit: report.priorCredit,
                  address: report.address,
                  detailAddress: report.detailAddress,
                  score: report.score,
                  isViolatedArchitecture: report.isViolatedArchitecture,
                  isTaxArrears: report.isTaxArrears,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${report.score}점',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    report.grade,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.address,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    report.date,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '상세 보기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 18, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
