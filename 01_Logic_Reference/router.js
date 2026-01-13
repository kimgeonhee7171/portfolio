/**

 * SPA Router - 페이지 라우팅 및 전환 관리
 * 보증지킴이 프로젝트용
 */

class Router {
    constructor() {
        this.routes = {
            '/': 'home',
            '/index': 'home',
            '/index.html': 'home',
            '/home': 'home',
            '/about': 'about',
            '/services': 'services',
            '/cases': 'cases',
            '/contact': 'contact'
        };
        
        // 섹션 ID 매핑
        this.sectionMap = {
            'home': 'hero',
            'about': 'problem-solution',
            'services': 'curiosity',
            'cases': 'testimonials',
            'contact': 'faq-section'
        };
        
        this.currentPage = 'home';
        this.init();
    }
    
    init() {
        // 초기 페이지 로드
        window.addEventListener('DOMContentLoaded', () => {
            this.handleRoute();
            this.initNavigation();
        });
        
        // 브라우저 뒤로/앞으로 버튼 처리
        window.addEventListener('popstate', () => {
            this.handleRoute();
        });
        
        // 네비게이션 링크 클릭 이벤트 위임
        document.addEventListener('click', (e) => {
            const link = e.target.closest('a[data-page]');
            if (link) {
                e.preventDefault();
                const page = link.getAttribute('data-page');
                this.navigate(page);
            }
        });
    }
    
    initNavigation() {
        // 모바일 네비게이션 토글 기능
        const navToggle = document.querySelector('.nav-toggle');
        const navMenu = document.querySelector('.nav-menu');
        
        if (navToggle && navMenu) {
            navToggle.addEventListener('click', () => {
                navMenu.classList.toggle('active');
                navToggle.classList.toggle('active');
            });
            
            // 메뉴 항목 클릭 시 모바일 메뉴 닫기
            navMenu.querySelectorAll('a').forEach(link => {
                link.addEventListener('click', () => {
                    navMenu.classList.remove('active');
                    navToggle.classList.remove('active');
                });
            });
        }
        
        // 스크롤 시 네비게이션 바 스타일 변경
        let lastScroll = 0;
        const navbar = document.querySelector('.navbar');
        
        window.addEventListener('scroll', () => {
            const currentScroll = window.pageYOffset;
            
            if (currentScroll > 50) {
                navbar?.classList.add('scrolled');
            } else {
                navbar?.classList.remove('scrolled');
            }
            
            lastScroll = currentScroll;
        });
    }
    
    getCurrentPath() {
        return window.location.pathname;
    }
    
    getPageFromPath(path) {
        const normalizedPath = path.toLowerCase();
        return this.routes[normalizedPath] || this.routes['/'] || 'home';
    }
    
    navigate(page) {
        if (this.currentPage === page) return;
        
        // 섹션 스크롤 네비게이션
        const sectionId = this.sectionMap[page];
        if (sectionId) {
            const section = document.getElementById(sectionId);
            if (section) {
                // 부드러운 스크롤
                const navbarHeight = document.querySelector('.navbar')?.offsetHeight || 0;
                const targetPosition = section.offsetTop - navbarHeight;
                
                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
                
                // URL 업데이트 (히스토리 추가)
                const path = this.getPathFromPage(page);
                window.history.pushState({ page }, '', path);
                
                // 활성 링크 업데이트
                this.updateActiveLink(page);
                this.currentPage = page;
                
                return;
            }
        }
        
        // 페이지가 없는 경우 기본 동작
        console.warn(`페이지를 찾을 수 없습니다: ${page}`);
    }
    
    handleRoute() {
        const path = this.getCurrentPath();
        const page = this.getPageFromPath(path);
        
        // 초기 로드 시 해당 섹션으로 스크롤
        if (page !== 'home') {
            const sectionId = this.sectionMap[page];
            if (sectionId) {
                setTimeout(() => {
                    const section = document.getElementById(sectionId);
                    if (section) {
                        const navbarHeight = document.querySelector('.navbar')?.offsetHeight || 0;
                        const targetPosition = section.offsetTop - navbarHeight;
                        window.scrollTo({
                            top: targetPosition,
                            behavior: 'smooth'
                        });
                    }
                }, 100);
            }
        }
        
        this.updateActiveLink(page);
        this.currentPage = page;
    }
    
    updateActiveLink(page) {
        // 모든 링크에서 active 클래스 제거
        document.querySelectorAll('a[data-page]').forEach(link => {
            link.classList.remove('active');
        });
        
        // 현재 페이지 링크에 active 클래스 추가
        const activeLink = document.querySelector(`a[data-page="${page}"]`);
        if (activeLink) {
            activeLink.classList.add('active');
        }
    }
    
    getPathFromPage(page) {
        if (page === 'home') return '/';
        return `/${page}`;
    }
}

// 전역 라우터 인스턴스 생성
const router = new Router();

