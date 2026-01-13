/**
 * ========================================
 * 보증지킴이 - 메인 JavaScript 파일
 * ========================================
 */

/**
 * ========================================
 * EmailJS 설정 및 초기화
 * ========================================
 */

// EmailJS 초기화
(function() {
    emailjs.init("IlLEKruddDnX0TLdG");
})();

// EmailJS 설정
const EMAILJS_CONFIG = {
    serviceId: "service_1bvu13q",
    templateId: "template_ocdkmfj",
    publicKey: "IlLEKruddDnX0TLdG",
    adminEmail: "bojeungjikimi@gmail.com"
};

/**
 * ========================================
 * 트래픽 추적 함수 (traffic_tracker.js 의존)
 * ========================================
 */
function trackButtonClick(category, action, label) {
    // 1) 세션 ID 생성 (traffic_tracker.js의 generateSessionId 사용, 미존재시 fallback)
    const sessionId = (typeof generateSessionId === 'function')
        ? generateSessionId()
        : 'session_' + Date.now();

    // 2) 내부 로깅 객체 구성 (로컬 저장 대신 콘솔 로그)
    const newEvent = {
        timestamp: new Date().toISOString(),
        sessionId: sessionId,
        category: category,
        action: action,
        label: label,
        userAgent: navigator.userAgent
    };
    console.log('📊 내부 이벤트 로그:', newEvent);

    // ⭐ [추가/복구] 내부 트래픽 서버로 데이터 전송
    if (typeof sendTrafficData === 'function') {
        sendTrafficData(category, action, label);
    } else {
        console.warn('⚠️ sendTrafficData 함수를 찾을 수 없습니다. 트래픽 분석이 불가능합니다.');
    }

    // 3) ⭐ Meta Pixel로 전송 (세션 ID 포함)
    if (typeof fbq === 'function') {
        const eventName = (category === 'SectionView') ? 'SectionView' : 'ButtonClick';
        fbq('trackCustom', eventName, {
            event_category: category,
            event_action: action,
            event_label: label,
            client_session_id: sessionId
        });
        console.log(`📊 Meta Pixel 전송: ${eventName} - ${label} (session: ${sessionId})`);
    } else {
        console.warn('⚠️ fbq가 로드되지 않았습니다. Meta Pixel 전송이 생략됩니다.');
    }
}
window.trackButtonClick = trackButtonClick; // 전역 사용을 위해 window에 할당 (HTML에서 직접 호출)

// trackPopupClick 함수 추가 - trackButtonClick을 래핑하는 함수
function trackPopupClick(category, action, label) {
    trackButtonClick(category, action, label);
}
window.trackPopupClick = trackPopupClick; // 전역 사용을 위해 window에 할당

/**
 * ========================================
 * 전화번호 포맷팅 함수
 * ========================================
 */

// 전화번호 자동 포맷팅 함수
function formatPhoneNumber(input) {
    let value = input.value.replace(/[^\d]/g, ''); // 숫자만 추출
    
    // 010으로 시작하지 않으면 010으로 강제 설정
    if (!value.startsWith('010')) {
        value = '010' + value.replace(/^010/, '');
    }
    
    // 010이 삭제되려고 하면 강제로 010 유지
    if (value.length < 3) {
        value = '010';
    }
    
    // 최대 11자리까지만 허용
    if (value.length > 11) {
        value = value.substring(0, 11);
    }
    
    // 하이픈 자동 추가 (4글자마다)
    let formatted = '';
    if (value.length >= 3) {
        formatted = value.substring(0, 3) + '-'; // ✨ 수정: 010 뒤에 바로 하이픈 추가
        if (value.length >= 7) {
            formatted += value.substring(3, 7);
            if (value.length >= 11) {
                formatted += '-' + value.substring(7, 11);
            } else if (value.length > 7) {
                formatted += '-' + value.substring(7);
            }
        } else if (value.length > 3) {
            formatted += value.substring(3);
        }
    } else {
        formatted = value;
    }
    
    input.value = formatted;
}

// 전화번호 입력 필드 포커스 이벤트
function handlePhoneFocus(input) {
    // ✨ 수정: 포커스 시 010이 없으면 '010-'으로 설정
    if (!input.value.startsWith('010-')) {
        input.value = '010-';
    }
    
    // ✨ 수정: 포커스 시 커서를 '010-' 뒤 (4번째 위치)로 이동
    setTimeout(() => {
        input.setSelectionRange(4, 4);
    }, 0);
}

// 전화번호 입력 필드 블러 이벤트
function handlePhoneBlur(input) {
    // ✨ 수정: 블러 시 010-이 없으면 010-으로 강제 설정
    if (!input.value.startsWith('010-')) {
        input.value = '010-';
    }
}

// 전화번호 입력 필드 키 다운 이벤트
function handlePhoneKeyDown(input, event) {
    const cursorPosition = input.selectionStart;
    const value = input.value.replace(/[^\d]/g, '');
    
    // ✨ 수정: Backspace나 Delete 키로 '010-' (4글자) 부분을 삭제하려고 할 때 방지
    if ((event.key === 'Backspace' || event.key === 'Delete') && cursorPosition <= 4) {
        event.preventDefault();
        return false;
    }
    
    // ✨ 수정: '010-' 부분(4글자)에 직접 입력하려고 할 때 방지
    if (cursorPosition < 4 && /^\d$/.test(event.key)) {
        event.preventDefault();
        return false;
    }
}

/**
 * ========================================
 * 본인 정보 입력 검증 함수
 * ========================================
 */

function validatePersonalInfo() {
    const userName = document.getElementById('userName');
    const userPhone = document.getElementById('userPhone');
    const userEmail = document.getElementById('userEmail');
    const privacyAgreement = document.getElementById('privacyAgreement');
    
    // 이름 검증
    if (!userName || !userName.value.trim()) {
        alert('이름을 입력해주시면 리포트를 받으실 수 있어요!');
        if (userName) userName.focus();
        return false;
    }
    
    // 연락처 검증
    if (!userPhone || !userPhone.value.trim()) {
        alert('연락처를 입력해주시면 리포트를 받으실 수 있어요!');
        if (userPhone) userPhone.focus();
        return false;
    }
    
    // 전화번호 형식 검증 (010-XXXX-XXXX)
    const phoneRegex = /^010-\d{4}-\d{4}$/;
    if (!phoneRegex.test(userPhone.value.trim())) {
        alert('올바른 전화번호 형식으로 입력해주세요.\n예시: 010-1234-5678');
        if (userPhone) userPhone.focus();
        return false;
    }
    
    // 이메일 검증
    if (!userEmail || !userEmail.value.trim()) {
        alert('이메일 주소를 입력해주시면 리포트를 받으실 수 있어요!');
        if (userEmail) userEmail.focus();
        return false;
    }
    
    // 이메일 형식 검증
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(userEmail.value.trim())) {
        alert('올바른 이메일 형식으로 입력해주세요.\n예시: example@email.com');
        if (userEmail) userEmail.focus();
        return false;
    }
    
    // 개인정보 동의 검증
    if (!privacyAgreement || !privacyAgreement.checked) {
        alert('개인정보 수집 및 이용에 동의해주시면 안전하게 리포트를 받으실 수 있어요!');
        if (privacyAgreement) privacyAgreement.focus();
        return false;
    }
    
    return true;
}

/**
 * ========================================
 * 지역별 전세사기 통계 데이터
 * ========================================
 */

