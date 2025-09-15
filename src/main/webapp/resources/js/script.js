/**
 * 텅장수강러 메인 스크립트
 */

// 전역 contextPath 변수 선언
var contextPath = ""

document.addEventListener("DOMContentLoaded", () => {
    console.log("DOM 로드됨")

    // 페이지에서 설정된 contextPath 값 확인
    if (typeof window.contextPath !== "undefined") {
        contextPath = window.contextPath
    } else {
        // contextPath가 설정되지 않은 경우 현재 경로에서 추출
        const path = window.location.pathname
        const segments = path.split("/")
        if (segments.length > 1 && segments[1]) {
            // 첫 번째 세그먼트가 컨텍스트 패스일 가능성이 높음
            contextPath = "/" + segments[1]
        } else {
            contextPath = "" // 루트 컨텍스트
        }
    }

    console.log("설정된 contextPath:", contextPath)

    // 부트스트랩 툴팁 초기화
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    var tooltipList = tooltipTriggerList.map((tooltipTriggerEl) => new bootstrap.Tooltip(tooltipTriggerEl))

    // 부트스트랩 팝오버 초기화
    var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
    var popoverList = popoverTriggerList.map((popoverTriggerEl) => new bootstrap.Popover(popoverTriggerEl))

    // 검색 가능한 드롭다운 초기화 - 이 줄을 추가하세요!
    initSearchableSelect()

    // 스크롤 시 네비게이션 바 스타일 변경
    window.addEventListener("scroll", () => {
        var navbar = document.querySelector(".navbar")
        if (window.scrollY > 50) {
            navbar.classList.add("navbar-scrolled")
        } else {
            navbar.classList.remove("navbar-scrolled")
        }
    })

    // 별점 선택 기능
    setupStarRating()

    // 강의평가 폼 유효성 검사
    setupEvaluationFormValidation()

    // 시간표 관련 기능
    setupTimetable()

    // 검색 기능
    setupSearch()

    // 로그인 폼 유효성 검사
    setupLoginFormValidation()

    // 로그인 모달 초기화
    setupLoginModal()

    // 로그인 필요한 링크에 이벤트 리스너 추가 - 약간의 지연 추가
    setTimeout(() => {
        setupLoginRequiredLinks()
    }, 100)

    // 네비게이션 active 상태 관리
    setupNavigationActiveState()
})

function setupNavigationActiveState() {
    const navLinks = document.querySelectorAll(".navbar-nav .nav-link")
    const currentPath = window.location.pathname

    console.log("현재 경로:", currentPath)
    console.log("모든 네비게이션 링크들:")

    navLinks.forEach((link) => {
        const href = link.getAttribute("href")
        const linkText = link.textContent.trim()

        console.log(`링크: ${linkText}, href: ${href}, 현재 active: ${link.classList.contains("active")}`)

        if (!href) return

        // JSP에서 이미 active 클래스가 설정되어 있다면 그대로 유지
        if (link.classList.contains("active")) {
            console.log(`${linkText} 링크는 이미 active 상태입니다.`)
            return
        }

        // JSP에서 active가 설정되지 않은 경우에만 JavaScript로 처리
        let shouldBeActive = false

        // 각 페이지별 정확한 매칭
        if (href.includes("/timetable") && currentPath.includes("/timetable")) {
            shouldBeActive = true
        } else if (
            href.includes("/evaluation") &&
            (currentPath.includes("/evaluation") || currentPath.includes("/evaluations"))
        ) {
            shouldBeActive = true
        } else if (href.includes("/community") && currentPath.includes("/community")) {
            shouldBeActive = true
        } else if (href.includes("/badges") && currentPath.includes("/badges")) {
            shouldBeActive = true
            console.log("배지 페이지 매칭됨!")
        } else if (
            href === contextPath + "/" &&
            (currentPath === contextPath + "/" || currentPath === contextPath + "/index.jsp")
        ) {
            shouldBeActive = true
        }

        if (shouldBeActive) {
            link.classList.add("active")
            console.log(`${linkText} 링크에 active 클래스 추가됨`)
        }

        // 클릭 시 active 상태 업데이트 - 로그인 필요한 링크는 별도 처리
        link.addEventListener("click", function (e) {
            // 로그인이 필요한 링크는 기존 로직 유지
            if (this.classList.contains("login-required")) {
                return
            }

            // 다른 링크들의 active 클래스 제거
            navLinks.forEach((otherLink) => {
                otherLink.classList.remove("active")
            })

            // 현재 링크에 active 클래스 추가
            this.classList.add("active")
        })
    })
}

