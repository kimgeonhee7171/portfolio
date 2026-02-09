import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kpostal/kpostal.dart';
import '../../utils/safety_calculator.dart';
import '../report/report_result_screen.dart';

// 진단하기 화면 (7단계 진단 프로세스)
class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  // 현재 진행 단계 (0~6: 총 7단계)
  int _currentStep = 0;

  // 7단계 진단 데이터 저장 변수
  String _contractType = ''; // Step 1: 계약유형 (월세/전세/반전세/매매)
  String _situation = ''; // Step 2: 현재 상황 (계약 예정/거주 중/계약 만료 전)
  String _deposit = ''; // Step 3: 보증금 (숫자 문자열, 만원 단위)
  String _monthlyRent = ''; // Step 3: 월세 (숫자 문자열, 만원 단위)
  String _marketPrice = ''; // Step 3: 매매가/시세 (숫자 문자열, 만원 단위)
  String _priorCredit = ''; // Step 3: 선순위 채권(근저당) (숫자 문자열, 만원 단위)
  String _period = ''; // Step 4: 계약 기간 (1년/2년/기타)
  String _address = ''; // Step 5: 주소 (도로명 주소)
  String _detailAddress = ''; // Step 5: 상세 주소 (동, 호수 등)
  String _landlordName = ''; // Step 6: 임대인(집주인) 이름 (블랙리스트 대조용)
  String _userName = ''; // Step 6: 이름
  String _userPhone = ''; // Step 6: 전화번호 (010-0000-0000)

  // Step 2. 추가 위험 요소 (7-Layer S-GSE)
  bool _isViolatedArchitecture = false; // 위반건축물 표기 여부
  bool _isTaxArrears = true; // 국세/지방세 완납 확인 여부 (미납 없음 = true)

  // 등기부등본 OCR (향후 AI 연동)
  bool _ocrCompleted = false; // OCR 분석 완료 여부
  bool _isOcrLoading = false; // OCR 분석 중 여부

  // TextField 컨트롤러
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _monthlyController = TextEditingController();
  final TextEditingController _marketPriceController = TextEditingController();
  final TextEditingController _priorCreditController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController =
      TextEditingController();
  final TextEditingController _landlordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // 금액 포맷팅 무한 루프 방지 플래그
  bool _isFormattingDeposit = false;
  bool _isFormattingMonthly = false;
  bool _isFormattingMarketPrice = false;
  bool _isFormattingPriorCredit = false;

  @override
  void initState() {
    super.initState();
    // 금액 입력 필드에 실시간 포맷팅 리스너 추가
    _depositController.addListener(_onDepositChanged);
    _monthlyController.addListener(_onMonthlyChanged);
    _marketPriceController.addListener(_onMarketPriceChanged);
    _priorCreditController.addListener(_onPriorCreditChanged);
    // 연락처 입력 필드에 리스너 추가
    _landlordController.addListener(_onLandlordChanged);
    _nameController.addListener(_onNameChanged);
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    // 컨트롤러 해제 (메모리 누수 방지)
    _depositController.dispose();
    _monthlyController.dispose();
    _marketPriceController.dispose();
    _priorCreditController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _landlordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // 보증금 입력 실시간 포맷팅 (콤마 자동 추가)
  void _onDepositChanged() {
    if (_isFormattingDeposit) return; // 재귀 호출 방지

    final text = _depositController.text.replaceAll(',', '');
    if (text.isEmpty) {
      setState(() => _deposit = '');
      return;
    }

    final number = int.tryParse(text);
    if (number == null) return;

    final formatted = _formatNumber(number);
    if (formatted != _depositController.text) {
      _isFormattingDeposit = true;

      _depositController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );

      setState(() => _deposit = number.toString());
      _isFormattingDeposit = false;
    }
  }

  // 월세 입력 실시간 포맷팅 (콤마 자동 추가)
  void _onMonthlyChanged() {
    if (_isFormattingMonthly) return; // 재귀 호출 방지

    final text = _monthlyController.text.replaceAll(',', '');
    if (text.isEmpty) {
      setState(() => _monthlyRent = '');
      return;
    }

    final number = int.tryParse(text);
    if (number == null) return;

    final formatted = _formatNumber(number);
    if (formatted != _monthlyController.text) {
      _isFormattingMonthly = true;

      _monthlyController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );

      setState(() => _monthlyRent = number.toString());
      _isFormattingMonthly = false;
    }
  }

  // 매매가 입력 실시간 포맷팅 (콤마 자동 추가)
  void _onMarketPriceChanged() {
    if (_isFormattingMarketPrice) return; // 재귀 호출 방지

    final text = _marketPriceController.text.replaceAll(',', '');
    if (text.isEmpty) {
      setState(() => _marketPrice = '');
      return;
    }

    final number = int.tryParse(text);
    if (number == null) return;

    final formatted = _formatNumber(number);
    if (formatted != _marketPriceController.text) {
      _isFormattingMarketPrice = true;

      _marketPriceController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );

      setState(() => _marketPrice = number.toString());
      _isFormattingMarketPrice = false;
    }
  }

  // 선순위 채권 입력 실시간 포맷팅 (콤마 자동 추가)
  void _onPriorCreditChanged() {
    if (_isFormattingPriorCredit) return;

    final text = _priorCreditController.text.replaceAll(',', '');
    if (text.isEmpty) {
      setState(() => _priorCredit = '');
      return;
    }

    final number = int.tryParse(text);
    if (number == null) return;

    final formatted = _formatNumber(number);
    if (formatted != _priorCreditController.text) {
      _isFormattingPriorCredit = true;

      _priorCreditController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );

      setState(() => _priorCredit = number.toString());
      _isFormattingPriorCredit = false;
    }
  }

  // 임대인 이름 입력 실시간 저장
  void _onLandlordChanged() {
    setState(() => _landlordName = _landlordController.text);
  }

  // 이름 입력 실시간 저장
  void _onNameChanged() {
    setState(() => _userName = _nameController.text);
  }

  // 전화번호 입력 실시간 저장
  void _onPhoneChanged() {
    setState(() => _userPhone = _phoneController.text);
  }

  // 다음 단계로 이동
  void _nextStep() {
    if (_currentStep < 6) {
      setState(() => _currentStep++);
    } else {
      // Step 7 완료 후 처음으로 돌아가기 & 데이터 초기화
      _resetAllData();
      setState(() => _currentStep = 0);
    }
  }

  // 모든 데이터 초기화
  void _resetAllData() {
    setState(() {
      _contractType = '';
      _situation = '';
      _deposit = '';
      _monthlyRent = '';
      _marketPrice = '';
      _priorCredit = '';
      _period = '';
      _address = '';
      _detailAddress = '';
      _landlordName = '';
      _userName = '';
      _userPhone = '';
      _isViolatedArchitecture = false;
      _isTaxArrears = true;
      _ocrCompleted = false;
    });

    _depositController.clear();
    _monthlyController.clear();
    _marketPriceController.clear();
    _priorCreditController.clear();
    _addressController.clear();
    _detailAddressController.clear();
    _landlordController.clear();
    _nameController.clear();
    _phoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 프로그레스 바 (7단계 진행도 표시)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 7,
                      color: const Color(0xFF1A237E), // Navy
                      backgroundColor: Colors.grey[200],
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentStep + 1}/7',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A237E), // Navy
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getStepTitle(_currentStep),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 스크롤 가능한 컨텐츠 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildStepContent(),
              ),
            ),
            // 하단 버튼 영역 (Step 1~5만 표시)
            if (_currentStep > 0 && _currentStep < 6) _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // 현재 단계에 맞는 UI 렌더링
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1ContractType();
      case 1:
        return _buildStep2Situation();
      case 2:
        return _buildStep3Amount();
      case 3:
        return _buildStep4Period();
      case 4:
        return _buildStep5Address();
      case 5:
        return _buildStep6Contact();
      case 6:
        return _buildStep7Complete();
      default:
        return Container();
    }
  }

  // 각 단계의 제목 반환
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return '계약 유형';
      case 1:
        return '현재 상황';
      case 2:
        return '금액 입력';
      case 3:
        return '계약 기간';
      case 4:
        return '주소 입력';
      case 5:
        return '정보 입력';
      case 6:
        return '분석 시작';
      default:
        return '';
    }
  }

  // ========================================
  // Step 1: 계약유형 선택
  // ========================================
  Widget _buildStep1ContractType() {
    return _buildChoiceStep(
      title: '어떤 유형의 계약인가요?',
      options: ['월세', '전세', '반전세', '매매'],
      onSelect: (value) {
        setState(() => _contractType = value);
        _nextStep();
      },
    );
  }

  // ========================================
  // Step 2: 상황 선택
  // ========================================
  Widget _buildStep2Situation() {
    return _buildChoiceStep(
      title: '현재 어떤 상황이신가요?',
      options: ['계약 예정', '거주 중', '계약 만료 전'],
      onSelect: (value) {
        setState(() => _situation = value);
        _nextStep();
      },
    );
  }

  // ========================================
  // Step 3: 금액 입력 (보증금 + 월세)
  // ========================================
  Widget _buildStep3Amount() {
    // 월세 또는 반전세 계약인지 확인
    final bool isMonthlyRent = _contractType == '월세' || _contractType == '반전세';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          isMonthlyRent ? '보증금과 월세를\n입력해주세요' : '보증금을\n입력해주세요',
        ),

        // --- 보증금 입력 섹션 ---
        const Text(
          '보증금',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A237E), // Navy
          ),
        ),
        const SizedBox(height: 8),
        _buildAmountTextField(_depositController, '보증금 입력'),
        const SizedBox(height: 10),

        // 보증금 빠른 입력 버튼
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAmountButton(_depositController, 10000, '+1억'),
            _buildAmountButton(_depositController, 1000, '+1000만'),
            _buildAmountButton(_depositController, 100, '+100만'),
            _buildAmountButton(_depositController, 0, '초기화', isReset: true),
          ],
        ),

        // --- 월세 입력 섹션 (월세 계약일 때만 표시) ---
        if (isMonthlyRent) ...[
          const SizedBox(height: 30),
          const Text(
            '월세',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1A237E), // Navy
            ),
          ),
          const SizedBox(height: 8),
          _buildAmountTextField(_monthlyController, '월세 입력'),
          const SizedBox(height: 10),

          // 월세 빠른 입력 버튼
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAmountButton(_monthlyController, 10, '+10만'),
              _buildAmountButton(_monthlyController, 5, '+5만'),
              _buildAmountButton(_monthlyController, 1, '+1만'),
              _buildAmountButton(_monthlyController, 0, '초기화', isReset: true),
            ],
          ),
        ],

        // --- 등기부등본 업로드 (전세/반전세/매매일 때만 표시) ---
        if (_contractType != '월세') ...[
          const SizedBox(height: 30),
          const Text(
            '집 시세 & 선순위 채권 확인',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '등기부등본을 업로드하면 AI가 매매가·근저당 정보를 자동 추출합니다.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          _buildRegistryUploadCard(),
          if (_ocrCompleted) _buildOcrResultCard(),
        ],

        // --- Step 2. 추가 위험 요소 확인 ---
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Step 2. 추가 위험 요소 확인',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '건축물·세금 정보를 확인하면 더 정확한 진단이 가능합니다.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isViolatedArchitecture,
                onChanged: (value) {
                  setState(() => _isViolatedArchitecture = value);
                },
                title: const Text(
                  '건축물대장에 \'위반건축물\' 표기가 있나요?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '위반건축물은 전세자금대출·보증보험 가입이 불가할 수 있습니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ),
                activeTrackColor: const Color(0xFF00C853),
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const Divider(height: 24),
              SwitchListTile(
                value: _isTaxArrears,
                onChanged: (value) {
                  setState(() => _isTaxArrears = value);
                },
                title: const Text(
                  '집주인의 국세/지방세 완납 증명서를 확인했나요?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '미납 세금이 없나요? 조세 채권은 보증금보다 우선 변제될 수 있습니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ),
                activeTrackColor: const Color(0xFF00C853),
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 등기부등본 업로드 카드 (점선 테두리)
  Widget _buildRegistryUploadCard() {
    return GestureDetector(
      onTap: _isOcrLoading ? null : () => _simulateOcrExtraction(context),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        dashPattern: const [8, 4],
        color: const Color(0xFF1A237E).withValues(alpha: 0.4),
        strokeWidth: 2,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: const Color(0xFF1A237E).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _ocrCompleted ? '📄 등기부등본' : '📄 등기부등본 파일 업로드/촬영',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _ocrCompleted ? '탭하여 다시 스캔' : '여기를 눌러 문서를 스캔하세요',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // OCR 분석 결과 카드
  Widget _buildOcrResultCard() {
    final marketFormatted = _formatNumber(int.tryParse(_marketPrice) ?? 0);
    final priorFormatted = _formatNumber(int.tryParse(_priorCredit) ?? 0);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00C853).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00C853).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00C853),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '분석 완료',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00C853),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '매매가: $marketFormatted만원 / 채권: $priorFormatted만원',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // OCR 시뮬레이션 (1.5초 후 테스트 데이터 할당)
  Future<void> _simulateOcrExtraction(BuildContext context) async {
    if (_isOcrLoading) return;

    setState(() => _isOcrLoading = true);

    // 1.5초 동안 "문서 분석 중..." 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF1A237E)),
              const SizedBox(height: 24),
              const Text(
                '문서 분석 중...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!context.mounted) return;
    Navigator.of(context).pop(); // 다이얼로그 닫기

    // 테스트 데이터 할당: 매매가 3억, 근저당 1억 2천만
    setState(() {
      _marketPrice = '30000';
      _priorCredit = '12000';
      _marketPriceController.text = '30,000';
      _priorCreditController.text = '12,000';
      _ocrCompleted = true;
      _isOcrLoading = false;
    });
  }

  // ========================================
  // Step 4: 계약 기간 선택
  // ========================================
  Widget _buildStep4Period() {
    return _buildChoiceStep(
      title: '계약 기간은 어떻게 되시나요?',
      options: ['1년', '2년', '기타'],
      onSelect: (value) {
        setState(() => _period = value);
        _nextStep();
      },
    );
  }

  // ========================================
  // Step 5: 주소 검색
  // ========================================
  Widget _buildStep5Address() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('어느 집을\n알아볼까요?'),

        // 도로명 주소 검색
        TextField(
          controller: _addressController,
          readOnly: true,
          onTap: _showAddressSearch,
          decoration: InputDecoration(
            hintText: '주소 검색 (클릭)',
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),

        // 최근 검색한 주소
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '최근 검색한 주소',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildRecentAddressChip('서울시 송파구 위례광장로 100'),
            _buildRecentAddressChip('경기도 성남시 수정구 위례대로 55'),
          ],
        ),

        if (_address.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF1A237E).withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF1A237E), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '선택된 주소',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // 상세 주소 입력 (동, 호수 등)
        TextField(
          controller: _detailAddressController,
          onChanged: (value) {
            setState(() => _detailAddress = value);
          },
          decoration: InputDecoration(
            hintText: '상세 주소 (동, 호수 등)',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.home, color: Color(0xFF1A237E)),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ========================================
  // Step 6: 정보 입력 (임대인 이름 + 이름 + 전화번호)
  // ========================================
  Widget _buildStep6Contact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('마지막으로\n정보를 입력해주세요'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '분석 결과를 받으실 연락처를 입력해주세요',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _loadMyInfo,
              icon: const Icon(
                Icons.person,
                size: 16,
                color: Color(0xFF1A237E),
              ),
              label: const Text(
                '내 정보',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A237E), // Navy
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 임대인(집주인) 이름 입력
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF1A237E).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Dual-Check',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '임대인 검증',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _landlordController,
                hint: '임대인 이름 (선택사항 - 모르면 비워두셔도 됩니다)',
                keyboardType: TextInputType.text,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 사용자 정보 입력
        const Text(
          '사용자 정보',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _nameController,
          hint: '이름',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 12),
        // 전화번호 입력란 (자동 하이픈)
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            PhoneNumberFormatter(),
          ],
          decoration: InputDecoration(
            hintText: '전화번호',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1A237E), // Navy
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ========================================
  // Step 7: S-GSE 분석 화면 (혁신적 로딩 경험)
  // ========================================
  Widget _buildStep7Complete() {
    return _SGSEAnalysisScreen(
      contractType: _contractType,
      situation: _situation,
      deposit: _deposit,
      monthlyRent: _monthlyRent,
      period: _period,
      address: _address,
      detailAddress: _detailAddress,
      landlordName: _landlordName,
      userName: _userName,
      userPhone: _userPhone,
      onComplete: () {
        // 전세가율 계산
        final calculatedScore = _calculateSafetyScore();

        // 분석 완료 후 결과 화면으로 이동 (7-Layer 위험 요소 전달)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportResultScreen(
              contractType: _contractType,
              deposit: _deposit,
              monthlyRent: _monthlyRent,
              marketPrice: _marketPrice,
              priorCredit: _priorCredit,
              address: _address,
              detailAddress: _detailAddress,
              score: calculatedScore,
              isViolatedArchitecture: _isViolatedArchitecture,
              isTaxArrears: _isTaxArrears,
            ),
          ),
        ).then((_) {
          // 결과 화면에서 돌아왔을 때 데이터 초기화
          _resetAllData();
          setState(() => _currentStep = 0);
        });
      },
    );
  }

  // ========================================
  // UI 재사용 위젯들
  // ========================================

  // 선택지 단계 공통 위젯
  Widget _buildChoiceStep({
    required String title,
    required List<String> options,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        ...options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => onSelect(option),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      option,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 섹션 헤더 (제목)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, top: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.3,
          color: Color(0xFF1A237E), // Navy
        ),
      ),
    );
  }

  // 일반 텍스트 입력 필드
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  // 금액 입력 필드 (숫자 전용)
  Widget _buildAmountTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixText: '만원',
        suffixStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  // 금액 빠른 입력 버튼
  Widget _buildAmountButton(
    TextEditingController controller,
    int amount,
    String label, {
    bool isReset = false,
  }) {
    return ElevatedButton(
      onPressed: () {
        if (isReset) {
          // 초기화 버튼
          if (controller == _depositController) {
            _isFormattingDeposit = true;
            controller.clear();
            setState(() => _deposit = '');
            _isFormattingDeposit = false;
          } else if (controller == _monthlyController) {
            _isFormattingMonthly = true;
            controller.clear();
            setState(() => _monthlyRent = '');
            _isFormattingMonthly = false;
          } else if (controller == _marketPriceController) {
            _isFormattingMarketPrice = true;
            controller.clear();
            setState(() => _marketPrice = '');
            _isFormattingMarketPrice = false;
          } else if (controller == _priorCreditController) {
            _isFormattingPriorCredit = true;
            controller.clear();
            setState(() => _priorCredit = '');
            _isFormattingPriorCredit = false;
          }
        } else {
          // 금액 추가 버튼
          final currentText = controller.text.replaceAll(',', '');
          final currentValue = int.tryParse(currentText) ?? 0;
          final newValue = currentValue + amount;
          final formatted = _formatNumber(newValue);

          if (controller == _depositController) {
            _isFormattingDeposit = true;
            controller.text = formatted;
            setState(() => _deposit = newValue.toString());
            _isFormattingDeposit = false;
          } else if (controller == _monthlyController) {
            _isFormattingMonthly = true;
            controller.text = formatted;
            setState(() => _monthlyRent = newValue.toString());
            _isFormattingMonthly = false;
          } else if (controller == _marketPriceController) {
            _isFormattingMarketPrice = true;
            controller.text = formatted;
            setState(() => _marketPrice = newValue.toString());
            _isFormattingMarketPrice = false;
          } else if (controller == _priorCreditController) {
            _isFormattingPriorCredit = true;
            controller.text = formatted;
            setState(() => _priorCredit = newValue.toString());
            _isFormattingPriorCredit = false;
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isReset
            ? Colors.grey[300]
            : const Color(0xFF1A237E).withValues(alpha: 0.1),
        foregroundColor: isReset ? Colors.black87 : const Color(0xFF1A237E),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isReset
                ? Colors.grey[400]!
                : const Color(0xFF1A237E).withValues(alpha: 0.3),
          ),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isReset ? Colors.black87 : const Color(0xFF1A237E),
        ),
      ),
    );
  }

  // 이전 단계로 이동
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // 하단 버튼 영역 (body 안에 포함)
  Widget _buildBottomButtons() {
    // 선택형 단계인지 확인 (Step 1, 3)
    final bool isChoiceStep = _currentStep == 1 || _currentStep == 3;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // [이전] 버튼 (Step 1 이상에서만 표시)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              label: const Text('이전'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // [다음] 버튼 (입력형 단계에서만 표시)
          if (!isChoiceStep)
            Expanded(
              child: ElevatedButton(
                onPressed: _canProceedToNext()
                    ? (_currentStep == 5 ? _startAnalysis : _nextStep)
                    : null, // 비활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canProceedToNext()
                      ? (_currentStep == 5
                            ? const Color(0xFF00C853) // 분석 시작 버튼은 Green
                            : const Color(0xFF1A237E)) // 일반 다음 버튼은 Navy
                      : Colors.grey[300], // 비활성화 시 회색
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  _getNextButtonText(),
                  style: TextStyle(
                    color: _canProceedToNext() ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          // 선택형 단계에서는 오른쪽 공간 비우기
          if (isChoiceStep) Expanded(child: Container()),
        ],
      ),
    );
  }

  // 다음 버튼 활성화 여부 체크
  bool _canProceedToNext() {
    switch (_currentStep) {
      case 2: // Step 3: 금액 입력 - 보증금 필수, 전세/반전세/매매는 등기부등본 OCR 완료 필수
        final depositOk = _deposit.isNotEmpty;
        final ocrOk = _contractType == '월세' || _ocrCompleted;
        return depositOk && ocrOk;
      case 4: // Step 5: 주소 입력 - 주소 필수
        return _address.isNotEmpty;
      case 5: // Step 6: 정보 입력 - 본인 이름과 전화번호만 필수 (임대인 이름은 선택)
        return _userName.isNotEmpty && _userPhone.isNotEmpty;
      default:
        return true; // 나머지 단계는 항상 활성화
    }
  }

  // 다음 버튼 텍스트 반환
  String _getNextButtonText() {
    switch (_currentStep) {
      case 2:
        return '금액 입력 완료';
      case 4:
        return '주소 입력 완료';
      case 5:
        return '분석 시작하기';
      default:
        return '다음';
    }
  }

  // ========================================
  // 헬퍼 함수들
  // ========================================

  // 최근 검색 주소 칩
  Widget _buildRecentAddressChip(String address) {
    return ActionChip(
      label: Text(address, style: const TextStyle(fontSize: 13)),
      avatar: const Icon(Icons.access_time, size: 18),
      backgroundColor: Colors.grey[100],
      side: BorderSide(color: Colors.grey[300]!),
      onPressed: () {
        setState(() {
          _address = address;
          _addressController.text = address;
        });
      },
    );
  }

  // 내 정보 불러오기
  void _loadMyInfo() {
    setState(() {
      _userName = '김건희';
      _nameController.text = '김건희';

      _userPhone = '01012345678';
      _phoneController.text = '010-1234-5678';
    });
  }

  // 분석 시작 (Step 7로 이동)
  void _startAnalysis() {
    // Step 7 (분석 화면)으로 이동
    setState(() => _currentStep = 6);
  }

  // 주소 검색 화면 열기
  Future<void> _showAddressSearch() async {
    Kpostal? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KpostalView()),
    );
    if (result != null) {
      setState(() {
        _address = result.address;
        _addressController.text = _address;
      });
    }
  }

  // 안전도 점수 계산 (SafetyCalculator 유틸리티 사용)
  int _calculateSafetyScore() {
    final depositValue = double.tryParse(_deposit.replaceAll(',', '')) ?? 0;
    final marketValue = double.tryParse(_marketPrice.replaceAll(',', '')) ?? 0;
    final priorValue = double.tryParse(_priorCredit.replaceAll(',', '')) ?? 0;

    // 7-Layer S-GSE: 추가 위험 요소 반영
    final result = SafetyCalculator.calculateSafety(
      deposit: depositValue,
      marketPrice: marketValue,
      priorCredit: priorValue,
      isViolatedArchitecture: _isViolatedArchitecture,
      isTaxArrears: _isTaxArrears,
    );
    return SafetyCalculator.calculateScore(result);
  }

  // 숫자 포맷팅 함수 (천 단위 콤마 추가)
  String _formatNumber(int number) {
    if (number == 0) return '';
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

// ========================================
// 전화번호 자동 하이픈 포매터
// ========================================
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자만 추출
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 최대 11자리까지만 허용
    if (text.length > 11) {
      return oldValue;
    }

    // 하이픈 자동 추가
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 7) {
        formatted += '-';
      }
      formatted += text[i];
    }

    // 커서 위치 계산
    int selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