const fraudStatsData = {
    '서울특별시 강남구': { count: 12, amount: '3억 2천만원', risk: '보통' },
    '서울특별시 서초구': { count: 8, amount: '2억 1천만원', risk: '낮음' },
    '서울특별시 송파구': { count: 15, amount: '4억 5천만원', risk: '높음' },
    '서울특별시 강동구': { count: 6, amount: '1억 8천만원', risk: '낮음' },
    '서울특별시 마포구': { count: 9, amount: '2억 7천만원', risk: '보통' },
    '서울특별시 영등포구': { count: 11, amount: '3억 1천만원', risk: '보통' },
    '서울특별시 구로구': { count: 7, amount: '2억 2천만원', risk: '낮음' },
    '서울특별시 금천구': { count: 4, amount: '1억 2천만원', risk: '낮음' },
    '서울특별시 관악구': { count: 13, amount: '3억 8천만원', risk: '높음' },
    '서울특별시 동작구': { count: 8, amount: '2억 3천만원', risk: '보통' },
    '서울특별시 서대문구': { count: 5, amount: '1억 5천만원', risk: '낮음' },
    '서울특별시 은평구': { count: 6, amount: '1억 9천만원', risk: '낮음' },
    '서울특별시 종로구': { count: 3, amount: '9천만원', risk: '낮음' },
    '서울특별시 중구': { count: 4, amount: '1억 1천만원', risk: '낮음' },
    '서울특별시 용산구': { count: 7, amount: '2억 4천만원', risk: '보통' },
    '서울특별시 성동구': { count: 5, amount: '1억 6천만원', risk: '낮음' },
    '서울특별시 광진구': { count: 6, amount: '1억 8천만원', risk: '낮음' },
    '서울특별시 중랑구': { count: 8, amount: '2억 5천만원', risk: '보통' },
    '서울특별시 성북구': { count: 4, amount: '1억 3천만원', risk: '낮음' },
    '서울특별시 강북구': { count: 3, amount: '8천만원', risk: '낮음' },
    '서울특별시 도봉구': { count: 2, amount: '6천만원', risk: '낮음' },
    '서울특별시 노원구': { count: 5, amount: '1억 4천만원', risk: '낮음' },
    '서울특별시 양천구': { count: 7, amount: '2억 1천만원', risk: '보통' },
    '서울특별시 강서구': { count: 6, amount: '1억 7천만원', risk: '낮음' },
    '경기도 성남시': { count: 9, amount: '2억 6천만원', risk: '보통' },
    '경기도 수원시': { count: 11, amount: '3억 2천만원', risk: '보통' },
    '경기도 고양시': { count: 7, amount: '2억 1천만원', risk: '보통' },
    '경기도 용인시': { count: 8, amount: '2억 4천만원', risk: '보통' },
    '경기도 부천시': { count: 6, amount: '1억 8천만원', risk: '낮음' },
    '경기도 안양시': { count: 5, amount: '1억 5천만원', risk: '낮음' },
    '경기도 안산시': { count: 4, amount: '1억 2천만원', risk: '낮음' },
    '경기도 의정부시': { count: 3, amount: '9천만원', risk: '낮음' },
    '경기도 평택시': { count: 2, amount: '6천만원', risk: '낮음' },
    '경기도 시흥시': { count: 3, amount: '8천만원', risk: '낮음' },
    '경기도 김포시': { count: 4, amount: '1억 1천만원', risk: '낮음' },
    '경기도 광주시': { count: 2, amount: '5천만원', risk: '낮음' },
    '경기도 이천시': { count: 1, amount: '3천만원', risk: '낮음' },
    '경기도 양주시': { count: 1, amount: '2천만원', risk: '낮음' },
    '경기도 오산시': { count: 2, amount: '6천만원', risk: '낮음' },
    '경기도 의왕시': { count: 1, amount: '3천만원', risk: '낮음' },
    '경기도 하남시': { count: 3, amount: '8천만원', risk: '낮음' },
    '경기도 여주시': { count: 1, amount: '2천만원', risk: '낮음' },
    '경기도 양평군': { count: 0, amount: '0원', risk: '매우 낮음' },
    '경기도 연천군': { count: 0, amount: '0원', risk: '매우 낮음' },
    '경기도 가평군': { count: 0, amount: '0원', risk: '매우 낮음' },
    '인천시 연수구': { count: 5, amount: '1억 4천만원', risk: '낮음' },
    '인천시 남동구': { count: 6, amount: '1억 7천만원', risk: '낮음' },
    '인천시 부평구': { count: 4, amount: '1억 1천만원', risk: '낮음' },
    '인천시 계양구': { count: 3, amount: '8천만원', risk: '낮음' },
    '인천시 서구': { count: 2, amount: '5천만원', risk: '낮음' },
    '인천시 미추홀구': { count: 3, amount: '8천만원', risk: '낮음' },
    '인천시 동구': { count: 1, amount: '3천만원', risk: '낮음' },
    '인천시 중구': { count: 1, amount: '2천만원', risk: '낮음' },
    '인천시 강화군': { count: 0, amount: '0원', risk: '매우 낮음' },
    '인천시 옹진군': { count: 0, amount: '0원', risk: '매우 낮음' },
    // 전국 통계 데이터
    '전국': { count: 2847, amount: '1,247억 3천만원', risk: '보통' }
};

/**
 * ========================================
 * 멀티스텝 모달 데이터 및 네비게이션
 * ========================================
 */

// 멀티스텝 모달 데이터 저장
let modalData = {
    propertyType: '',
    trafficCode: '',
    residenceStatus: '',
    detailStatus: '',
    amount: 0,
    monthlyRent: 0,
    contractPeriod: '',
    address: '',
    userName: '',
    userPhone: '',
    userEmail: '',
    privacyAgreement: false
};

let currentStep = 1;
const totalSteps = 7;

/**
 * ========================================
 * 모달 기본 함수들
 * ========================================
 */

function openModal() {
    const modal = document.getElementById('paymentModal');
    if (modal) {
        modal.classList.add('show');
        document.body.style.overflow = 'hidden';
        document.body.classList.add('modal-open');
        resetModal();

        // 💡 [수정] Meta Pixel 추적: InitiateCheckout (퍼널 시작 + 값 0원 할당)
        if (typeof fbq === 'function') {
            fbq('track', 'InitiateCheckout', {
                value: 0.00, 
                currency: 'KRW'
            });
            console.log("📊 Meta Pixel 추적: InitiateCheckout (모달 열기, 값: 0원)");
        }
        
        // 💡 수정된 유입 로직: 모달이 열릴 때 세션 시작을 추적
        if (typeof sendTrafficData === 'function') {
            sendTrafficData('Session', 'Start', 'Modal_Open_CTA');
            console.log("📊 트래픽 추적: Session - Start - Modal_Open_CTA (새로운 유입)");
        }
    }
}

function closeModal() {
    const modal = document.getElementById('paymentModal');
    if (modal) {
        modal.classList.remove('show');
        document.body.style.overflow = 'auto';
        document.body.classList.remove('modal-open');
        
        // ✨ [수정] Modal First UX: 모달을 닫을 때 메인 콘텐츠를 표시
        document.body.classList.remove('modal-first-active');
    }
}

function resetModal() {
    currentStep = 1;
    modalData = {
        propertyType: '',
        trafficCode: '',
        residenceStatus: '',
        amount: 0,
        monthlyRent: 0,
        contractPeriod: '',
        address: ''
    };
    updateStepDisplay();
    updateNavigationButtons();
    resetAmountInput();
}

// Make functions globally available
window.openModal = openModal;
window.closeModal = closeModal;

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('paymentModal');
    if (event.target == modal) {
        closeModal();
    }
}

// 키보드 이벤트 처리 - 모달이 열려있을 때 Enter 키로 다음 단계로 이동
document.addEventListener('keydown', function(event) {
    // Enter 키를 눌렀을 때
    if (event.key === 'Enter') {
        const modal = document.getElementById('paymentModal');
        // 모달이 열려있는지 확인
        if (modal && modal.classList.contains('show')) {
            // 현재 활성화된 다음 버튼 찾기
            const nextBtn = document.querySelector('.nav-btn.next:not([disabled])');
            if (nextBtn) {
                event.preventDefault(); // 기본 동작 방지
                nextBtn.click(); // 다음 버튼 클릭 효과
            }
        }
    }
});

/**
 * ========================================
 * 단계별 네비게이션
 * ========================================
 */