/**
 * 별점 선택 기능 설정
 */
function setupStarRating() {
    const starContainers = document.querySelectorAll(".star-rating-input")

    starContainers.forEach((container) => {
        const stars = container.querySelectorAll(".star")
        const ratingInput = container.querySelector('input[type="hidden"]')

        stars.forEach((star, index) => {
            // 마우스 오버 시 별점 미리보기
            star.addEventListener("mouseover", () => {
                for (let i = 0; i <= index; i++) {
                    stars[i].classList.add("filled")
                }
                for (let i = index + 1; i < stars.length; i++) {
                    stars[i].classList.remove("filled")
                }
            })

            // 마우스 아웃 시 원래 별점으로 복원
            star.addEventListener("mouseout", () => {
                const rating = Number.parseInt(ratingInput.value) || 0
                stars.forEach((s, i) => {
                    if (i < rating) {
                        s.classList.add("filled")
                    } else {
                        s.classList.remove("filled")
                    }
                })
            })

            // 클릭 시 별점 선택
            star.addEventListener("click", () => {
                const newRating = index + 1
                ratingInput.value = newRating

                // 선택된 별점 표시
                stars.forEach((s, i) => {
                    if (i < newRating) {
                        s.classList.add("filled")
                    } else {
                        s.classList.remove("filled")
                    }
                })
            })
        })
    })
}

/**
 * 강의평가 폼 유효성 검사
 */
function setupEvaluationFormValidation() {
    const evaluationForm = document.getElementById("evaluationForm")

    if (evaluationForm) {
        evaluationForm.addEventListener("submit", (event) => {
            const courseName = document.getElementById("courseName")
            const professor = document.getElementById("professor")
            const rating = document.getElementById("rating")
            const comment = document.getElementById("comment")

            let isValid = true

            // 강의명 검사
            if (!courseName.value.trim()) {
                showError(courseName, "강의명을 입력해주세요.")
                isValid = false
            } else {
                clearError(courseName)
            }

            // 교수명 검사
            if (!professor.value.trim()) {
                showError(professor, "교수명을 입력해주세요.")
                isValid = false
            } else {
                clearError(professor)
            }

            // 별점 검사
            if (!rating.value || rating.value === "0") {
                showError(document.querySelector(".star-rating-input"), "별점을 선택해주세요.")
                isValid = false
            } else {
                clearError(document.querySelector(".star-rating-input"))
            }

            // 평가 내용 검사
            if (!comment.value.trim()) {
                showError(comment, "평가 내용을 입력해주세요.")
                isValid = false
            } else if (comment.value.trim().length < 10) {
                showError(comment, "평가 내용은 최소 10자 이상 입력해주세요.")
                isValid = false
            } else {
                clearError(comment)
            }

            if (!isValid) {
                event.preventDefault()
            }
        })
    }
}

/**
 * 시간표 관련 기능 설정
 */
function setupTimetable() {
    // 시간표 셀 클릭 이벤트
    const timetableCells = document.querySelectorAll(".timetable-cell")

    timetableCells.forEach((cell) => {
        cell.addEventListener("click", function () {
            const courseId = this.getAttribute("data-course-id")
            if (courseId) {
                // 강의 상세 정보 모달 표시
                showCourseDetails(courseId)
            }
        })
    })

    // 강의 드래그 앤 드롭 기능
    setupDragAndDrop()
}

