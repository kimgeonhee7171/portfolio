import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/firestore_service.dart';

// 전문가 칼럼 & 꿀팁 상세 화면
class ColumnDetailScreen extends StatefulWidget {
  final String title;
  final String author;
  final String date;
  final String content;
  final String? appBarTitle;
  final String? documentId; // Firestore 문서 ID (좋아요 기능용)
  final int? initialLikeCount; // 초기 좋아요 수
  final int? initialDislikeCount; // 초기 아쉬워요 수

  const ColumnDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.date,
    required this.content,
    this.appBarTitle,
    this.documentId,
    this.initialLikeCount,
    this.initialDislikeCount,
  });

  @override
  State<ColumnDetailScreen> createState() => _ColumnDetailScreenState();
}

class _ColumnDetailScreenState extends State<ColumnDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLiked = false;
  bool _isDisliked = false;
  late int _likeCount;
  late int _dislikeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikeCount ?? 0;
    _dislikeCount = widget.initialDislikeCount ?? 0;
  }

  // 좋아요 토글 (상호 배타적)
  Future<void> _toggleLike() async {
    if (widget.documentId == null) return;

    final wasLiked = _isLiked;
    final wasDisliked = _isDisliked;
    final previousLikeCount = _likeCount;
    final previousDislikeCount = _dislikeCount;

    // 낙관적 업데이트 (즉시 UI 변경)
    setState(() {
      // 아쉬워요가 눌러져 있었다면 취소
      if (_isDisliked) {
        _isDisliked = false;
        _dislikeCount--;
      }

      // 좋아요 토글
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
    });

    try {
      // 아쉬워요 취소
      if (wasDisliked) {
        await _firestoreService.toggleDislike(widget.documentId!, false);
      }

      // 좋아요 토글
      await _firestoreService.toggleLike(widget.documentId!, _isLiked);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLiked ? '도움이 되셨다니 기쁩니다! 💚' : '좋아요를 취소했습니다'),
            backgroundColor: _isLiked ? const Color(0xFF00C853) : Colors.grey,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 에러 발생 시 원복
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _isDisliked = wasDisliked;
          _likeCount = previousLikeCount;
          _dislikeCount = previousDislikeCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('에러가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 아쉬워요 토글 (상호 배타적)
  Future<void> _toggleDislike() async {
    if (widget.documentId == null) return;

    final wasLiked = _isLiked;
    final wasDisliked = _isDisliked;
    final previousLikeCount = _likeCount;
    final previousDislikeCount = _dislikeCount;

    // 낙관적 업데이트 (즉시 UI 변경)
    setState(() {
      // 좋아요가 눌러져 있었다면 취소
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      }

      // 아쉬워요 토글
      _isDisliked = !_isDisliked;
      _dislikeCount = _isDisliked ? _dislikeCount + 1 : _dislikeCount - 1;
    });

    try {
      // 좋아요 취소
      if (wasLiked) {
        await _firestoreService.toggleLike(widget.documentId!, false);
      }

      // 아쉬워요 토글
      await _firestoreService.toggleDislike(widget.documentId!, _isDisliked);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isDisliked ? '소중한 의견 감사합니다' : '아쉬워요를 취소했습니다'),
            backgroundColor: _isDisliked ? Colors.grey[700] : Colors.grey,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 에러 발생 시 원복
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _isDisliked = wasDisliked;
          _likeCount = previousLikeCount;
          _dislikeCount = previousDislikeCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('에러가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        title: Text(
          widget.appBarTitle ?? '전문가 칼럼',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // 공유 기능
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 섹션
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 작성자 및 날짜
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.author,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.date,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 본문 내용
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.content,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 도움이 되었나요?
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '이 칼럼이 도움이 되셨나요?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _toggleLike,
                              icon: Icon(
                                _isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                size: 18,
                              ),
                              label: Text(
                                _likeCount > 0
                                    ? '도움됐어요 ($_likeCount)'
                                    : '도움됐어요',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _isLiked
                                    ? Colors.white
                                    : Colors.grey[600],
                                backgroundColor: _isLiked
                                    ? AppColors.primary
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: _isLiked
                                      ? AppColors.primary
                                      : Colors.grey[400]!,
                                  width: _isLiked ? 0 : 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _toggleDislike,
                              icon: Icon(
                                _isDisliked
                                    ? Icons.thumb_down
                                    : Icons.thumb_down_outlined,
                                size: 18,
                              ),
                              label: Text(
                                _dislikeCount > 0
                                    ? '아쉬워요 ($_dislikeCount)'
                                    : '아쉬워요',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _isDisliked
                                    ? Colors.white
                                    : Colors.grey[600],
                                backgroundColor: _isDisliked
                                    ? Colors.grey[700]
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: _isDisliked
                                      ? Colors.grey[700]!
                                      : Colors.grey[400]!,
                                  width: _isDisliked ? 0 : 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