function goToNextStep() {
    // 현재 단계 데이터 저장
    saveCurrentStepData();
    
    // 각 단계별 입력 검증
    if (currentStep === 1) {
        // Step 1: 거래 유형 선택 검증
        const selectedOption = document.querySelector('.step-content[data-step="1"] .option-btn.selected');
        if (!selectedOption) {
            alert('🏠 거래 유형을 선택해주시면 맞춤 분석을 시작할 수 있어요!');
            return;
        }
        trackButtonClick('Funnel', 'Step_Complete', 'Step1_' + modalData.propertyType);
        currentStep = 2;
    } else if (currentStep === 2) {
        // Step 2: 상황 선택 검증
        const selectedOption = document.querySelector('.step-content[data-step="2"] .option-btn.selected');
        if (!selectedOption) {
            alert('📋 현재 상황을 선택해주시면 더 정확한 리포트를 드릴 수 있어요!');
            return;
        }
        const value = selectedOption.getAttribute('data-value');
        if (value === '현재거주') {
            // 현재거주는 바로 Step 3으로
            trackButtonClick('Funnel', 'Step_Complete', 'Step2_' + modalData.residenceStatus);
            currentStep = 3;
        } else {
            // 나머지는 Step 2-2로
            trackButtonClick('Funnel', 'Step_Complete', 'Step2_' + modalData.residenceStatus);
            currentStep = '2-2';
        }
    } else if (currentStep === '2-2') {
        // Step 2-2: 상세 상황 선택 검증
        const selectedOption = document.querySelector('.step-content[data-step="2-2"] .option-btn.selected');
        if (!selectedOption) {
            alert('📝 상세 상황을 선택해주시면 더 정확한 분석이 가능해요!');
            return;
        }
        trackButtonClick('Funnel', 'Step_Complete', 'Step2-2_' + modalData.detailStatus);
        currentStep = 3;
    } else if (currentStep === 3) {
        // Step 3: 금액 입력 검증
        const amountInput = document.getElementById('amountInput');
        const monthlyAmountInput = document.getElementById('monthlyAmountInput');
        const monthlyRentSection = document.getElementById('monthlyRentSection');
        
        if (!amountInput || !amountInput.value || parseInt(amountInput.value) <= 0) {
            alert('💰 보증금 금액을 입력해주시면 안전성 분석을 시작할 수 있어요!');
            return;
        }
        
        // 월세 입력이 필요한 경우 검증
        if (monthlyRentSection && monthlyRentSection.style.display !== 'none') {
            if (!monthlyAmountInput || !monthlyAmountInput.value || parseInt(monthlyAmountInput.value) <= 0) {
                alert('💰 월세 금액도 함께 입력해주시면 더 정확한 분석이 가능해요!');
                return;
            }
        }
        
        trackButtonClick('Funnel', 'Step_Complete', 'Step3_Amount');
        currentStep = 4;
    } else if (currentStep === 4) {
        // Step 4: 계약 기간 선택 검증
        const selectedOption = document.querySelector('.step-content[data-step="4"] .option-btn.selected');
        if (!selectedOption) {
            alert('📅 계약 기간을 선택해주시면 맞춤 분석을 진행할 수 있어요!');
            return;
        }
        trackButtonClick('Funnel', 'Step_Complete', 'Step4_' + modalData.contractPeriod);
        currentStep = 5;
    } else if (currentStep === 5) {
        // Step 5: 주소 입력 검증
        const addressCityDistrict = document.getElementById('addressCityDistrict');
        const addressDetail = document.getElementById('addressDetail');
        if (!addressCityDistrict || !addressCityDistrict.value.trim()) {
            alert('🏡 시/도, 구/군을 입력해주시면 해당 지역의 안전성을 분석해드릴 수 있어요!');
            return;
        }
        if (!addressDetail || !addressDetail.value.trim()) {
            alert('🏡 상세 주소를 입력해주시면 정확한 분석이 가능해요!');
            return;
        }
        trackButtonClick('Funnel', 'Step_Complete', 'Step5_Address');
        currentStep = 6;
    } else if (currentStep === 6) {
        // Step 6: 본인 정보 입력 검증
        if (!validatePersonalInfo()) {
            return; 
        }
        
        // 💡 [수정] Meta Pixel 추적: Lead (Step 6, 핵심 정보 입력 완료, 값: 0원)
        if (typeof fbq === 'function') {
            fbq('track', 'Lead', {
                value: 0.00,
                currency: 'KRW'
            }); 
            console.log("📊 Meta Pixel 추적: Lead (Step 6 완료, 값: 0원)");
        }
        
        trackButtonClick('Funnel', 'Step_Complete', 'Step6_PersonalInfo');
        currentStep = 7;
    } else if (currentStep === 7) {
        // Step 7에서 완료 처리 (지역별 전세사기 통계 + 결제 정보)
        completeForm();
        return;
    } else {
        // 일반적인 다음 단계로 이동
        currentStep++;
    }
    
    updateStepDisplay();
    updateNavigationButtons();
    updateModalTitle();
}

function goToPreviousStep() {
    if (currentStep === '2-2') {
        // Step 2-2에서 Step 2로
        currentStep = 2;
    } else if (currentStep === 3) {
        // Step 3에서 이전 단계로 (2-2 또는 2)
        const selectedOption = document.querySelector('.step-content[data-step="2"] .option-btn.selected');
        if (selectedOption) {
            const value = selectedOption.getAttribute('data-value');
            if (value === '현재거주') {
                currentStep = 2;
            } else {
                currentStep = '2-2';
            }
        } else {
            currentStep = 2;
        }
    } else if (currentStep === 4) {
        // Step 4에서 Step 3으로
        currentStep = 3;
    } else if (currentStep === 5) {
        // Step 5에서 Step 4로
        currentStep = 4;
    } else if (currentStep === 6) {
        // Step 6에서 Step 5로
        currentStep = 5;
    } else if (currentStep === 7) {
        // Step 7에서 Step 6으로
        currentStep = 6;
    } else if (currentStep > 1) {
        currentStep--;
    }
    
    updateStepDisplay();
    updateNavigationButtons();
    updateModalTitle();
}

function updateStepDisplay() {
    // 모든 단계 숨기기
    document.querySelectorAll('.step-content').forEach(step => {
        step.classList.remove('active');
    });
    
    // 현재 단계 보이기
    const currentStepElement = document.querySelector(`.step-content[data-step="${currentStep}"]`);
    if (currentStepElement) {
        currentStepElement.classList.add('active');
    }
    
    // 진행 표시 업데이트
    document.querySelectorAll('.progress-dot').forEach((dot) => {
        dot.classList.remove('active', 'completed', 'half-completed');
        const dotStep = dot.getAttribute('data-step');
        
        // 현재 단계에 따라 progress 표시
        if (currentStep === 1) {
            if (dotStep === '1') dot.classList.add('active');
        } else if (currentStep === 2) {
            if (dotStep === '1') dot.classList.add('completed');
            if (dotStep === '2') dot.classList.add('active');
        } else if (currentStep === '2-2') {
            if (dotStep === '1') dot.classList.add('completed');
            if (dotStep === '2') dot.classList.add('half-completed');
            // 2-2는 2번째 칸 안에 있으므로 별도 칸 없음
        } else if (currentStep === 3) {
            if (dotStep === '1' || dotStep === '2') dot.classList.add('completed');
            if (dotStep === '3') dot.classList.add('active');
        } else if (currentStep === 4) {
            if (dotStep === '1' || dotStep === '2' || dotStep === '3') dot.classList.add('completed');
            if (dotStep === '4') dot.classList.add('active');
        } else if (currentStep === 5) {
            if (dotStep === '1' || dotStep === '2' || dotStep === '3' || dotStep === '4') dot.classList.add('completed');
            if (dotStep === '5') dot.classList.add('active');
        } else if (currentStep === 6) {
            if (dotStep === '1' || dotStep === '2' || dotStep === '3' || dotStep === '4' || dotStep === '5') dot.classList.add('completed');
            if (dotStep === '6') dot.classList.add('active');
        } else if (currentStep === 7) {
            if (dotStep === '1' || dotStep === '2' || dotStep === '3' || dotStep === '4' || dotStep === '5' || dotStep === '6') dot.classList.add('completed');
            if (dotStep === '7') dot.classList.add('active');
        }
    });
}

