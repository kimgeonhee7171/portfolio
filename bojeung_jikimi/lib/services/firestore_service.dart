import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tip_model.dart';

// Firestore 데이터 서비스
class FirestoreService {
  // Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tips 컬렉션 가져오기 (order 기준 오름차순 정렬)
  Future<List<Tip>> getTips() async {
    try {
      final querySnapshot = await _firestore
          .collection('tips')
          .orderBy('order', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Tip.fromFirestore(doc))
          .toList();
    } catch (e) {
      // 에러 발생 시 로그 출력 및 빈 리스트 반환
      debugPrint('❌ Firestore getTips 에러: $e');
      return [];
    }
  }

  // Tips 스트림으로 가져오기 (실시간 업데이트)
  Stream<List<Tip>> getTipsStream() {
    return _firestore
        .collection('tips')
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Tip.fromFirestore(doc))
            .toList());
  }

  // Tip 추가 (관리자용)
  Future<void> addTip(Tip tip) async {
    try {
      await _firestore.collection('tips').add(tip.toMap());
      debugPrint('✅ Tip 추가 성공: ${tip.title}');
    } catch (e) {
      debugPrint('❌ Tip 추가 에러: $e');
    }
  }

  // 좋아요 토글 (증가/감소, 동시성 안전)
  Future<void> toggleLike(String documentId, bool isIncrement) async {
    await _toggleReaction(documentId, 'like_count', isIncrement);
  }

  // 아쉬워요 토글 (증가/감소, 동시성 안전)
  Future<void> toggleDislike(String documentId, bool isIncrement) async {
    await _toggleReaction(documentId, 'dislike_count', isIncrement);
  }

  // 공통 반응 토글 함수
  Future<void> _toggleReaction(
    String documentId,
    String fieldName,
    bool isIncrement,
  ) async {
    try {
      final docRef = _firestore.collection('tips').doc(documentId);
      
      // 문서 존재 여부 확인
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        debugPrint('❌ 문서가 존재하지 않습니다: $documentId');
        throw Exception('문서를 찾을 수 없습니다');
      }
      
      final data = docSnapshot.data();
      
      if (isIncrement) {
        // 증가
        if (data != null && !data.containsKey(fieldName)) {
          await docRef.set({
            fieldName: 1,
          }, SetOptions(merge: true));
        } else {
          await docRef.update({
            fieldName: FieldValue.increment(1),
          });
        }
        debugPrint('✅ $fieldName 증가 성공: $documentId');
      } else {
        // 감소
        final currentCount = data?[fieldName] ?? 0;
        if (currentCount > 0) {
          await docRef.update({
            fieldName: FieldValue.increment(-1),
          });
          debugPrint('✅ $fieldName 감소 성공: $documentId');
        }
      }
    } catch (e) {
      debugPrint('❌ $fieldName 토글 에러: $e');
      rethrow;
    }
  }
}
