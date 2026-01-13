/**
 * ========================================
 * 사용자 트래픽 추적 시스템 (로컬/도메인 환경 분리 및 서버 연동)
 * ========================================
 */

const STORAGE_KEY = 'bojeungjikimi_traffic_data';
const SCROLL_TRACKING_KEY = 'scrollTrackingData';

// 💡 트래픽 분석 전용 Google Sheets Web App URL
const TRAFFIC_API_URL = 'https://script.google.com/macros/s/AKfycbwcwe6bcn1zjnnO_A-XDoKgjIryJEVdBgFUWkmYdHmXKzYpo5GMb41mChTieMYzwsDw/exec';

/**
 * 현재 환경이 도메인 환경인지 확인합니다.
 * @returns {boolean} 도메인 환경이면 true
 */
function isDomainEnvironment() {
    return location.protocol === 'https:';
}

/**
 * 로컬 저장소에서 현재 데이터를 불러옵니다.
 * @returns {Array<Object>} 저장된 트래픽 이벤트 배열
 */
function getTrafficData() {
    try {
        const data = localStorage.getItem(STORAGE_KEY);
        return data ? JSON.parse(data) : [];
    } catch (e) {
        console.error("로컬 저장소에서 데이터를 불러오는 중 오류 발생:", e);
        return [];
    }
}

/**
 * Google Sheets Web App으로 트래픽 데이터를 전송하는 내부 함수
 */
async function sendEventToApi(eventData) {
    if (TRAFFIC_API_URL === 'YOUR_TRAFFIC_API_URL_HERE' || !TRAFFIC_API_URL) {
        console.warn('⚠️ 트래픽 분석 API URL이 설정되지 않았습니다. 로컬 저장소에만 저장됩니다.');
        return;
    }
    
    try {
        // fetch API를 사용하여 트래픽 데이터 전송
        const response = await fetch(TRAFFIC_API_URL, {
            method: 'POST',
            mode: 'no-cors', // Google Apps Script는 보통 'no-cors' 모드를 사용해야 합니다.
            cache: 'no-cache',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(eventData),
        });

        // no-cors 모드에서는 응답 상태를 정확히 확인할 수 없으므로, 로그만 남깁니다.
        console.log('📡 트래픽 데이터 전송 시도 완료 (no-cors 모드).');
    } catch (error) {
        console.error('❌ 트래픽 데이터 전송 오류:', error);
    }
}

/**
 * 새 이벤트를 기록하고 로컬 저장소에 저장합니다.
 * @param {string} category - 이벤트 카테고리 (예: 'Funnel')
 * @param {string} action - 이벤트 액션 (예: 'Step_Complete', 'Click')
 * @param {string} label - 이벤트 상세 레이블 (예: 'Step1_전세')
 */
function sendTrafficData(category, action, label) {
    const sessionId = generateSessionId(); // 세션 ID 가져오기
    const newEvent = {
        timestamp: new Date().toISOString(),
        sessionId: sessionId, // 세션 ID 추가
        category: category,
        action: action,
        label: label,
        userAgent: navigator.userAgent
    };
    
    // 💡 도메인 환경에서는 서버로 전송, 로컬 환경에서는 localStorage에 저장
    if (isDomainEnvironment()) {
        // 도메인 환경: Google Sheets Web App으로 전송 시도
        sendEventToApi(newEvent);
        console.log('📡 도메인 환경: 트래픽 데이터 전송 시도.');
    } else {
        // 로컬 환경: 로컬 저장소에 저장
        const data = getTrafficData();
        data.push(newEvent);
        
        try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
            console.log('✅ 로컬 저장소 저장:', newEvent);
        } catch (e) {
            console.error("로컬 저장소에 데이터를 저장하는 중 오류 발생:", e);
        }
    }
    
    // 스크롤 추적 데이터는 Scroll 카테고리일 때만 별도로 저장 (중복 방지)
    if (category === 'Scroll') {
        saveScrollTrackingData(category, action, label);
    }
}

/**
 * 스크롤 추적 데이터를 localStorage에 저장합니다.
 * @param {string} category - 이벤트 카테고리
 * @param {string} action - 이벤트 액션
 * @param {string} label - 이벤트 라벨
 */
function saveScrollTrackingData(category, action, label) {
    try {
        // 기존 스크롤 추적 데이터 불러오기
        const existingData = localStorage.getItem(SCROLL_TRACKING_KEY);
        const scrollData = existingData ? JSON.parse(existingData) : [];
        
        // 세션 ID 생성 (간단한 UUID)
        const sessionId = generateSessionId();
        
        // 새 이벤트 객체 생성
        const newScrollEvent = {
            timestamp: new Date().toISOString(),
            category: category,
            action: action,
            label: label,
            sessionId: sessionId
        };
        
        // 배열에 추가
        scrollData.push(newScrollEvent);
        
        // localStorage에 저장
        localStorage.setItem(SCROLL_TRACKING_KEY, JSON.stringify(scrollData));
        
        console.log('📊 스크롤 추적 데이터 저장:', newScrollEvent);
        
    } catch (e) {
        console.error("스크롤 추적 데이터 저장 중 오류 발생:", e);
    }
}

/**
 * 간단한 세션 ID를 생성합니다.
 * @returns {string} 생성된 세션 ID
 */
function generateSessionId() {
    // 기존 세션 ID가 있으면 사용, 없으면 새로 생성
    let sessionId = sessionStorage.getItem('scrollSessionId');
    if (!sessionId) {
        sessionId = 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        sessionStorage.setItem('scrollSessionId', sessionId);
    }
    return sessionId;
}

/**
 * 로컬 저장소의 모든 트래픽 데이터를 삭제합니다.
 */
function clearTrafficData() {
    try {
        localStorage.removeItem(STORAGE_KEY);
        return true;
    } catch (e) {
        console.error("로컬 저장소 데이터 삭제 중 오류 발생:", e);
        return false;
    }
}

/**
 * 스크롤 추적 데이터를 삭제합니다.
 */
function clearScrollTrackingData() {
    try {
        localStorage.removeItem(SCROLL_TRACKING_KEY);
        sessionStorage.removeItem('scrollSessionId');
        return true;
    } catch (e) {
        console.error("스크롤 추적 데이터 삭제 중 오류 발생:", e);
        return false;
    }
}

// 전역에서 사용할 수 있도록 함수를 window 객체에 할당
window.getTrafficData = getTrafficData;
window.sendTrafficData = sendTrafficData;
window.clearTrafficData = clearTrafficData;
window.clearScrollTrackingData = clearScrollTrackingData;