function updateNavigationButtons() {
    const currentStepSelector = `.step-content[data-step="${currentStep}"]`;
    const prevBtn = document.querySelector(`${currentStepSelector} .nav-btn.prev`);
    const nextBtn = document.querySelector(`${currentStepSelector} .nav-btn.next`);
    const backBtn = document.getElementById('backBtn');
    
    if (!prevBtn || !nextBtn) {
        return;
    }
    
    if (currentStep === 1) {
        prevBtn.style.display = 'none';
        backBtn.style.display = 'none';
    } else {
        prevBtn.style.display = 'block';
        prevBtn.disabled = false;
        backBtn.style.display = 'block';
    }
    
    if (currentStep === 7) {
        nextBtn.textContent = '신청하기!';
        nextBtn.disabled = false; // 무료 버전이므로 항상 활성화
    } else {
        nextBtn.textContent = '다음';
        nextBtn.disabled = !isCurrentStepValid();
    }
}

// 현재 단계의 입력이 유효한지 확인하는 함수
function isCurrentStepValid() {
    if (currentStep === 1) {
        // Step 1: 거주 상태 선택 확인
        const selectedOption = document.querySelector('.step-content[data-step="1"] .option-btn.selected');
        return selectedOption !== null;
    } else if (currentStep === 2) {
        // Step 2: 상황 선택 확인
        const selectedOption = document.querySelector('.step-content[data-step="2"] .option-btn.selected');
        return selectedOption !== null;
    } else if (currentStep === '2-2') {
        // Step 2-2: 상세 상황 선택 확인
        const selectedOption = document.querySelector('.step-content[data-step="2-2"] .option-btn.selected');
        return selectedOption !== null;
    } else if (currentStep === 3) {
        // Step 3: 금액 입력 확인
        const amountInput = document.getElementById('amountInput');
        const monthlyAmountInput = document.getElementById('monthlyAmountInput');
        const monthlyRentSection = document.getElementById('monthlyRentSection');
        
        // 보증금 입력 확인: 콤마 제거 후 0보다 큰지 확인
        const depositValue = parseInt(amountInput ? amountInput.value.replace(/,/g, '') : 0);
        if (!amountInput || depositValue <= 0 || isNaN(depositValue)) {
            return false;
        }
        
        // 월세 입력이 필요한 경우 확인
        if (monthlyRentSection && monthlyRentSection.style.display !== 'none') {
            const monthlyValue = parseInt(monthlyAmountInput ? monthlyAmountInput.value.replace(/,/g, '') : 0);
            if (!monthlyAmountInput || monthlyValue <= 0 || isNaN(monthlyValue)) {
                return false;
            }
        }
        
        return true;
    } else if (currentStep === 4) {
        // Step 4: 계약 기간 선택 확인
        const selectedOption = document.querySelector('.step-content[data-step="4"] .option-btn.selected');
        return selectedOption !== null;
    } else if (currentStep === 5) {
        // Step 5: 주소 입력 확인
        const addressCityDistrict = document.getElementById('addressCityDistrict');
        const addressDetail = document.getElementById('addressDetail');
        return addressCityDistrict && addressCityDistrict.value.trim() && 
               addressDetail && addressDetail.value.trim();
    } else if (currentStep === 6) {
        // Step 6: 본인 정보 입력 확인
        const userName = document.getElementById('userName');
        const userPhone = document.getElementById('userPhone');
        const userEmail = document.getElementById('userEmail');
        const privacyAgreement = document.getElementById('privacyAgreement');
        
        return userName && userName.value.trim() &&
               userPhone && userPhone.value.trim() &&
               userEmail && userEmail.value.trim() &&
               privacyAgreement && privacyAgreement.checked;
    }
    return true; // 기본적으로 유효하다고 간주
}

function updateModalTitle() {
    const titles = {
        1: '어떤 유형의 계약인가요?',
        2: '현재 어떤 상황이신가요?',
        '2-2': '좀 더 자세히 알려주세요',
        3: '금액을 입력해주세요',
        4: '계약 기간을 선택해주세요',
        5: '분석받을 주소를 알려주세요',
        6: '정보를 입력해주세요',
        7: '지역별 전세사기 통계'
    };
    
    document.getElementById('modalTitle').textContent = titles[currentStep] || '정보 입력';
}

function saveCurrentStepData() {
    switch(currentStep) {
        case 1:
            const selectedProperty = document.querySelector('.step-content[data-step="1"] .option-btn.selected');
            if (selectedProperty) {
                modalData.propertyType = selectedProperty.getAttribute('data-value');
                modalData.trafficCode = selectedProperty.getAttribute('data-traffic');
            }
            break;
        case 2:
            const selectedResidence = document.querySelector('.step-content[data-step="2"] .option-btn.selected');
            if (selectedResidence) {
                modalData.residenceStatus = selectedResidence.getAttribute('data-value');
            }
            break;
        case '2-2':
            const selectedDetail = document.querySelector('.step-content[data-step="2-2"] .option-btn.selected');
            if (selectedDetail) {
                modalData.detailStatus = selectedDetail.getAttribute('data-value');
            }
            break;
        case 3:
            const amountInput = document.getElementById('amountInput');
            if (amountInput) {
                modalData.amount = parseInt(amountInput.value.replace(/,/g, '')) || 0;
            }
            
            const monthlyAmountInput = document.getElementById('monthlyAmountInput');
            if (monthlyAmountInput) {
                modalData.monthlyRent = parseInt(monthlyAmountInput.value.replace(/,/g, '')) || 0;
            }
            break;
        case 4:
            const selectedPeriod = document.querySelector('.step-content[data-step="4"] .option-btn.selected');
            if (selectedPeriod) {
                modalData.contractPeriod = selectedPeriod.getAttribute('data-value');
            }
            break;
        case 5:
            const addressCityDistrict = document.getElementById('addressCityDistrict');
            const addressDong = document.getElementById('addressDong');
            const addressNumber = document.getElementById('addressNumber');
            const addressDetail = document.getElementById('addressDetail');
            
            let fullAddress = '';
            if (addressCityDistrict && addressCityDistrict.value.trim()) fullAddress += addressCityDistrict.value.trim();
            if (addressDong && addressDong.value.trim()) fullAddress += ' ' + addressDong.value.trim();
            if (addressNumber && addressNumber.value.trim()) fullAddress += ' ' + addressNumber.value.trim();
            if (addressDetail && addressDetail.value.trim()) fullAddress += ' ' + addressDetail.value.trim();
            
            modalData.address = fullAddress.trim();
            break;
        case 6:
            // 본인 정보 입력 단계
            const userName = document.getElementById('userName');
            const userPhone = document.getElementById('userPhone');
            const userEmail = document.getElementById('userEmail');
            const privacyAgreement = document.getElementById('privacyAgreement');
            
            if (userName) modalData.userName = userName.value.trim();
            if (userPhone) modalData.userPhone = userPhone.value.trim();
            if (userEmail) modalData.userEmail = userEmail.value.trim();
            if (privacyAgreement) modalData.privacyAgreement = privacyAgreement.checked;
            break;
        case 7:
            // 전세사기 통계 단계 - 데이터 저장 불필요
            break;
    }
}

/**
 * ========================================
 * 서버 API 호출 함수 (Google Sheets 대체)
 * ========================================
 */

/**
 * Google Sheets Web App으로 예약 데이터 전송
 * @param {Object} data - 전송할 폼 데이터
 * @returns {Promise<boolean>} - 성공 여부
 */