/**
 * 강의 드래그 앤 드롭 기능 설정
 */
function setupDragAndDrop() {
    const draggableCourses = document.querySelectorAll(".draggable-course")
    const dropZones = document.querySelectorAll(".timetable-cell:not([data-course-id])")

    draggableCourses.forEach((course) => {
        course.setAttribute("draggable", true)

        course.addEventListener("dragstart", function (e) {
            e.dataTransfer.setData("text/plain", this.getAttribute("data-course-id"))
            this.classList.add("dragging")
        })

        course.addEventListener("dragend", function () {
            this.classList.remove("dragging")
        })
    })

    dropZones.forEach((zone) => {
        zone.addEventListener("dragover", function (e) {
            e.preventDefault()
            this.classList.add("drag-over")
        })

        zone.addEventListener("dragleave", function () {
            this.classList.remove("drag-over")
        })

        zone.addEventListener("drop", function (e) {
            e.preventDefault()
            this.classList.remove("drag-over")

            const courseId = e.dataTransfer.getData("text/plain")
            const day = this.getAttribute("data-day")
            const hour = this.getAttribute("data-hour")

            // AJAX 요청으로 시간표 업데이트
            updateTimetable(courseId, day, hour)
        })
    })
}

/**
 * 시간표 업데이트 AJAX 요청
 */
function updateTimetable(courseId, day, hour) {
    const xhr = new XMLHttpRequest()
    xhr.open("POST", contextPath + "/timetable/update", true)
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")

    xhr.onload = () => {
        if (xhr.status === 200) {
            const response = JSON.parse(xhr.responseText)
            if (response.success) {
                // 성공 시 페이지 새로고침
                window.location.reload()
            } else {
                // 오류 메시지 표시
                showToast("error", response.message || "시간표 업데이트에 실패했습니다.")
            }
        } else {
            showToast("error", "서버 오류가 발생했습니다.")
        }
    }

    xhr.onerror = () => {
        showToast("error", "네트워크 오류가 발생했습니다.")
    }

    xhr.send(`courseId=${courseId}&day=${day}&hour=${hour}`)
}

/**
 * 강의 상세 정보 모달 표시
 */
function showCourseDetails(courseId) {
    const xhr = new XMLHttpRequest()
    xhr.open("GET", contextPath + "/courses/" + courseId, true)

    xhr.onload = () => {
        if (xhr.status === 200) {
            const response = JSON.parse(xhr.responseText)

            // 모달 내용 설정
            const modal = new bootstrap.Modal(document.getElementById("courseDetailModal"))
            document.getElementById("modalCourseName").textContent = response.name
            document.getElementById("modalProfessor").textContent = response.professor
            document.getElementById("modalDepartment").textContent = response.department
            document.getElementById("modalRating").textContent = response.rating.toFixed(1)

            // 모달 표시
            modal.show()
        } else {
            showToast("error", "강의 정보를 불러오는데 실패했습니다.")
        }
    }

    xhr.onerror = () => {
        showToast("error", "네트워크 오류가 발생했습니다.")
    }

    xhr.send()
}

/**
 * 검색 기능 설정
 */
function setupSearch() {
    const searchForm = document.getElementById("searchForm")
    const searchInput = document.getElementById("searchInput")

    if (searchForm) {
        searchForm.addEventListener("submit", (event) => {
            if (!searchInput.value.trim()) {
                event.preventDefault()
                showToast("warning", "검색어를 입력해주세요.")
            }
        })
    }
}

/**
 * 로그인 폼 유효성 검사
 */