// ========================================
// Safe-Guard Scoring Engine (S-GSE) 분석 화면
// ========================================
class _SGSEAnalysisScreen extends StatefulWidget {
  final String contractType;
  final String situation;
  final String deposit;
  final String monthlyRent;
  final String period;
  final String address;
  final String detailAddress;
  final String landlordName;
  final String userName;
  final String userPhone;
  final VoidCallback onComplete;

  const _SGSEAnalysisScreen({
    required this.contractType,
    required this.situation,
    required this.deposit,
    required this.monthlyRent,
    required this.period,
    required this.address,
    required this.detailAddress,
    required this.landlordName,
    required this.userName,
    required this.userPhone,
    required this.onComplete,
  });

  @override
  State<_SGSEAnalysisScreen> createState() => _SGSEAnalysisScreenState();
}

class _SGSEAnalysisScreenState extends State<_SGSEAnalysisScreen>
    with SingleTickerProviderStateMixin {
  int _currentPhase = 0;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  final List<String> _analysisPhases = [
    '공적장부(등기/건축물) 실시간 스크래핑 중...',
    'Safe-Guard 엔진 가동 (권리분석 로직)...',
    '임대인 블랙리스트 및 체납 이력 대조 중...',
    'AI + Human 하이브리드 검증 완료!',
  ];

  @override
  void initState() {
    super.initState();

    // 프로그레스 애니메이션 컨트롤러
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 애니메이션 시작
    _animationController.forward();

    // 텍스트 순차 변경 (각 750ms마다)
    _startPhaseAnimation();

    // 3초 후 완료 콜백 실행
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  void _startPhaseAnimation() {
    for (int i = 0; i < _analysisPhases.length; i++) {
      Future.delayed(Duration(milliseconds: i * 750), () {
        if (mounted) {
          setState(() => _currentPhase = i);
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // S-GSE 로고 영역
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1A237E).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Text(
                  'Safe-Guard Scoring Engine',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 원형 프로그레스 인디케이터 (그라데이션)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: _progressAnimation.value,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(
                              const Color(0xFF1A237E), // Navy
                              const Color(0xFF00C853), // Green
                              _progressAnimation.value,
                            )!,
                          ),
                        );
                      },
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Text(
                        '${(_progressAnimation.value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 현재 분석 단계 텍스트 (애니메이션)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _analysisPhases[_currentPhase],
                  key: ValueKey<int>(_currentPhase),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _currentPhase == 3
                        ? const Color(0xFF00C853) // 마지막 단계는 Green
                        : const Color(0xFF1A237E), // Navy
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // 분석 정보 요약
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A237E),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '분석 대상 정보',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('계약 유형', widget.contractType),
                    _buildInfoRow('상황', widget.situation),
                    _buildInfoRow(
                      '보증금',
                      widget.deposit.isNotEmpty ? '${widget.deposit}만원' : '-',
                    ),
                    if (widget.contractType == '월세' ||
                        widget.contractType == '반전세')
                      _buildInfoRow(
                        '월세',
                        widget.monthlyRent.isNotEmpty
                            ? '${widget.monthlyRent}만원'
                            : '-',
                      ),
                    _buildInfoRow('계약 기간', widget.period),
                    _buildInfoRow(
                      '주소',
                      widget.address.isNotEmpty ? widget.address : '-',
                    ),
                    if (widget.detailAddress.isNotEmpty)
                      _buildInfoRow('상세주소', widget.detailAddress),
                    const Divider(height: 24, thickness: 1),
                    _buildInfoRow(
                      '임대인 이름',
                      widget.landlordName.isNotEmpty
                          ? widget.landlordName
                          : '정보 없음 (선택 항목)',
                      highlight: true,
                    ),
                    _buildInfoRow(
                      '신청인',
                      widget.userName.isNotEmpty ? widget.userName : '-',
                    ),
                    _buildInfoRow(
                      '연락처',
                      widget.userPhone.isNotEmpty ? widget.userPhone : '-',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 기술력 강조 텍스트
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF00C853)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Dual-Check: 집(권리) + 집주인(인물) 검증',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: highlight ? const Color(0xFF00C853) : Colors.grey[600],
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: highlight ? const Color(0xFF1A237E) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