async function sendDataToServer(data) {
    try {
        // ⭐ [수정] 새로 배포된 고객 데이터 저장용 Apps Script URL로 교체
        const GOOGLE_SHEET_WEB_APP_URL = 'https://script.google.com/macros/s/AKfycbxfvzWR6dZZu5Q-tUYGPMq64Qlnp4U_6eh3P_eeWsYyK5kifCmZUJhVnCw0SbROneSUpA/exec';
        
        if (GOOGLE_SHEET_WEB_APP_URL === 'YOUR_GOOGLE_SHEET_WEB_APP_URL_HERE') {
            console.warn('⚠️ Google Sheets URL이 설정되지 않았습니다. 예약 데이터 전송이 비활성화됩니다.');
            return false;
        }
        
        // UserAgent 추가
        const requestData = {
            ...data,
            userAgent: navigator.userAgent,
            timestamp: new Date().toISOString()
        };
        
        console.log('📡 Google Sheets로 예약 데이터 전송 시도:', requestData);
        
        const response = await fetch(GOOGLE_SHEET_WEB_APP_URL, {
            method: 'POST',
            mode: 'no-cors', // Google Apps Script는 no-cors 모드 사용
            cache: 'no-cache',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(requestData)
        });
        
        // no-cors 모드에서는 응답 상태를 정확히 확인할 수 없으므로, 로그만 남깁니다.
        console.log('📡 Google Sheet로 예약 데이터 전송 시도 완료 (no-cors 모드).');
        return true; // no-cors 모드에서는 성공으로 간주

    } catch (error) {
        console.error('❌ Google Sheets 전송 오류:', error);
        return false;
    }
}

/**
 * ========================================
 * 폼 완료 처리 함수
 * ========================================
 */

async function completeForm() {
    // ⭐ [추가] processingOverlay 변수 선언 (스코프 확장)
    let processingOverlay = null;
    
    saveCurrentStepData();

    if (!modalData.userName || !modalData.userPhone || !modalData.userEmail || !modalData.privacyAgreement) {
        alert('필수 정보를 모두 입력하고 동의해주시면 안전한 리포트를 받으실 수 있어요!');
        return;
    }
    
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(modalData.userEmail)) {
        alert('올바른 이메일 형식으로 입력해주세요.\n예시: example@email.com');
        return;
    }
    const phoneRegex = /^010-\d{4}-\d{4}$/;
    if (!phoneRegex.test(modalData.userPhone)) {
        alert('올바른 전화번호 형식으로 입력해주세요.\n예시: 010-1234-5678');
        return;
    }

    const step7NextBtn = document.querySelector('.step-content[data-step="7"] .nav-btn.next');
    if (!step7NextBtn) {
        alert('⚠️ 일시적인 오류가 발생했어요. 페이지를 새로고침 후 다시 시도해주세요!');
        return;
    }

    const originalText = step7NextBtn.textContent;
    step7NextBtn.textContent = '처리 중...';
    step7NextBtn.disabled = true;
    
    // ⭐ [수정] 변수에 값 할당
    processingOverlay = document.getElementById('processingOverlay');
    
    // 요소가 있을 때만 active 클래스 추가 (없으면 경고 로그)
    processingOverlay 
        ? processingOverlay.classList.add('active') 
        : console.warn('⚠️ DOM에서 processingOverlay 요소를 찾을 수 없습니다. (808행 오류 방지)');

    const monthlyRentRowHtml = modalData.monthlyRent > 0
        ? `<tr><td style="padding: 12px 0; border-bottom: 1px solid #e5e7eb; font-weight: 600; color: #6b7280;">월세</td><td style="padding: 12px 0; border-bottom: 1px solid #e5e7eb; color: #374151; font-weight: 700;">${formatNumberToKorean(modalData.monthlyRent)}</td></tr>`
        : '';

    const templateParams = {
        userName: modalData.userName,
        userEmail: modalData.userEmail,
        userPhone: modalData.userPhone,
        propertyType: modalData.propertyType,
        residenceStatus: modalData.residenceStatus,
        detailStatus: modalData.detailStatus,
        depositAmount: formatNumberToKorean(modalData.amount),
        contractPeriod: modalData.contractPeriod,
        address: modalData.address,
        monthlyRentRow: monthlyRentRowHtml,
    };
    
    try {
        // 서버 전송과 이메일 전송을 병렬로 실행
        const [serverSuccess, emailResults] = await Promise.all([
            sendDataToServer(modalData),
            sendEmailNotifications(templateParams)
        ]);

        let alertMessage = '';
        
        if (serverSuccess) {
            
            // 💡 [수정] Meta Pixel 추적: CompleteRegistration (최종 목표 달성, 값: 0원)
            if (typeof fbq === 'function') {
                fbq('track', 'CompleteRegistration', {
                    value: 0.00, 
                    currency: 'KRW'
                });
                console.log("📊 Meta Pixel 추적: CompleteRegistration (신청 성공, 값: 0원)");
            }
            
            // 최종 신청 완료 추적
            trackButtonClick('Funnel', 'Goal_Conversion', 'Step7_Application_Success');
            
            alertMessage = `보증지킴이 리포트 신청이 완료되었습니다!\n\n` +
                `신청 내용은 ${modalData.userEmail} 주소로 발송된 확인 이메일에서도 보실 수 있어요.\n\n` +
                `24시간 이내 전문가가 꼼꼼히 분석한 안전성 검증 리포트를 보내드릴게요!\n\n` +
                `소중한 보증금, 보증지킴이와 함께 지켜요! 감사합니다 😊`;
            
            if (!emailResults.customerSuccess) {
                alertMessage = `보증지킴이 리포트 신청이 완료되었습니다!\n\n` + 
                `확인 이메일 발송에 일시적인 문제가 있었지만, 신청은 정상적으로 접수되었어요.\n\n` +
                `24시간 이내 전문가 분석 리포트를 보내드릴게요! 안심하세요 😊`;
            }
        } else {
            alertMessage = '⚠️ 일시적인 오류가 발생했어요.\n\n잠시 후 다시 시도해주시면 안전하게 신청하실 수 있어요!';
        }
        
        alert(alertMessage);
        
        console.log('📡 서버 전송:', serverSuccess ? '성공' : '실패');
        console.log('📧 관리자 이메일:', emailResults.adminSuccess ? '성공' : '실패');
        console.log('📧 고객 이메일:', emailResults.customerSuccess ? '성공' : '실패');

        if (serverSuccess) {
            const step7PrevBtn = document.querySelector('.step-content[data-step="7"] .nav-btn.prev');
            if (step7PrevBtn) {
                step7PrevBtn.disabled = false;
            }
            
            // 💡 Meta Pixel CompleteRegistration 이벤트 전송 완료를 위한 500ms 지연
            await new Promise(resolve => setTimeout(resolve, 500));
            closeModal();
        }

    } catch (error) {
        console.error('❌ 전체 처리 중 오류 발생:', error);
        alert('⚠️ 일시적인 오류가 발생했어요.\n\n잠시 후 다시 시도해주시거나, 문제가 계속되면 고객센터로 문의해주세요!');
    } finally {
        step7NextBtn.textContent = originalText;
        step7NextBtn.disabled = false; // 무료 버전이므로 항상 활성화
        if (processingOverlay) {
            processingOverlay.classList.remove('active');
        }
    }
}

/**
 * ========================================
 * 금액 관련 함수들
 * ========================================
 */

function resetAmountInput() {
    const amountInput = document.getElementById('amountInput');
    const amountText = document.getElementById('amountText');
    const monthlyAmountInput = document.getElementById('monthlyAmountInput');
    const monthlyAmountText = document.getElementById('monthlyAmountText');
    const monthlyRentSection = document.getElementById('monthlyRentSection');
    
    amountInput.value = '';
    amountText.style.display = 'none';
    monthlyAmountInput.value = '';
    monthlyAmountText.style.display = 'none';
    monthlyRentSection.style.display = 'none';
}

function addAmount(amount) {
    const amountInput = document.getElementById('amountInput');
    const currentValue = amountInput.value.replace(/,/g, '');
    const currentAmount = currentValue ? parseInt(currentValue) : 0;
    const newAmount = currentAmount + amount;
    amountInput.value = newAmount.toLocaleString();
    formatAmount(amountInput);
}

function formatAmount(input) {
    const value = input.value.replace(/,/g, '');
    const numValue = parseInt(value);
    const amountText = document.getElementById('amountText');
    
    if (!isNaN(numValue) && numValue > 0) {
        input.value = numValue.toLocaleString();
        amountText.textContent = formatNumberToKorean(numValue);
        amountText.style.display = 'block';
    } else {
        amountText.style.display = 'none';
    }
    
    // 금액이 변경될 때마다 다음 버튼 상태 업데이트 호출
    updateNavigationButtons();
}