function setupLoginFormValidation() {
    const loginForm = document.getElementById("loginForm")

    if (loginForm) {
        loginForm.addEventListener("submit", (event) => {
            const username = document.getElementById("username")
            const password = document.getElementById("password")

            let isValid = true

            // 사용자명 검사
            if (!username.value.trim()) {
                showError(username, "사용자명을 입력해주세요.")
                isValid = false
            } else {
                clearError(username)
            }

            // 비밀번호 검사
            if (!password.value) {
                showError(password, "비밀번호를 입력해주세요.")
                isValid = false
            } else {
                clearError(password)
            }

            if (!isValid) {
                event.preventDefault()
            }
        })
    }
}

/**
 * 오류 메시지 표시
 */
function showError(element, message) {
    const formGroup = element.closest(".form-group") || element.closest(".mb-3")
    const errorElement = formGroup.querySelector(".invalid-feedback") || document.createElement("div")

    element.classList.add("is-invalid")

    if (!formGroup.querySelector(".invalid-feedback")) {
        errorElement.className = "invalid-feedback"
        errorElement.textContent = message
        formGroup.appendChild(errorElement)
    } else {
        errorElement.textContent = message
    }
}

/**
 * 오류 메시지 제거
 */
function clearError(element) {
    element.classList.remove("is-invalid")
    const formGroup = element.closest(".form-group") || element.closest(".mb-3")
    const errorElement = formGroup.querySelector(".invalid-feedback")

    if (errorElement) {
        errorElement.textContent = ""
    }
}

/**
 * 토스트 메시지 표시
 */
function showToast(type, message) {
    const toastContainer = document.querySelector(".toast-container") || createToastContainer()
    const toast = document.createElement("div")
    toast.className = "toast"
    toast.setAttribute("role", "alert")
    toast.setAttribute("aria-live", "assertive")
    toast.setAttribute("aria-atomic", "true")

    const iconClass =
        type === "success"
            ? "bi-check-circle-fill"
            : type === "error"
                ? "bi-exclamation-circle-fill"
                : type === "warning"
                    ? "bi-exclamation-triangle-fill"
                    : "bi-info-circle-fill"

    const bgClass =
        type === "success" ? "bg-success" : type === "error" ? "bg-danger" : type === "warning" ? "bg-warning" : "bg-info"

    toast.innerHTML = `
       <div class="toast-header ${bgClass} text-white">
           <i class="bi ${iconClass} me-2"></i>
           <strong class="me-auto">${type.charAt(0).toUpperCase() + type.slice(1)}</strong>
           <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast" aria-label="Close"></button>
       </div>
       <div class="toast-body">
           ${message}
       </div>
   `

    toastContainer.appendChild(toast)

    const bsToast = new bootstrap.Toast(toast, {
        autohide: true,
        delay: 5000,
    })

    bsToast.show()

    // 토스트가 닫힐 때 DOM에서 제거
    toast.addEventListener("hidden.bs.toast", () => {
        toast.remove()
    })
}

/**
 * 토스트 컨테이너 생성
 */
function createToastContainer() {
    const container = document.createElement("div")
    container.className = "toast-container position-fixed bottom-0 end-0 p-3"
    document.body.appendChild(container)
    return container
}

/**
 * 확인 대화상자 표시
 */
function confirmAction(message, callback) {
    if (confirm(message)) {
        callback()
    }
}

/**
 * 삭제 확인
 */
function confirmDelete(url) {
    confirmAction("정말로 삭제하시겠습니까?", () => {
        window.location.href = url
    })
}

/**
 * 로그인 모달 설정
 */
