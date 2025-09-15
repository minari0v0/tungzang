/**
 * 배지 컬렉션 페이지 스크립트
 */
$(document).ready(() => {
    // 진행률 원형 차트 애니메이션
    animateProgressCircle()

    // 배지 카드 3D 효과
    setupBadgeCardEffects()

    // 탭 전환 애니메이션
    setupTabAnimations()

    // 카운터 애니메이션
    animateCounters()

    // 로그인 체크
    checkLoginStatus()
})

/**
 * 진행률 원형 차트 애니메이션
 */
function animateProgressCircle() {
    const circle = document.querySelector(".progress-circle")
    const percentage = Number.parseFloat(document.querySelector(".progress-text").textContent)

    if (circle) {
        setTimeout(() => {
            circle.style.background = `conic-gradient(#10b981 ${percentage * 3.6}deg, rgba(255,255,255,0.2) 0deg)`
        }, 500)
    }
}

/**
 * 배지 카드 3D 효과 설정
 */
function setupBadgeCardEffects() {
    $(".badge-card").each(function () {
        $(this).on("mousemove", (e) => {
            const rect = this.getBoundingClientRect()
            const x = e.clientX - rect.left
            const y = e.clientY - rect.top

            const centerX = rect.width / 2
            const centerY = rect.height / 2

            const rotateX = (y - centerY) / 10
            const rotateY = (centerX - x) / 10

            $(this).css("transform", `translateY(-10px) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`)
        })

        $(this).on("mouseleave", () => {
            $(this).css("transform", "translateY(0) rotateX(0) rotateY(0)")
        })
    })
}

/**
 * 탭 전환 애니메이션 설정
 */
function setupTabAnimations() {
    $('button[data-bs-toggle="pill"]').on("shown.bs.tab", (e) => {
        const target = $(e.target).attr("data-bs-target")
        $(target)
            .find(".badge-card")
            .each(function (index) {
                $(this).removeClass("animate__fadeInUp")
                setTimeout(() => {
                    $(this).addClass("animate__fadeInUp")
                }, index * 100)
            })
    })
}

/**
 * 카운터 애니메이션
 */
function animateCounters() {
    $(".stats-number").each(function () {
        const $this = $(this)
        const countTo = Number.parseInt($this.text())

        $({ countNum: 0 }).animate(
            {
                countNum: countTo,
            },
            {
                duration: 2000,
                easing: "swing",
                step: function () {
                    $this.text(Math.floor(this.countNum))
                },
                complete: () => {
                    $this.text(countTo)
                },
            },
        )
    })
}

/**
 * 로그인 상태 확인
 */
function checkLoginStatus() {
    // 로그인 상태 확인 로직은 서버에서 처리
    // 로그인이 필요한 경우 서버에서 모달을 표시하도록 설정
}

/**
 * 로그인 모달 닫기
 */
function closeLoginModal() {
    const overlay = document.getElementById("loginModalOverlay")
    if (overlay) {
        overlay.classList.remove("show")
        setTimeout(() => {
            overlay.style.display = "none"
            window.location.href = contextPath + "/"
        }, 300)
    }
}

/**
 * 로그인 페이지로 이동
 */
function goToLogin() {
    window.location.href = contextPath + "/login.jsp?redirect=badges"
}

// 모달 외부 클릭 시 닫기
$(document).ready(() => {
    $("#loginModalOverlay").on("click", function (e) {
        if (e.target === this) {
            closeLoginModal()
        }
    })
})

/**
 * 다크 모드 감지 및 적용
 */
function applyDarkModeToElements() {
    const isDarkMode = document.body.classList.contains("dark-mode")

    if (isDarkMode) {
        // 다크 모드 특정 스타일 적용
        $(".progress-circle").css("box-shadow", "0 0 20px rgba(0, 0, 0, 0.5)")
    } else {
        // 라이트 모드 특정 스타일 적용
        $(".progress-circle").css("box-shadow", "0 0 20px rgba(126, 34, 206, 0.3)")
    }
}

// 다크 모드 변경 감지
const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
        if (mutation.attributeName === "class") {
            applyDarkModeToElements()
        }
    })
})

// 다크 모드 감지 설정
$(document).ready(() => {
    observer.observe(document.body, { attributes: true })
    applyDarkModeToElements()
})

document.addEventListener("DOMContentLoaded", () => {
    const header = document.querySelector(".badge-collection-header")

    if (header) {
        header.addEventListener("mousemove", (e) => {
            // 헤더 내에서의 마우스 상대 위치 계산 (%)
            const rect = header.getBoundingClientRect()
            const x = ((e.clientX - rect.left) / rect.width) * 100
            const y = ((e.clientY - rect.top) / rect.height) * 100

            // CSS 변수 업데이트
            header.style.setProperty("--mouse-x", `${x}%`)
            header.style.setProperty("--mouse-y", `${y}%`)
        })

        // 마우스가 헤더를 벗어날 때 효과 초기화
        header.addEventListener("mouseleave", () => {
            header.style.setProperty("--mouse-x", "50%")
            header.style.setProperty("--mouse-y", "50%")
        })
    }
})