function formatNumberToKorean(num) {
    if (num >= 100000000) {
        const eok = Math.floor(num / 100000000);
        const man = Math.floor((num % 100000000) / 10000);
        if (man > 0) {
            return eok + '억 ' + man + '만원';
        }
        return eok + '억원';
    } else if (num >= 10000) {
        return Math.floor(num / 10000) + '만원';
    } else if (num >= 1000) {
        return Math.floor(num / 1000) + '천원';
    } else {
        return num.toLocaleString() + '원';
    }
}

/**
 * ========================================
 * 월세 관련 함수들
 * ========================================
 */

function addMonthlyAmount(amount) {
    const monthlyAmountInput = document.getElementById('monthlyAmountInput');
    const currentValue = monthlyAmountInput.value.replace(/,/g, '');
    const currentAmount = currentValue ? parseInt(currentValue) : 0;
    const newAmount = currentAmount + amount;
    monthlyAmountInput.value = newAmount.toLocaleString();
    formatMonthlyAmount(monthlyAmountInput);
}

function formatMonthlyAmount(input) {
    const value = input.value.replace(/,/g, '');
    const numValue = parseInt(value);
    const monthlyAmountText = document.getElementById('monthlyAmountText');
    
    if (!isNaN(numValue) && numValue > 0) {
        input.value = numValue.toLocaleString();
        monthlyAmountText.textContent = formatNumberToKorean(numValue);
        monthlyAmountText.style.display = 'block';
    } else {
        monthlyAmountText.style.display = 'none';
    }
    
    // 월세 금액이 변경될 때마다 다음 버튼 상태 업데이트 호출
    updateNavigationButtons();
}

// 거래 유형에 따른 월세 입력란 표시/숨김
function toggleMonthlyRentSection() {
    const monthlyRentSection = document.getElementById('monthlyRentSection');
    const selectedProperty = document.querySelector('.step-content[data-step="1"] .option-btn.selected');
    
    if (selectedProperty) {
        const propertyType = selectedProperty.getAttribute('data-value');
        if (propertyType === '월세' || propertyType === '반전세') {
            monthlyRentSection.style.display = 'block';
        } else {
            monthlyRentSection.style.display = 'none';
            // 월세 관련 데이터 초기화
            document.getElementById('monthlyAmountInput').value = '';
            document.getElementById('monthlyAmountText').style.display = 'none';
            modalData.monthlyRent = 0;
        }
    }
    
    // 버튼 상태 업데이트
    updateNavigationButtons();
}

/**
 * ========================================
 * 주소 검색 및 전세사기 통계
 * ========================================
 */

function searchAddress() {
    const addressCityDistrict = document.getElementById('addressCityDistrict');
    const addressDong = document.getElementById('addressDong');
    
    if (addressCityDistrict && addressCityDistrict.value.trim() && 
        addressDong && addressDong.value.trim()) {
        // 실제 구현 시 주소 검색 API 연동
        const fullAddress = `${addressCityDistrict.value.trim()} ${addressDong.value.trim()}`;
        console.log('주소 검색:', fullAddress);
        alert('🔍 주소 검색 기능은 곧 업데이트될 예정이에요!\n현재는 직접 입력해주시면 분석 가능합니다 😊');
    } else {
        alert('🏡 시/도, 구/군과 동/읍/면을 입력해주시면 정확한 주소 검색이 가능해요!');
    }
}

// 지역별 전세사기 통계 업데이트 함수
function updateFraudStats() {
    const addressCityDistrict = document.getElementById('addressCityDistrict');
    if (!addressCityDistrict || !addressCityDistrict.value.trim()) {
        // 입력이 비어있을 때도 전국 통계 표시
        const nationalStats = fraudStatsData['전국'];
        document.getElementById('statsLocation').textContent = '전국 (2025년 기준)';
        document.getElementById('fraudCount').textContent = nationalStats.count + '건';
        document.getElementById('fraudAmount').textContent = nationalStats.amount;
        document.getElementById('riskLevel').textContent = nationalStats.risk;
        
        // 전국 통계에 맞는 색상 적용
        const riskLevelElement = document.getElementById('riskLevel');
        const fraudStatsCard = document.getElementById('fraudStatsCard');
        
        // 기존 색상 클래스 제거
        fraudStatsCard.classList.remove('risk-low', 'risk-medium', 'risk-high', 'risk-very-low');
        
        // 전국 통계 위험도에 따른 색상 적용
        fraudStatsCard.classList.add('risk-medium');
        riskLevelElement.style.color = '#f59e0b';
        return;
    }

    const cityDistrict = addressCityDistrict.value.trim();
    const stats = fraudStatsData[cityDistrict];
    
    if (stats) {
        // 통계 데이터 업데이트
        document.getElementById('statsLocation').textContent = cityDistrict;
        document.getElementById('fraudCount').textContent = stats.count + '건';
        document.getElementById('fraudAmount').textContent = stats.amount;
        document.getElementById('riskLevel').textContent = stats.risk;
        
        // 위험도에 따른 색상 조정
        const riskLevelElement = document.getElementById('riskLevel');
        const fraudStatsCard = document.getElementById('fraudStatsCard');
        
        // 기존 색상 클래스 제거
        fraudStatsCard.classList.remove('risk-low', 'risk-medium', 'risk-high', 'risk-very-low');
        
        // 위험도에 따른 색상 적용
        switch(stats.risk) {
            case '매우 낮음':
                fraudStatsCard.classList.add('risk-very-low');
                riskLevelElement.style.color = '#10b981';
                break;
            case '낮음':
                fraudStatsCard.classList.add('risk-low');
                riskLevelElement.style.color = '#3b82f6';
                break;
            case '보통':
                fraudStatsCard.classList.add('risk-medium');
                riskLevelElement.style.color = '#f59e0b';
                break;
            case '높음':
                fraudStatsCard.classList.add('risk-high');
                riskLevelElement.style.color = '#ef4444';
                break;
        }
    } else {
        // 데이터가 없는 경우 전국 통계 표시
        const nationalStats = fraudStatsData['전국'];
        document.getElementById('statsLocation').textContent = '전국 (2025년 기준)';
        document.getElementById('fraudCount').textContent = nationalStats.count + '건';
        document.getElementById('fraudAmount').textContent = nationalStats.amount;
        document.getElementById('riskLevel').textContent = nationalStats.risk;
        
        // 전국 통계에 맞는 색상 적용
        const riskLevelElement = document.getElementById('riskLevel');
        const fraudStatsCard = document.getElementById('fraudStatsCard');
        
        // 기존 색상 클래스 제거
        fraudStatsCard.classList.remove('risk-low', 'risk-medium', 'risk-high', 'risk-very-low');
        
        // 전국 통계 위험도에 따른 색상 적용
        fraudStatsCard.classList.add('risk-medium');
        riskLevelElement.style.color = '#f59e0b';
    }
}

/**
 * ========================================
 * EmailJS 이메일 전송
 * ========================================
 */

async function sendEmailNotifications(templateParams) {
    try {
        const adminPromise = emailjs.send(
            EMAILJS_CONFIG.serviceId,
            EMAILJS_CONFIG.templateId,
            {
                ...templateParams,
                to_email: EMAILJS_CONFIG.adminEmail,
                reply_to: templateParams.userEmail
            },
            EMAILJS_CONFIG.publicKey
        );

        const customerPromise = emailjs.send(
            EMAILJS_CONFIG.serviceId,
            EMAILJS_CONFIG.templateId,
            {
                ...templateParams,
                to_email: templateParams.userEmail
            },
            EMAILJS_CONFIG.publicKey
        );

        const [adminResult, customerResult] = await Promise.allSettled([adminPromise, customerPromise]);
        const adminSuccess = adminResult.status === 'fulfilled';
        const customerSuccess = customerResult.status === 'fulfilled';

        if (!adminSuccess) console.error('❌ 관리자 알림 전송 실패:', adminResult.reason);
        if (!customerSuccess) console.error('❌ 고객 확인 메일 전송 실패:', customerResult.reason);

        return { adminSuccess, customerSuccess };

    } catch (error) {
        console.error('❌ 이메일 전송 과정 중 심각한 오류 발생:', error);
        return { adminSuccess: false, customerSuccess: false };
    }
}

