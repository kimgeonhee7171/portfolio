/**
 * ========================================
 * 스크롤 추적 시스템 - scroll_tracker.js
 * ========================================
 * 
 * 홈페이지의 주요 섹션에 도달할 때마다 트래픽을 추적합니다.
 * Intersection Observer를 사용하여 섹션 진입을 감지하고
 * trackButtonClick 함수를 호출하여 추적 데이터를 전송합니다.
 */

/**
 * ========================================
 * 추적 대상 섹션 ID 목록
 * ========================================
 */
const TRACKED_SECTIONS = [
    'hero',                    // 1단계: 인지단계 - Hero Section
    'problem-solution',        // 1단계: 인지단계 - Problem Awareness Section
    'curiosity',              // 2단계: 호기심단계 - How It Works Section
    'safety-score-section',   // 2.5단계: 안전도 점수 시스템
    'trust',                  // 3단계: 신뢰단계 - Trust Section
    'testimonials',           // 3단계: 신뢰단계 - Testimonials Section
    'faq-section',            // 3단계: 신뢰단계 - FAQ Section
    'urgency-section',        // 4단계: 욕구단계 - Urgency Section
    'purchase'                // 5단계: 구매단계 - Final CTA Section
];

/**
 * ========================================
 * 스크롤 추적 초기화 함수
 * ========================================
 */
function initScrollTracking() {
    // trackButtonClick 함수가 전역으로 사용 가능한지 확인
    if (typeof trackButtonClick !== 'function') {
        console.warn('⚠️ trackButtonClick 함수를 찾을 수 없습니다. index.js 로드 확인 필요.');
        return;
    }

    console.log('📊 스크롤 추적 시스템 초기화 시작...');

    // Intersection Observer 설정
    const observerOptions = {
        rootMargin: '0px 0px -50% 0px',  // 뷰포트 상단에서 50% 지점을 교차할 때
        threshold: 0                      // 뷰포트에 조금이라도 보이면 즉시 추적
    };

    // Intersection Observer 콜백 함수
    const observerCallback = (entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const sectionId = entry.target.id;
                
                // 추적 대상 섹션인지 확인
                if (TRACKED_SECTIONS.includes(sectionId)) {
                    // 스크롤 추적 이벤트 전송
                    trackButtonClick('Scroll', 'Section_View', sectionId);
                    console.log(`📊 스크롤 추적: Scroll - Section_View - ${sectionId}`);
                    
                    // 한 번만 추적하도록 observer에서 제거
                    scrollObserver.unobserve(entry.target);
                }
            }
        });
    };

    // Intersection Observer 생성
    const scrollObserver = new IntersectionObserver(observerCallback, observerOptions);

    // 각 추적 대상 섹션에 observer 적용
    TRACKED_SECTIONS.forEach(sectionId => {
        const section = document.getElementById(sectionId);
        if (section) {
            scrollObserver.observe(section);
            console.log(`📊 섹션 추적 시작: ${sectionId}`);
        } else {
            console.warn(`⚠️ 섹션을 찾을 수 없습니다: ${sectionId}`);
        }
    });

    console.log('📊 스크롤 추적 시스템 초기화 완료');
}

/**
 * ========================================
 * DOM 로드 완료 시 스크롤 추적 초기화 (로딩 오류 방지)
 * ========================================
 */
function initializeOnLoad() {
    // trackButtonClick 함수가 정의되었는지 확인 후 초기화 시도
    if (typeof trackButtonClick === 'function') {
        initScrollTracking();
    } else {
        // 혹시 모를 경우를 대비해 50ms 후 재시도 (매우 드뭄)
        setTimeout(initScrollTracking, 50);
    }
}

// ⭐ [수정] 모든 요소와 스크립트 로드가 완료된 후에 실행하도록 window.onload 사용
window.addEventListener('load', initializeOnLoad);
