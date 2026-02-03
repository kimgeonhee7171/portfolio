import 'package:cloud_firestore/cloud_firestore.dart';

// 전세 안전 꿀팁 데이터 모델
class Tip {
  final String id;
  final String title;
  final String content;
  final int order;
  final int likeCount;
  final int dislikeCount;

  Tip({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
    this.likeCount = 0,
    this.dislikeCount = 0,
  });

  // Firestore 문서를 Tip 객체로 변환
  factory Tip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Tip(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      order: data['order'] ?? 0,
      likeCount: data['like_count'] ?? 0,
      dislikeCount: data['dislike_count'] ?? 0,
    );
  }

  // Tip 객체를 Firestore 문서로 변환 (데이터 추가 시 사용)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'order': order,
      'like_count': likeCount,
      'dislike_count': dislikeCount,
    };
  }
}