/**
 * ========================================
 * DOM 로드 시 초기화
 * ========================================
 */

document.addEventListener('DOMContentLoaded', () => {
    
    // 옵션 버튼 클릭 이벤트 추가
    document.querySelectorAll('.option-btn').forEach(button => {
        button.addEventListener('click', function() {
            // 같은 단계의 다른 버튼들에서 selected 클래스 제거
            const currentStepElement = this.closest('.step-content');
            currentStepElement.querySelectorAll('.option-btn').forEach(btn => {
                btn.classList.remove('selected');
            });
            
            // 클릭한 버튼에 selected 클래스 추가
            this.classList.add('selected');
            
            // 데이터 저장
            saveCurrentStepData();
            
            // 1단계에서 거래 유형 선택 시 월세 입력란 토글
            if (currentStepElement.getAttribute('data-step') === '1') {
                toggleMonthlyRentSection();
            }
            
            // 버튼 상태 업데이트
            updateNavigationButtons();
        });
    });
    
    // 입력 필드 실시간 검증 이벤트 추가
    const amountInput = document.getElementById('amountInput');
    if (amountInput) {
        amountInput.addEventListener('input', updateNavigationButtons);
    }
    
    const addressInputs = document.querySelectorAll('#addressCityDistrict, #addressDetail');
    addressInputs.forEach(input => {
        input.addEventListener('input', updateNavigationButtons);
    });
    
    const personalInfoInputs = document.querySelectorAll('#userName, #userPhone, #userEmail');
    personalInfoInputs.forEach(input => {
        input.addEventListener('input', updateNavigationButtons);
    });
    
    const privacyAgreement = document.getElementById('privacyAgreement');
    if (privacyAgreement) {
        privacyAgreement.addEventListener('change', updateNavigationButtons);
    }
    
    const monthlyAmountInput = document.getElementById('monthlyAmountInput');
    if (monthlyAmountInput) {
        monthlyAmountInput.addEventListener('input', updateNavigationButtons);
    }
    
    // FAQ 토글 기능
    const faqItems = document.querySelectorAll('.faq-item');
    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        question.addEventListener('click', () => {
            const isActive = item.classList.contains('active');
            
            // 모든 FAQ 아이템 닫기
            faqItems.forEach(faqItem => {
                faqItem.classList.remove('active');
            });
            
            // 클릭한 아이템만 열기 (토글)
            if (!isActive) {
                item.classList.add('active');
            }
        });
    });
    
    // Problem Card 클릭 기능
    const problemCards = document.querySelectorAll('.problem-card');
    problemCards.forEach(card => {
        card.addEventListener('click', () => {
            // 모든 problem-card에서 active 클래스 제거
            problemCards.forEach(problemCard => {
                problemCard.classList.remove('active');
            });
            
            // 클릭한 카드에 active 클래스 추가
            card.classList.add('active');
        });
    });
    
    // 카운터 애니메이션
    const counterNumbers = document.querySelectorAll('.counter-number');
    const animateCounter = (element) => {
        const targetStr = element.getAttribute('data-target');
        const target = parseFloat(targetStr.replace(/,/g, ''));
        const duration = 2000; // 2초
        const start = performance.now();
        
        const updateCounter = (currentTime) => {
            const elapsed = currentTime - start;
            const progress = Math.min(elapsed / duration, 1);
            
            const current = target * progress;
            
            // 숫자 포맷팅 (천 단위 콤마 추가)
            if (targetStr.includes(',')) {
                element.textContent = Math.floor(current).toLocaleString();
            } else if (target % 1 === 0) {
                element.textContent = Math.floor(current);
            } else {
                element.textContent = current.toFixed(1);
            }
            
            if (progress < 1) {
                requestAnimationFrame(updateCounter);
            }
        };
        
        requestAnimationFrame(updateCounter);
    };
    
    // Intersection Observer로 카운터 애니메이션 트리거
    const counterObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                animateCounter(entry.target);
                counterObserver.unobserve(entry.target);
            }
        });
    });
    
    // 점수에 따른 색상 계산 함수 (range-fill 그라데이션과 정확히 일치)
    const getScoreColor = (score) => {
        // range-fill의 그라데이션: linear-gradient(90deg, #dc2626 0%, #f59e0b 50%, #10b981 100%)
        // 0-30: 빨간색 (#dc2626)
        // 31-60: 주황색 (#f59e0b) 
        // 61-100: 초록색 (#10b981)
        
        if (score >= 0 && score <= 30) {
            return '#dc2626'; // 위험 - 빨간색
        } else if (score >= 31 && score <= 60) {
            return '#f59e0b'; // 주의 - 주황색
        } else if (score >= 61 && score <= 100) {
            return '#10b981'; // 보통/안전 - 초록색
        }
        return '#10b981'; // 기본값
    };

    // Range-fill 애니메이션 트리거
    const rangeFillObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const rangeFill = entry.target.querySelector('.range-fill');
                const scoreCircle = document.querySelector('.score-circle');
                
                if (rangeFill) {
                    // 약간의 지연 후 애니메이션 시작 (모바일 호환성)
                    setTimeout(() => {
                        rangeFill.classList.add('animate');
                        
                        // score-circle 색상 업데이트
                        if (scoreCircle) {
                            const currentScore = 85; // 현재 점수
                            const scoreColor = getScoreColor(currentScore);
                            
                            // score-circle 배경색 업데이트 (부드러운 그라데이션)
                            scoreCircle.style.background = `linear-gradient(135deg, ${scoreColor}20, ${scoreColor}10, white)`;
                            scoreCircle.style.borderColor = scoreColor;
                            scoreCircle.style.boxShadow = `0 8px 25px ${scoreColor}30, 0 0 0 1px ${scoreColor}20`;
                            
                            // score-circle::before 요소도 업데이트 (외곽 글로우 효과)
                            const style = document.createElement('style');
                            style.id = 'score-circle-dynamic-style';
                            style.textContent = `
                                .score-circle::before {
                                    background: radial-gradient(circle, ${scoreColor}30 0%, ${scoreColor}10 50%, transparent 100%) !important;
                                    opacity: 0.8 !important;
                                }
                            `;
                            // 기존 동적 스타일 제거 후 새로 추가
                            const existingStyle = document.getElementById('score-circle-dynamic-style');
                            if (existingStyle) {
                                existingStyle.remove();
                            }
                            document.head.appendChild(style);
                        }
                    }, 300);
                }
                rangeFillObserver.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.3, // 30% 보일 때 트리거
        rootMargin: '0px 0px -50px 0px' // 하단에서 50px 전에 트리거
    });
    
    counterNumbers.forEach(counter => {
        counterObserver.observe(counter);
    });
    
    // Range-fill 애니메이션을 위한 섹션 관찰
    const scoreAnalysisSection = document.querySelector('.score-analysis');
    if (scoreAnalysisSection) {
        rangeFillObserver.observe(scoreAnalysisSection);
    }
    
    // 걱정 말풍선 클릭 기능 (선택사항)
    const worryBubbles = document.querySelectorAll('.worry-bubble');
    worryBubbles.forEach(bubble => {
        bubble.addEventListener('click', () => {
            // 말풍선 클릭 시 약간의 애니메이션 효과
            bubble.style.transform = 'scale(1.02)';
            setTimeout(() => {
                bubble.style.transform = 'scale(1)';
            }, 150);
            
            const scenario = bubble.getAttribute('data-scenario');
            console.log(`걱정 상황 ${scenario} 클릭됨`);
        });
    });
    
    // Problem Card 네비게이션 기능
    let currentProblemCard = 1;
    const totalProblemCards = 3;
    
    window.changeProblemCard = function(direction) {
        const newIndex = currentProblemCard + direction;
        
        // 마지막 카드에서 다음 버튼을 누를 때 curiosity 섹션으로 스크롤
        if (direction > 0 && currentProblemCard === totalProblemCards) {
            const curiositySection = document.getElementById('curiosity');
            if (curiositySection) {
                curiositySection.scrollIntoView({ 
                    behavior: 'smooth',
                    block: 'start'
                });
            }
            return;
        }
        
        if (newIndex >= 1 && newIndex <= totalProblemCards) {
            const currentCard = document.querySelector(`.problem-card[data-card="${currentProblemCard}"]`);
            const newCard = document.querySelector(`.problem-card[data-card="${newIndex}"]`);
            
            // 현재 카드 슬라이드 아웃 애니메이션
            if (direction > 0) {
                currentCard.classList.add('slide-out-left');
            } else {
                currentCard.classList.add('slide-out-right');
            }
            
            // 새 카드 준비 (슬라이드 인 위치)
            if (direction > 0) {
                newCard.classList.add('slide-in-right');
            } else {
                newCard.classList.add('slide-in-left');
            }
            
            // 애니메이션 완료 후 상태 업데이트
            setTimeout(() => {
                // 현재 카드에서 active와 슬라이드 클래스 제거
                currentCard.classList.remove('active', 'slide-out-left', 'slide-out-right');
                document.querySelector(`.progress-step[data-step="${currentProblemCard}"]`).classList.remove('active');
                document.querySelector(`.dot[data-dot="${currentProblemCard}"]`).classList.remove('active');
                
                // 새 카드에서 슬라이드 인 클래스 제거하고 active 추가
                currentProblemCard = newIndex;
                newCard.classList.remove('slide-in-left', 'slide-in-right');
                newCard.classList.add('active');
                document.querySelector(`.progress-step[data-step="${currentProblemCard}"]`).classList.add('active');
                document.querySelector(`.dot[data-dot="${currentProblemCard}"]`).classList.add('active');
                
                // 버튼 상태 업데이트
                updateNavigationButtons();
            }, 300); // transition 시간과 동일
        }
    };
    
    function updateProblemCardNavigationButtons() {
        const prevButton = document.querySelector('.nav-button.prev');
        const nextButton = document.querySelector('.nav-button.next');
        
        prevButton.disabled = currentProblemCard === 1;
        // 마지막 카드에서도 다음 버튼을 활성화 (curiosity 섹션으로 이동)
        nextButton.disabled = false;
    }
    
    // 도트 클릭 기능
    document.querySelectorAll('.dot').forEach(dot => {
        dot.addEventListener('click', () => {
            const targetCard = parseInt(dot.getAttribute('data-dot'));
            if (targetCard !== currentProblemCard) {
                const direction = targetCard - currentProblemCard;
                changeProblemCard(direction);
            }
        });
    });
    
    // 초기 버튼 상태 설정
    updateProblemCardNavigationButtons();
    
    // CTA 버튼 이벤트 리스너 추가
    const heroCta = document.getElementById('hero-cta');
    if (heroCta) {
        heroCta.addEventListener('click', function(e) {
            e.preventDefault();
            scrollToSection('curiosity');
        });
    }
    
    // 모든 CTA 버튼에 클릭 이벤트 추가
    const ctaButtons = document.querySelectorAll('.cta-button');
    ctaButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            
            // onclick 속성 실행
            const onclickAttr = this.getAttribute('onclick');
            if (onclickAttr) {
                eval(onclickAttr);
            }
        });
    });
    
    // 섹션 애니메이션 초기화
    initSectionAnimations();
    
    // Verification Cases 애니메이션 초기화
    initVerificationCasesAnimation();
    
    // 초기 전세사기 통계 표시 (전국 통계)
    updateFraudStats();
    
    // ✨ [신규 추가] Modal First UX: 페이지 로드 시 모달을 자동으로 띄우는 로직
    // openModal() 함수는 모달을 열고, body에 modal-open 클래스를 추가함
    // 이 때 body에는 이미 modal-first-active 클래스가 있으므로, 모달 외 섹션은 숨겨진 상태 유지
    setTimeout(() => {
        openModal();
    }, 100); // 아주 짧은 지연시간(100ms)을 주어 CSS가 적용된 후 모달이 뜨게 함
});