function setupLoginModal() {
    // 모달이 이미 존재하는지 확인
    if (document.getElementById("loginModalOverlay")) {
        return
    }

    // 모달 요소 생성
    const modalOverlay = document.createElement("div")
    modalOverlay.className = "login-modal-overlay"
    modalOverlay.id = "loginModalOverlay"

    const modalHTML = `
    <div class="login-modal">
      <div class="login-modal-header">
        <i class="bi bi-shield-lock"></i>
        <h3>로그인 필요</h3>
      </div>
      <div class="login-modal-body">
        <p>로그인이 필요한 서비스입니다. 로그인하시겠습니까?</p>
      </div>
      <div class="login-modal-footer">
        <button id="loginModalCancel" class="login-modal-btn login-modal-btn-secondary">아니오</button>
        <button id="loginModalConfirm" class="login-modal-btn login-modal-btn-primary">예</button>
      </div>
    </div>
    `

    modalOverlay.innerHTML = modalHTML
    document.body.appendChild(modalOverlay)

    // ESC 키로 모달 닫기
    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape" && modalOverlay.classList.contains("show")) {
            closeLoginModal()
        }
    })

    // 모달 외부 클릭 시 닫기
    modalOverlay.addEventListener("click", (e) => {
        if (e.target === modalOverlay) {
            closeLoginModal()
        }
    })
}

/**
 * 로그인 모달 닫기
 */
function closeLoginModal() {
    const modalOverlay = document.getElementById("loginModalOverlay")
    if (modalOverlay) {
        modalOverlay.classList.remove("show")
        setTimeout(() => {
            modalOverlay.style.display = "none"
        }, 300)
    }
}

/**
 * 로그인 모달 열기
 */
function openLoginModal(redirectUrl) {
    const modalOverlay = document.getElementById("loginModalOverlay")
    if (!modalOverlay) {
        setupLoginModal()
        return openLoginModal(redirectUrl) // 재귀 호출로 모달 생성 후 다시 시도
    }

    // 로그인 확인 버튼 클릭 이벤트
    document.getElementById("loginModalConfirm").onclick = () => {
        window.location.href = contextPath + "/login.jsp?redirect=" + (redirectUrl || "")
    }

    // 취소 버튼 클릭 이벤트
    document.getElementById("loginModalCancel").onclick = () => {
        closeLoginModal()
        // 이전 페이지로 돌아가기
        if (window.history.length > 1) {
            window.history.back()
        } else {
            window.location.href = contextPath + "/"
        }
    }

    // 모달이 이미 표시되어 있는지 확인
    if (modalOverlay.style.display !== "flex") {
        modalOverlay.style.display = "flex"
        setTimeout(() => {
            modalOverlay.classList.add("show")
        }, 10)
    }
}

/**
 * 로그인 체크 함수 - 개선된 버전
 */
