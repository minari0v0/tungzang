document.addEventListener("DOMContentLoaded", () => {
    // 스크롤 이벤트 리스너
    window.addEventListener("scroll", () => {
        // 스크롤 위치에 따른 히어로 섹션 효과
        const heroSection = document.getElementById("hero")
        const scrollPosition = window.scrollY

        if (heroSection) {
            const scale = 1 + scrollPosition * 0.0005
            const opacity = 1 - scrollPosition * 0.001

            heroSection.style.transform = `scale(${Math.min(scale, 1.2)})`
            heroSection.style.opacity = Math.max(opacity, 0.4)
        }

        // 요소가 화면에 보일 때 애니메이션 적용
        animateOnScroll()
    })

    // 초기 애니메이션 실행
    animateOnScroll()

    // 스크롤 버튼 클릭 이벤트
    const scrollButton = document.querySelector(".scroll-indicator")
    if (scrollButton) {
        scrollButton.addEventListener("click", () => {
            const featuresSection = document.getElementById("features")
            if (featuresSection) {
                featuresSection.scrollIntoView({ behavior: "smooth" })
            }
        })
    }

    // 특징 카드 애니메이션
    const featureCards = document.querySelectorAll(".feature-card")
    featureCards.forEach((card, index) => {
        setTimeout(
            () => {
                card.style.opacity = "1"
                card.style.transform = "translateY(0)"
            },
            300 * (index + 1),
        )
    })

    // CTA 섹션 애니메이션
    const ctaSection = document.querySelector(".cta-section")
    if (ctaSection) {
        setTimeout(() => {
            ctaSection.style.opacity = "1"
            ctaSection.style.transform = "scale(1)"
        }, 1000)
    }
})

// 요소가 화면에 보일 때 애니메이션 적용하는 함수
function animateOnScroll() {
    const elements = document.querySelectorAll(".feature-card, .cta-section, .story-content")

    elements.forEach((element) => {
        const elementPosition = element.getBoundingClientRect().top
        const windowHeight = window.innerHeight

        if (elementPosition < windowHeight * 0.8) {
            element.style.opacity = "1"
            element.style.transform = element.classList.contains("cta-section") ? "scale(1)" : "translateY(0)"
        }
    })
}