/**
 * ========================================
 * 기타 유틸리티 함수들
 * ========================================
 */

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        document.querySelector(this.getAttribute('href')).scrollIntoView({
            behavior: 'smooth'
        });
    });
});

// Scroll to section function
function scrollToSection(sectionId) {
    console.log('Attempting to scroll to:', sectionId);
    const element = document.getElementById(sectionId);
    if (element) {
        console.log('Element found, scrolling...');
        element.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
    } else {
        console.error('Element not found:', sectionId);
    }
}

// Make scrollToSection globally available
window.scrollToSection = scrollToSection;

// Steps accordion functionality
function toggleStep(stepNumber) {
    const stepItem = document.querySelector(`.step-item[data-step="${stepNumber}"]`);
    const isActive = stepItem.classList.contains('active');
    
    // Close all other steps
    document.querySelectorAll('.step-item').forEach(item => {
        item.classList.remove('active');
    });
    
    // Toggle current step
    if (!isActive) {
        stepItem.classList.add('active');
    }
}

// Make toggleStep globally available
window.toggleStep = toggleStep;

// Verification Cases 순차적 애니메이션
function initVerificationCasesAnimation() {
    const verificationCases = document.querySelector('.verification-cases');
    if (verificationCases) {
        const caseItems = verificationCases.querySelectorAll('.case-item');
        const warningBox = verificationCases.querySelector('.cases-warning');
        
        const animateCases = () => {
            // 각 카드를 순차적으로 애니메이션
            caseItems.forEach((item, index) => {
                const delay = parseInt(item.getAttribute('data-delay')) || index * 200;
                
                setTimeout(() => {
                    item.classList.add('animate-in');
                    
                    // 카드가 나타날 때 약간의 진동 효과
                    setTimeout(() => {
                        item.style.transform = 'translateX(0) scale(1.02)';
                        setTimeout(() => {
                            item.style.transform = 'translateX(0) scale(1)';
                        }, 100);
                    }, 50);
                }, delay);
            });
            
            // 마지막에 경고 메시지 애니메이션
            if (warningBox) {
                const warningDelay = parseInt(warningBox.getAttribute('data-delay')) || 800;
                setTimeout(() => {
                    warningBox.classList.add('animate-in');
                    
                    // 경고 메시지에 펄스 효과
                    setTimeout(() => {
                        warningBox.style.animation = 'pulse 0.6s ease-in-out';
                        setTimeout(() => {
                            warningBox.style.animation = '';
                        }, 600);
                    }, 300);
                }, warningDelay);
            }
        };
        
        // Intersection Observer로 섹션이 보일 때 애니메이션 시작
        const casesObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    animateCases();
                    casesObserver.unobserve(entry.target);
                }
            });
        }, { threshold: 0.3 });
        
        casesObserver.observe(verificationCases);
    }
}

// 섹션별 애니메이션 로직
function initSectionAnimations() {
    // Intersection Observer 설정
    const observerOptions = {
        threshold: 0.2,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const sectionObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const section = entry.target;
                
                // 섹션에 animate 클래스 추가
                section.classList.add('animate');
                
                // 섹션 내부의 아이템들에 순차적으로 animate 클래스 추가
                const items = section.querySelectorAll('.breakdown-item, .caution-item, .improvement-item');
                items.forEach((item, index) => {
                    setTimeout(() => {
                        item.classList.add('animate');
                    }, index * 200); // 200ms 간격으로 순차 애니메이션
                });
                
                // 한 번만 실행되도록 observer 해제
                sectionObserver.unobserve(section);
            }
        });
    }, observerOptions);
    
    // 애니메이션 대상 섹션들 관찰 시작
    const sections = document.querySelectorAll('.score-breakdown, .caution-section, .improvement-section');
    sections.forEach(section => {
        sectionObserver.observe(section);
    });
}