function checkLogin(redirectUrl) {
    console.log("로그인 체크 함수 호출됨, 리다이렉트 URL:", redirectUrl)
    console.log("사용할 URL:", contextPath + "/auth/check")

    // AJAX 요청으로 로그인 상태 확인
    return fetch(contextPath + "/auth/check", {
        method: "GET",
        headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
        },
        credentials: "same-origin",
    })
        .then((response) => {
            console.log("로그인 체크 응답 받음:", response)
            console.log("응답 상태:", response.status)
            console.log("응답 헤더 Content-Type:", response.headers.get("content-type"))

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`)
            }

            const contentType = response.headers.get("content-type")
            if (!contentType || !contentType.includes("application/json")) {
                throw new Error("응답이 JSON 형식이 아닙니다: " + contentType)
            }

            return response.json()
        })
        .then((data) => {
            console.log("로그인 체크 데이터:", data)
            if (!data.isLoggedIn) {
                // 로그인되지 않은 경우 모달 표시
                console.log("로그인되지 않음, 모달 표시")
                openLoginModal(redirectUrl || window.location.pathname.substring(contextPath.length))
                return false
            }
            console.log("이미 로그인됨")

            // 로그인된 경우 해당 페이지로 이동 - 이 부분이 추가됨
            if (redirectUrl) {
                console.log("페이지 이동:", contextPath + "/" + redirectUrl)
                window.location.href = contextPath + "/" + redirectUrl
            }

            return true
        })
        .catch((error) => {
            console.error("로그인 상태 확인 중 오류 발생:", error)
            // 오류 발생 시 로그인 모달 표시 (서버 오류일 수도 있으므로)
            openLoginModal(redirectUrl || window.location.pathname.substring(contextPath.length))
            return false
        })
}

/**
 * 로그인이 필요한 링크에 이벤트 리스너 추가
 */
function setupLoginRequiredLinks() {
    console.log("로그인 필요 링크 설정 함수 호출됨")

    // 로그인이 필요한 링크에 클래스 추가
    const loginRequiredLinks = document.querySelectorAll(".login-required")
    console.log("로그인 필요 링크 수:", loginRequiredLinks.length)

    loginRequiredLinks.forEach((link) => {
        console.log("로그인 필요 링크:", link)

        // 이벤트 리스너가 중복 등록되지 않도록 기존 리스너 제거
        link.removeEventListener("click", loginRequiredClickHandler)

        // 새 이벤트 리스너 등록
        link.addEventListener("click", loginRequiredClickHandler)
    })

    // 네비게이션 바의 시간표 링크 처리 - 직접 선택자로 변경
    const timetableLink = document.querySelector("a.nav-link[href*='/timetable']")
    console.log("시간표 링크:", timetableLink)

    if (timetableLink) {
        // 이미 login-required 클래스가 있는지 확인
        if (!timetableLink.classList.contains("login-required")) {
            console.log("시간표 링크에 login-required 클래스 추가")
            timetableLink.classList.add("login-required")

            // 이벤트 리스너가 중복 등록되지 않도록 기존 리스너 제거
            timetableLink.removeEventListener("click", timetableClickHandler)

            // 새 이벤트 리스너 등록
            timetableLink.addEventListener("click", timetableClickHandler)
        }
    }

    // 배지 컬렉션 링크 처리 - 직접 선택자로 추가
    const badgesLink = document.querySelector("a.nav-link[href*='/badges']")
    console.log("배지 컬렉션 링크:", badgesLink)

    if (badgesLink) {
        // 이미 login-required 클래스가 있는지 확인
        if (!badgesLink.classList.contains("login-required")) {
            console.log("배지 컬렉션 링크에 login-required 클래스 추가")
            badgesLink.classList.add("login-required")
        }
    }
}

// 로그인 필요 링크 클릭 핸들러 함수
function loginRequiredClickHandler(e) {
    console.log("로그인 필요 링크 클릭됨")
    e.preventDefault()
    const redirectUrl = this.getAttribute("data-redirect") || this.getAttribute("href")
    console.log("리다이렉트 URL:", redirectUrl)

    // 경로에서 앞의 슬래시(/) 제거
    const cleanRedirectUrl = redirectUrl.startsWith("/") ? redirectUrl.substring(1) : redirectUrl

    checkLogin(cleanRedirectUrl)
}

// 시간표 링크 클릭 핸들러 함수 수정
function timetableClickHandler(e) {
    console.log("시간표 링크 클릭 핸들러 호출됨")
    e.preventDefault() // 항상 기본 동작 중단

    // 로그인 상태 확인 후 처리
    checkLogin("timetable").then((isLoggedIn) => {
        if (isLoggedIn) {
            // 로그인된 경우 시간표 페이지로 이동
            console.log("로그인 확인됨, 시간표 페이지로 이동")
            window.location.href = contextPath + "/timetable"
        }
        // 로그인되지 않은 경우는 checkLogin 함수에서 모달을 표시함
    })
}

// 강의평가 페이지 스크롤 위치 관리
function setupEvaluationsScrollPosition() {
    // 페이지가 강의평가 페이지인지 확인
    if (!document.querySelector(".evaluations-grid")) {
        return
    }

    // 페이지 언로드 시 현재 스크롤 위치 저장
    window.addEventListener("beforeunload", () => {
        // 강의평가 페이지에서만 스크롤 위치 저장
        if (window.location.pathname.includes("/evaluations")) {
            sessionStorage.setItem("evaluationsScrollPosition", window.scrollY)
        }
    })

    // 초기화 버튼 클릭 시 스크롤 위치 초기화
    const resetButton = document.querySelector(".evaluations-search-form a.btn-outline-secondary")
    if (resetButton) {
        resetButton.addEventListener("click", () => {
            sessionStorage.removeItem("evaluationsScrollPosition")
        })
    }
}

/**
 * 검색 가능한 드롭다운 초기화
 */
function initSearchableSelect() {
    const selects = document.querySelectorAll(".searchable-select")

    selects.forEach((select) => {
        // 이미 초기화된 경우 건너뛰기
        if (select.classList.contains("searchable-select-initialized")) {
            return
        }

        // 원래 select 요소 숨기기
        select.style.display = "none"
        select.classList.add("searchable-select-initialized")

        // 선택된 옵션 가져오기
        const selectedOption = select.options[select.selectedIndex]
        const selectedValue = selectedOption ? selectedOption.value : ""
        const selectedText = selectedOption ? selectedOption.textContent : "선택하세요"

        // 옵션 그룹화
        const groups = {}
        const options = Array.from(select.options)

        options.forEach((option) => {
            // optgroup의 label 속성을 그룹명으로 사용
            let group = "기타"
            if (option.parentElement && option.parentElement.tagName === "OPTGROUP") {
                group = option.parentElement.label
            }

            if (!groups[group]) {
                groups[group] = []
            }
            groups[group].push({
                value: option.value,
                text: option.textContent,
                selected: option.selected,
            })
        })

        // 커스텀 드롭다운 생성
        const container = document.createElement("div")
        container.className = "searchable-select-container"

        // 선택된 값을 표시할 입력 필드
        const input = document.createElement("div")
        input.className = "searchable-select-input"
        input.textContent = selectedText
        input.setAttribute("tabindex", "0")

        // 화살표 아이콘
        const arrow = document.createElement("span")
        arrow.className = "searchable-select-arrow"
        arrow.innerHTML = '<i class="bi bi-chevron-down"></i>'

        // 드롭다운 메뉴
        const dropdown = document.createElement("div")
        dropdown.className = "searchable-select-dropdown"

        // 검색 입력 필드
        const searchContainer = document.createElement("div")
        searchContainer.className = "searchable-select-search"

        const searchInput = document.createElement("input")
        searchInput.type = "text"
        searchInput.placeholder = "학과 검색..."
        searchInput.setAttribute("autocomplete", "off")

        searchContainer.appendChild(searchInput)
        dropdown.appendChild(searchContainer)

        // 그룹별로 옵션 추가
        const sortedGroups = Object.keys(groups).sort()

        sortedGroups.forEach((groupName) => {
            const groupContainer = document.createElement("div")
            groupContainer.className = "searchable-select-group"

            const groupLabel = document.createElement("div")
            groupLabel.className = "searchable-select-group-label"
            groupLabel.textContent = groupName
            groupContainer.appendChild(groupLabel)

            groups[groupName].forEach((option) => {
                const optionElement = document.createElement("div")
                optionElement.className = "searchable-select-option"
                if (option.selected) {
                    optionElement.classList.add("selected")
                }
                optionElement.textContent = option.text
                optionElement.setAttribute("data-value", option.value)

                optionElement.addEventListener("click", () => {
                    // 원래 select 값 변경
                    select.value = option.value

                    // 커스텀 UI 업데이트
                    input.textContent = option.text

                    // 선택된 옵션 스타일 업데이트
                    dropdown.querySelectorAll(".searchable-select-option").forEach((opt) => {
                        opt.classList.remove("selected")
                    })
                    optionElement.classList.add("selected")

                    // 드롭다운 닫기
                    container.classList.remove("active")

                    // change 이벤트 발생
                    const event = new Event("change", { bubbles: true })
                    select.dispatchEvent(event)
                })

                groupContainer.appendChild(optionElement)
            })

            dropdown.appendChild(groupContainer)
        })

        // 컨테이너에 요소 추가
        container.appendChild(input)
        container.appendChild(arrow)
        container.appendChild(dropdown)

        // 원래 select 다음에 커스텀 드롭다운 삽입
        select.parentNode.insertBefore(container, select.nextSibling)

        // 드롭다운 토글
        input.addEventListener("click", () => {
            container.classList.toggle("active")
            if (container.classList.contains("active")) {
                searchInput.focus()
            }
        })

        // 키보드 접근성
        input.addEventListener("keydown", (e) => {
            if (e.key === "Enter" || e.key === " ") {
                e.preventDefault()
                container.classList.toggle("active")
                if (container.classList.contains("active")) {
                    searchInput.focus()
                }
            }
        })

        // 검색 기능
        searchInput.addEventListener("input", () => {
            const searchTerm = searchInput.value.toLowerCase()
            let hasResults = false

            // 기존 "결과 없음" 메시지 제거
            const existingNoResults = dropdown.querySelector(".searchable-select-no-results")
            if (existingNoResults) {
                existingNoResults.remove()
            }

            // 각 그룹과 옵션 순회
            dropdown.querySelectorAll(".searchable-select-group").forEach((group) => {
                let groupHasVisibleOptions = false

                // 그룹 내 옵션 순회
                group.querySelectorAll(".searchable-select-option").forEach((option) => {
                    if (option.textContent.toLowerCase().includes(searchTerm)) {
                        option.style.display = "block"
                        groupHasVisibleOptions = true
                        hasResults = true
                    } else {
                        option.style.display = "none"
                    }
                })

                // 그룹 라벨 표시/숨김
                const groupLabel = group.querySelector(".searchable-select-group-label")
                if (groupHasVisibleOptions) {
                    group.style.display = "block"
                    groupLabel.style.display = "block"
                } else {
                    group.style.display = "none"
                }
            })

            // 결과가 없는 경우 메시지 표시
            if (!hasResults) {
                const noResults = document.createElement("div")
                noResults.className = "searchable-select-no-results"
                noResults.textContent = "검색 결과가 없습니다"
                dropdown.appendChild(noResults)
            }
        })

        // 외부 클릭 시 드롭다운 닫기
        document.addEventListener("click", (e) => {
            if (!container.contains(e.target)) {
                container.classList.remove("active")
            }
        })

        // 키보드 네비게이션
        searchInput.addEventListener("keydown", (e) => {
            const options = Array.from(dropdown.querySelectorAll('.searchable-select-option:not([style*="display: none"])'))
            if (options.length === 0) return

            const focusedOption = dropdown.querySelector(".searchable-select-option.focused")
            const focusedIndex = focusedOption ? options.indexOf(focusedOption) : -1

            switch (e.key) {
                case "ArrowDown":
                    e.preventDefault()
                    if (focusedIndex < options.length - 1) {
                        if (focusedOption) focusedOption.classList.remove("focused")
                        options[focusedIndex + 1].classList.add("focused")
                        options[focusedIndex + 1].scrollIntoView({ block: "nearest" })
                    }
                    break

                case "ArrowUp":
                    e.preventDefault()
                    if (focusedIndex > 0) {
                        if (focusedOption) focusedOption.classList.remove("focused")
                        options[focusedIndex - 1].classList.add("focused")
                        options[focusedIndex - 1].scrollIntoView({ block: "nearest" })
                    }
                    break

                case "Enter":
                    e.preventDefault()
                    if (focusedOption) {
                        focusedOption.click()
                    }

                    break

                case "Escape":
                    e.preventDefault()
                    container.classList.remove("active")
                    break
            }
        })
    })
}

// 페이지 로드 시 실행
document.addEventListener("DOMContentLoaded", () => {
    setupEvaluationsScrollPosition()
})

// 전역 함수로 노출
window.openLoginModal = openLoginModal
window.checkLogin = checkLogin
window.closeLoginModal = closeLoginModal
