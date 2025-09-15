// 시간표 관련 JavaScript 함수

document.addEventListener("DOMContentLoaded", () => {
    console.log("DOM이 로드되었습니다.")

    // 전역 변수
    window.activeTab = "timetable-view"
    window.scrollPosition = 0

    // 현재 활성화된 탭 저장
    const tabElements = document.querySelectorAll('button[data-bs-toggle="tab"]')
    tabElements.forEach((tab) => {
        tab.addEventListener("shown.bs.tab", (event) => {
            window.activeTab = event.target.getAttribute("data-bs-target").substring(1)
        })
    })

    // 강의 추가 버튼 이벤트 리스너
    const addCourseBtn = document.getElementById("addCourseBtn")
    if (addCourseBtn) {
        console.log("강의 추가 버튼을 찾았습니다.")

        addCourseBtn.addEventListener("click", () => {
            console.log("강의 추가 버튼이 클릭되었습니다.")
            showModal("addCourseModal")
        })
    } else {
        console.error("강의 추가 버튼을 찾을 수 없습니다.")
    }

    // 시간표에 강의 배치
    placeCourses()

    // 드래그 앤 드롭 기능 초기화
    initializeDragAndDrop()

    // 이벤트 리스너 설정
    setupEventListeners()

    // 색상 선택 이벤트 설정
    setupColorOptions()

    // 시간표 카드에 클래스 추가
    const timetableCard = document.querySelector(".card-header")
    if (timetableCard && timetableCard.closest(".card")) {
        timetableCard.closest(".card").classList.add("timetable-card")
    }

    // 시간표 탭 내의 카드와 표에 hover 효과 제거
    const timetableCards = document.querySelectorAll("#timetable-view .card, #course-list-view .card")
    timetableCards.forEach((card) => {
        card.classList.add("no-hover")
    })

    const timetableTable = document.querySelector("#timetable")
    if (timetableTable) {
        timetableTable.classList.add("no-hover")
    }

    const courseListCards = document.querySelectorAll("#courseList .card")
    courseListCards.forEach((card) => {
        card.classList.add("no-hover")
    })

    // 다크 모드 감지 및 카드 헤더 색상 보존
    function preserveCardHeaderColors() {
        // 모든 강의 카드 헤더 찾기
        const cardHeaders = document.querySelectorAll('#list-view .card-header[style*="background-color"]')

        cardHeaders.forEach((header) => {
            // 원래 배경색 저장
            const originalColor = header.style.backgroundColor

            // 데이터 속성에 원래 색상 저장
            header.setAttribute("data-original-color", originalColor)

            // 다크 모드 변경 감지를 위한 MutationObserver 설정
            const observer = new MutationObserver((mutations) => {
                mutations.forEach((mutation) => {
                    if (mutation.type === "attributes" && mutation.attributeName === "class") {
                        const isDarkMode = document.body.classList.contains("dark-mode")

                        if (isDarkMode) {
                            // 다크 모드일 때 원래 색상 적용
                            const savedColor = header.getAttribute("data-original-color")
                            if (savedColor) {
                                header.style.setProperty("background-color", savedColor, "important")
                            }
                        }
                    }
                })
            })

            // body 요소의 클래스 변화 감지
            observer.observe(document.body, { attributes: true })

            // 페이지 로드 시 이미 다크 모드인 경우 색상 적용
            if (document.body.classList.contains("dark-mode")) {
                header.style.setProperty("background-color", originalColor, "important")
            }
        })
    }

    // 페이지 로드 시 실행
    preserveCardHeaderColors()

    // 탭 전환 시에도 색상 보존 적용
    document.querySelectorAll('[data-bs-toggle="tab"]').forEach((tab) => {
        tab.addEventListener("shown.bs.tab", (e) => {
            if (e.target.getAttribute("data-bs-target") === "#list-view") {
                setTimeout(preserveCardHeaderColors, 100) // 탭 전환 후 약간의 지연을 두고 실행
            }
        })
    })
})

// 시간표에 강의 배치 함수
function placeCourses() {
    const courses = getCourses()

    // 시간표에 강의 배치
    courses.forEach((course) => {
        createCourseElement(course)
    })
}

// 강의 요소 생성 및 배치 함수
function createCourseElement(course) {
    const dayMap = { 월: 0, 화: 1, 수: 2, 목: 3, 금: 4 }
    const dayIndex = dayMap[course.day]

    if (dayIndex === undefined) return

    const startHour = course.startTime
    const endHour = course.endTime
    const duration = endHour - startHour

    // 시작 셀 찾기
    const startCell = document.querySelector(`.day-cell[data-day="${course.day}"][data-hour="${startHour}"]`)
    if (!startCell) return

    // 강의 요소 생성
    const courseElement = document.createElement("div")
    courseElement.className = "course-item position-absolute"
    courseElement.setAttribute("data-course-id", course.id)
    courseElement.style.backgroundColor = course.color

    // 강의 내용 추가
    courseElement.innerHTML = `
    <div class="fw-bold">${course.name}</div>
    <div>${course.professor}</div>
    <div>${course.location}</div>
  `

    // 위치 및 크기 설정
    courseElement.style.top = `${startCell.offsetTop}px`
    courseElement.style.left = `${startCell.offsetLeft}px`
    courseElement.style.width = `${startCell.offsetWidth}px`
    courseElement.style.height = `${startCell.offsetHeight * duration}px`

    // 클릭 이벤트 추가
    courseElement.addEventListener("click", () => {
        showCourseInfo(course.id)
    })

    // 시간표 컨테이너에 추가
    const container = document.querySelector(".timetable-container")
    if (container) {
        container.appendChild(courseElement)
    }
}

// 드래그 앤 드롭 기능 초기화
function initializeDragAndDrop() {
    const courseItems = document.querySelectorAll(".course-item")

    courseItems.forEach((item) => {
        item.setAttribute("draggable", "true")

        item.addEventListener("dragstart", (e) => {
            e.dataTransfer.setData("text/plain", item.getAttribute("data-course-id"))
            item.classList.add("dragging")

            // 현재 스크롤 위치 저장
            window.scrollPosition = window.scrollY
        })

        item.addEventListener("dragend", () => {
            item.classList.remove("dragging")
        })
    })

    // 드롭 영역 설정
    const dayCells = document.querySelectorAll(".day-cell")

    dayCells.forEach((cell) => {
        cell.addEventListener("dragover", (e) => {
            e.preventDefault()
            cell.classList.add("drag-over")
        })

        cell.addEventListener("dragleave", () => {
            cell.classList.remove("drag-over")
        })

        cell.addEventListener("drop", (e) => {
            e.preventDefault()
            cell.classList.remove("drag-over")

            const courseId = e.dataTransfer.getData("text/plain")
            const day = cell.getAttribute("data-day")
            const hour = Number.parseInt(cell.getAttribute("data-hour"))

            // 강의 시간 업데이트
            updateCourseTime(courseId, day, hour)
        })
    })
}

// 이벤트 리스너 설정 함수
function setupEventListeners() {
    // 편집 버튼 클릭 시 모달 표시
    const editBtns = document.querySelectorAll(".edit-course")
    editBtns.forEach((btn) => {
        btn.addEventListener("click", function (e) {
            e.stopPropagation() // 이벤트 버블링 방지
            const courseId = this.getAttribute("data-course-id")
            showCourseDetails(courseId)
        })
    })

    // 목록에서 삭제 버튼 클릭
    const deleteBtns = document.querySelectorAll(".delete-course")
    deleteBtns.forEach((btn) => {
        btn.addEventListener("click", function (e) {
            e.stopPropagation() // 이벤트 버블링 방지
            if (confirm("정말로 이 강의를 삭제하시겠습니까?")) {
                const courseId = this.getAttribute("data-course-id")
                deleteCourse(courseId)
            }
        })
    })

    // 강의 카드 클릭 시 정보 모달 표시
    const courseCards = document.querySelectorAll(".course-card")
    courseCards.forEach((card) => {
        card.addEventListener("click", function (e) {
            // 드롭다운 버튼이나 드롭다운 메뉴 클릭 시 이벤트 무시
            if (e.target.closest(".dropdown") || e.target.closest(".dropdown-menu")) {
                return
            }

            const courseId = this.getAttribute("data-course-id")
            showCourseInfo(courseId)
        })
    })

    // 강의 추가 폼 제출 처리
    const saveCourseBtn = document.getElementById("saveCourseBtn")
    const addCourseForm = document.getElementById("addCourseForm")

    if (saveCourseBtn && addCourseForm) {
        saveCourseBtn.addEventListener("click", () => {
            if (!validateForm(addCourseForm)) {
                return
            }

            submitCourseForm(addCourseForm, "add")
        })
    }

    // 강의 수정 폼 제출 처리
    const updateCourseBtn = document.getElementById("updateCourseBtn")
    const editCourseForm = document.getElementById("editCourseForm")

    if (updateCourseBtn && editCourseForm) {
        updateCourseBtn.addEventListener("click", () => {
            if (!validateForm(editCourseForm)) {
                return
            }

            submitCourseForm(editCourseForm, "update")
        })
    }

    // 강의 삭제 버튼 클릭 이벤트
    const deleteCourseBtn = document.getElementById("deleteCourseBtn")
    if (deleteCourseBtn) {
        deleteCourseBtn.addEventListener("click", () => {
            if (confirm("정말로 이 강의를 삭제하시겠습니까?")) {
                const courseId = document.getElementById("editCourseId").value
                deleteCourse(courseId)
            }
        })
    }

    // 강의 정보 모달에서 수정 버튼 클릭 이벤트
    const editCourseBtn = document.getElementById("editCourseBtn")
    if (editCourseBtn) {
        editCourseBtn.addEventListener("click", function () {
            // 현재 보고 있는 강의 ID 가져오기
            const courseId = this.getAttribute("data-course-id")

            // 정보 모달 닫기
            closeModal("courseInfoModal")

            // 수정 모달 열기
            setTimeout(() => {
                showCourseDetails(courseId)
            }, 100)
        })
    }
}

// 색상 선택 이벤트 설정
function setupColorOptions() {
    // 색상 옵션 클릭 시 선택 효과
    const colorOptions = document.querySelectorAll(".color-option")
    colorOptions.forEach((option) => {
        option.addEventListener("click", function () {
            const radioId = this.getAttribute("for")
            const radio = document.getElementById(radioId)
            if (radio) {
                radio.checked = true

                // 모든 색상 옵션의 테두리 초기화
                const allOptions = document.querySelectorAll(".color-option")
                allOptions.forEach((opt) => {
                    opt.style.border = "2px solid transparent"
                })

                // 선택된 옵션의 테두리 설정
                this.style.border = "2px solid #000"
            }
        })
    })
}

// 모달 표시 함수
function showModal(modalId) {
    const modalElement = document.getElementById(modalId)
    if (!modalElement) {
        console.error(`모달 요소를 찾을 수 없습니다: ${modalId}`)
        return
    }

    try {
        // Bootstrap 모달 사용 시도
        if (typeof bootstrap !== "undefined") {
            const modal = new bootstrap.Modal(modalElement)
            modal.show()
        }
        // jQuery 모달 사용 시도
        else if (typeof $ !== "undefined" && typeof $.fn.modal !== "undefined") {
            $(modalElement).modal("show")
        }
        // 순수 JavaScript로 모달 표시
        else {
            modalElement.classList.add("show")
            modalElement.style.display = "block"
            document.body.classList.add("modal-open")

            // 배경 생성
            let backdrop = document.querySelector(".modal-backdrop")
            if (!backdrop) {
                backdrop = document.createElement("div")
                backdrop.className = "modal-backdrop fade show"
                document.body.appendChild(backdrop)
            }

            // 닫기 버튼 이벤트 추가
            const closeButtons = modalElement.querySelectorAll('[data-bs-dismiss="modal"], .btn-close, .btn-secondary')
            closeButtons.forEach((btn) => {
                btn.addEventListener("click", () => {
                    modalElement.classList.remove("show")
                    modalElement.style.display = "none"
                    document.body.classList.remove("modal-open")
                    if (backdrop.parentNode) {
                        backdrop.parentNode.removeChild(backdrop)
                    }
                })
            })
        }
    } catch (error) {
        console.error(`모달 표시 중 오류 발생: ${error}`)
    }
}

// 모달 닫기 함수
function closeModal(modalId) {
    const modalElement = document.getElementById(modalId)
    if (!modalElement) {
        console.error(`모달 요소를 찾을 수 없습니다: ${modalId}`)
        return
    }

    try {
        // Bootstrap 모달 사용 시도
        if (typeof bootstrap !== "undefined") {
            const modalInstance = bootstrap.Modal.getInstance(modalElement)
            if (modalInstance) {
                modalInstance.hide()
            } else {
                // 인스턴스가 없는 경우 수동으로 닫기
                modalElement.classList.remove("show")
                modalElement.style.display = "none"
                document.body.classList.remove("modal-open")
                const backdrop = document.querySelector(".modal-backdrop")
                if (backdrop && backdrop.parentNode) {
                    backdrop.parentNode.removeChild(backdrop)
                }
            }
        }
        // jQuery 모달 사용 시도
        else if (typeof $ !== "undefined" && typeof $.fn.modal !== "undefined") {
            $(modalElement).modal("hide")
        }
        // 순수 JavaScript로 모달 닫기
        else {
            modalElement.classList.remove("show")
            modalElement.style.display = "none"
            document.body.classList.remove("modal-open")
            const backdrop = document.querySelector(".modal-backdrop")
            if (backdrop && backdrop.parentNode) {
                backdrop.parentNode.removeChild(backdrop)
            }
        }
    } catch (error) {
        console.error(`모달 닫기 중 오류 발생: ${error}`)
    }
}

// 강의 상세 정보 표시 함수 (수정용)
function showCourseDetails(courseId) {
    // AJAX로 강의 정보 가져오기
    fetch(window.location.origin + "/timetable/" + courseId)
        .then((response) => {
            if (!response.ok) {
                throw new Error("서버 응답 오류")
            }
            return response.json()
        })
        .then((course) => {
            // 모달에 정보 채우기
            document.getElementById("editCourseId").value = course.id
            document.getElementById("editName").value = course.name
            document.getElementById("editProfessor").value = course.professor
            document.getElementById("editDay").value = course.day
            document.getElementById("editLocation").value = course.location
            document.getElementById("editStartTime").value = course.startTime
            document.getElementById("editEndTime").value = course.endTime

            // 색상 선택
            const colorRadio = document.querySelector(`input[name="editColor"][value="${course.color}"]`)
            if (colorRadio) {
                colorRadio.checked = true

                // 모든 색상 옵션의 테두리 초기화
                const allOptions = document.querySelectorAll('label[for^="editColor-"]')
                allOptions.forEach((opt) => {
                    opt.style.border = "2px solid transparent"
                })

                // 선택된 옵션의 테두리 설정
                const selectedOption = document.querySelector(`label[for="editColor-${course.color}"]`)
                if (selectedOption) {
                    selectedOption.style.border = "2px solid #000"
                }
            }

            // 모달 표시
            showModal("courseDetailModal")

            // 강의 평가 탭 데이터 로드
            loadCourseEvaluations(course.name, course.professor)
        })
        .catch((error) => {
            console.error("Error:", error)
            alert("강의 정보를 불러오는 데 실패했습니다.")
        })
}

// 강의 정보 표시 함수 (읽기 전용)
function showCourseInfo(courseId) {
    // AJAX로 강의 정보 가져오기
    fetch(window.location.origin + "/timetable/" + courseId)
        .then((response) => {
            if (!response.ok) {
                throw new Error("서버 응답 오류")
            }
            return response.json()
        })
        .then((course) => {
            // 모달에 정보 채우기
            document.getElementById("infoCourseName").textContent = course.name
            document.getElementById("infoCourseColor").style.backgroundColor = course.color
            document.getElementById("infoProfessor").textContent = course.professor
            document.getElementById("infoDay").textContent = course.day
            document.getElementById("infoTime").textContent = `${course.startTime}:00 - ${course.endTime}:00`
            document.getElementById("infoLocation").textContent = course.location

            // 수정 버튼에 강의 ID 설정
            document.getElementById("editCourseBtn").setAttribute("data-course-id", course.id)

            // 모달 표시
            showModal("courseInfoModal")

            // 기본 탭을 '강의 정보'로 설정 (추가된 부분)
            const infoTab = document.querySelector('a[href="#courseInfoTab"]')
            if (infoTab) {
                const tabInstance = new bootstrap.Tab(infoTab)
                tabInstance.show()
            }

            // 강의 평가 탭 데이터 로드 (백그라운드에서 로드)
            loadCourseEvaluationsForInfo(course.name, course.professor)
        })
        .catch((error) => {
            console.error("Error:", error)
            alert("강의 정보를 불러오는 데 실패했습니다.")
        })
}

// 강의 시간 업데이트 함수
function updateCourseTime(courseId, day, startTime) {
    // 현재 강의 정보 가져오기
    fetch(window.location.origin + "/timetable/" + courseId)
        .then((response) => {
            if (!response.ok) {
                throw new Error("서버 응답 오류")
            }
            return response.json()
        })
        .then((course) => {
            // 강의 시간 업데이트
            const duration = course.endTime - course.startTime
            const endTime = startTime + duration

            // 업데이트할 데이터 준비
            const updateData = {
                id: courseId,
                day: day,
                startTime: startTime,
                endTime: endTime,
            }

            // 서버에 업데이트 요청
            fetch(window.location.origin + "/timetable/" + courseId, {
                method: "PUT",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(updateData),
            })
                .then((response) => {
                    if (!response.ok) {
                        throw new Error("서버 응답 오류")
                    }
                    return response.json()
                })
                .then(() => {
                    // 페이지 새로고침 없이 시간표 업데이트
                    updateTimetableWithoutRefresh(course, day, startTime, endTime)
                })
                .catch((error) => {
                    console.error("Error:", error)
                    alert("강의 시간 업데이트에 실패했습니다.")
                })
        })
        .catch((error) => {
            console.error("Error:", error)
            alert("강의 정보를 불러오는 데 실패했습니다.")
        })
}

// 페이지 새로고침 없이 시간표 업데이트
function updateTimetableWithoutRefresh(course, newDay, newStartTime, newEndTime) {
    // 기존 강의 요소 찾기
    const courseElement = document.querySelector(`.course-item[data-course-id="${course.id}"]`)
    if (!courseElement) return

    // 새 위치의 셀 찾기
    const newStartCell = document.querySelector(`.day-cell[data-day="${newDay}"][data-hour="${newStartTime}"]`)
    if (!newStartCell) return

    // 강의 요소 위치 및 크기 업데이트
    const duration = newEndTime - newStartTime
    courseElement.style.top = `${newStartCell.offsetTop}px`
    courseElement.style.left = `${newStartCell.offsetLeft}px`
    courseElement.style.height = `${newStartCell.offsetHeight * duration}px`
    courseElement.style.width = `${newStartCell.offsetWidth}px` // 너비도 업데이트

    // 목록 보기 탭의 강의 정보 업데이트
    const courseCard = document.querySelector(`.course-card[data-course-id="${course.id}"]`)
    if (courseCard) {
        // 요일 정보 업데이트
        const dayElement = courseCard.querySelector(".bi-calendar-date")
        if (dayElement && dayElement.nextSibling) {
            dayElement.nextSibling.textContent = ` ${newDay}요일`
        }

        // 시간 정보 업데이트
        const timeElement = courseCard.querySelector(".bi-clock")
        if (timeElement && timeElement.nextSibling) {
            timeElement.nextSibling.textContent = ` ${newStartTime}:00 - ${newEndTime}:00`
        }
    }

    // 저장된 스크롤 위치로 복원
    if (window.scrollPosition) {
        window.scrollTo(0, window.scrollPosition)
    }
}

// 폼 유효성 검사 함수
function validateForm(form) {
    for (const element of form.elements) {
        if (element.hasAttribute("required") && !element.value) {
            alert("모든 필수 항목을 입력해주세요.")
            element.focus()
            return false
        }
    }

    // 시작 시간과 종료 시간 검사
    if (form.id === "addCourseForm" || form.id === "editCourseForm") {
        const startTimeSelect = form.querySelector('[name="startTime"]')
        const endTimeSelect = form.querySelector('[name="endTime"]')

        if (startTimeSelect && endTimeSelect) {
            const startTime = Number.parseInt(startTimeSelect.value)
            const endTime = Number.parseInt(endTimeSelect.value)

            if (startTime >= endTime) {
                alert("종료 시간은 시작 시간보다 커야 합니다.")
                return false
            }
        }
    }

    return true
}

// 강의 폼 제출 함수
function submitCourseForm(form, action) {
    // 폼 데이터 수집
    const formData = new FormData(form)
    const courseData = {}

    formData.forEach((value, key) => {
        courseData[key] = value
    })

    // 색상 설정
    if (action === "add") {
        const selectedColor = document.querySelector('input[name="color"]:checked')
        courseData.color = selectedColor ? selectedColor.value : "#4f46e5"
    } else {
        const selectedColor = document.querySelector('input[name="editColor"]:checked')
        courseData.color = selectedColor ? selectedColor.value : "#4f46e5"
    }

    // AJAX 요청
    const url =
        action === "add" ? window.location.origin + "/timetable" : window.location.origin + "/timetable/" + courseData.id

    const method = action === "add" ? "POST" : "PUT"

    fetch(url, {
        method: method,
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(courseData),
    })
        .then((response) => {
            if (!response.ok) {
                throw new Error("서버 응답 오류")
            }
            return response.json()
        })
        .then((data) => {
            if (data.id) {
                // 성공적으로 추가/수정됨
                // 현재 활성화된 탭을 유지하며 페이지 새로고침
                reloadWithActiveTab()
            } else {
                alert(action === "add" ? "강의 추가에 실패했습니다." : "강의 수정에 실패했습니다.")
            }
        })
        .catch((error) => {
            console.error("Error:", error)
            alert(action === "add" ? "강의 추가 중 오류가 발생했습니다." : "  => {")
            console.error("Error:", error)
            alert(action === "add" ? "강의 추가 중 오류가 발생했습니다." : "강의 수정 중 오류가 발생했습니다.")
        })
}

// 강의 삭제 함수
function deleteCourse(courseId) {
    fetch(window.location.origin + "/timetable/" + courseId, {
        method: "DELETE",
    })
        .then((response) => {
            // 204 No Content 응답은 성공으로 처리
            if (response.status === 204) {
                // 성공적으로 삭제됨
                reloadWithActiveTab()
                return { success: true }
            }

            if (!response.ok) {
                throw new Error("서버 응답 오류")
            }

            return response.json()
        })
        .then((data) => {
            if (data && data.success) {
                // 성공적으로 삭제됨
                reloadWithActiveTab()
            } else {
                // 오류가 발생해도 페이지 새로고침 (실제로는 삭제되었을 수 있음)
                reloadWithActiveTab()
            }
        })
        .catch((error) => {
            console.error("Error:", error)
            alert("강의 삭제 중 오류가 발생했습니다.")
            // 오류가 발생해도 페이지 새로고침 (실제로는 삭제되었을 수 있음)
            reloadWithActiveTab()
        })
}

// 강의 평가 데이터 로드 함수 (수정 모달용)
function loadCourseEvaluations(courseName, professor) {
    const evaluationsContainer = document.getElementById("courseEvaluations")
    if (!evaluationsContainer) return

    // 로딩 표시
    evaluationsContainer.innerHTML =
        '<div class="text-center"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>'

    // 데이터베이스에서 강의 정보 조회
    fetch(`/api/evaluations?course=${encodeURIComponent(courseName)}&professor=${encodeURIComponent(professor)}`)
        .then((response) => response.json())
        .then((data) => {
            if (!data.exists) {
                // 강의가 데이터베이스에 없는 경우
                evaluationsContainer.innerHTML = `
          <div class="text-center py-4">
            <div class="mb-3">
              <i class="bi bi-exclamation-circle text-warning" style="font-size: 2rem;"></i>
            </div>
            <h5>강의 정보를 찾을 수 없습니다</h5>
            <p class="text-muted">데이터베이스에 등록되지 않은 강의입니다.</p>
          </div>
        `
                return
            }

            if (data.evaluations.length === 0) {
                // 강의 평가가 없는 경우
                evaluationsContainer.innerHTML = `
          <div class="text-center py-4">
            <div class="mb-3">
              <i class="bi bi-chat-square-text text-muted" style="font-size: 2rem;\"></i>
            </div>
            <h5>아직 등록된 강의 평가가 없습니다</h5>
            <p class="text-muted">첫 번째 강의 평가를 작성해보세요</p>
            <a href="${window.location.origin}/evaluations/write?course=${encodeURIComponent(courseName)}&professor=${encodeURIComponent(professor)}" class="btn btn-primary btn-sm mt-2">
              <i class="bi bi-pencil-fill me-1"></i> 강의 평가 작성
            </a>
          </div>
        `
            } else {
                // 강의 평가가 있는 경우
                let html = '<div class="evaluation-list">'

                data.evaluations.forEach((evaluation) => {
                    // 특징(features) 목록 생성
                    let featuresHtml = ""
                    if (evaluation.features && evaluation.features.length > 0) {
                        featuresHtml = '<div class="mt-2">'
                        evaluation.features.forEach((feature) => {
                            featuresHtml += `<span class="badge bg-light text-dark me-1">${feature}</span>`
                        })
                        featuresHtml += "</div>"
                    }

                    html += `
            <div class="evaluation-item">
              <div class="d-flex justify-content-between align-items-center mb-2">
                <div class="evaluation-meta">
                  ${new Date(evaluation.date).toLocaleDateString()}
                </div>
                <div class="evaluation-rating">
                  <span class="badge bg-success">평점 ${evaluation.rating}/5</span>
                </div>
              </div>
              <div class="evaluation-content">
                ${evaluation.comment}
              </div>
              <div class="d-flex justify-content-between align-items-center">
                <div class="evaluation-meta">
                  <span class="me-2">난이도: ${evaluation.difficulty}/5</span>
                  <span>과제량: ${evaluation.homework}/5</span>
                </div>
              </div>
              ${featuresHtml}
            </div>
          `
                })

                html += "</div>"
                evaluationsContainer.innerHTML = html
            }
        })
        .catch((error) => {
            console.error("Error:", error)
            evaluationsContainer.innerHTML = `
        <div class="alert alert-danger" role="alert">
          강의 평가를 불러오는 중 오류가 발생했습니다.
        </div>
      `
        })
}

// 강의 평가 데이터 로드 함수 (정보 모달용)
function loadCourseEvaluationsForInfo(courseName, professor) {
    const evaluationsContainer = document.getElementById("infoEvaluations")
    if (!evaluationsContainer) return

    // 로딩 표시
    evaluationsContainer.innerHTML =
        '<div class="text-center"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>'

    // 데이터베이스에서 강의 정보 조회
    fetch(`/api/evaluations?course=${encodeURIComponent(courseName)}&professor=${encodeURIComponent(professor)}`)
        .then((response) => response.json())
        .then((data) => {
            if (!data.exists) {
                // 강의가 데이터베이스에 없는 경우 - 메시지 변경
                evaluationsContainer.innerHTML = `
          <div class="text-center py-4">
            <div class="mb-3">
              <i class="bi bi-chat-square-text text-muted" style="font-size: 2rem;"></i>
            </div>
            <h5>아무도 해당 강의를 평가하지 않았어요!</h5>
            <p class="text-muted">처음으로 작성해주세요</p>
            <a href="${window.location.origin}/evaluations/write?course=${encodeURIComponent(courseName)}&professor=${encodeURIComponent(professor)}" class="btn btn-primary btn-sm mt-2">
              <i class="bi bi-pencil-fill me-1"></i> 강의 평가 작성
            </a>
          </div>
        `
                return
            }

            if (data.evaluations.length === 0) {
                // 강의 평가가 없는 경우 - 메시지 변경
                evaluationsContainer.innerHTML = `
          <div class="text-center py-4">
            <div class="mb-3">
              <i class="bi bi-chat-square-text text-muted" style="font-size: 2rem;"></i>
            </div>
            <h5>아무도 해당 강의를 평가하지 않았어요!</h5>
            <p class="text-muted">처음으로 작성해주세요</p>
            <a href="${window.location.origin}/evaluations/write?course=${encodeURIComponent(courseName)}&professor=${encodeURIComponent(professor)}" class="btn btn-primary btn-sm mt-2">
              <i class="bi bi-pencil-fill me-1"></i> 강의 평가 작성
            </a>
          </div>
        `
            } else {
                // 강의 평가가 있는 경우
                let html = '<div class="evaluation-list">'

                data.evaluations.forEach((evaluation) => {
                    // 특징(features) 목록 생성
                    let featuresHtml = ""
                    if (evaluation.features && evaluation.features.length > 0) {
                        featuresHtml = '<div class="mt-2">'
                        evaluation.features.forEach((feature) => {
                            featuresHtml += `<span class="badge bg-light text-dark me-1">${feature}</span>`
                        })
                        featuresHtml += "</div>"
                    }

                    html += `
            <div class="evaluation-item">
              <div class="d-flex justify-content-between align-items-center mb-2">
                <div class="evaluation-meta">
                  ${new Date(evaluation.date).toLocaleDateString()}
                </div>
                <div class="evaluation-rating">
                  <span class="badge bg-success">평점 ${evaluation.rating}/5</span>
                </div>
              </div>
              <div class="evaluation-content">
                ${evaluation.comment}
              </div>
              <div class="d-flex justify-content-between align-items-center">
                <div class="evaluation-meta">
                  <span class="me-2">난이도: ${evaluation.difficulty}/5</span>
                  <span>과제량: ${evaluation.homework}/5</span>
                </div>
              </div>
              ${featuresHtml}
            </div>
          `
                })

                html += "</div>"
                evaluationsContainer.innerHTML = html
            }
        })
        .catch((error) => {
            console.error("Error:", error)
            evaluationsContainer.innerHTML = `
        <div class="alert alert-danger" role="alert">
          강의 평가를 불러오는 중 오류가 발생했습니다.
        </div>
      `
        })
}

// 현재 활성화된 탭을 유지하며 페이지 새로고침
function reloadWithActiveTab() {
    const currentTab = window.activeTab || "timetable-view"
    const url = new URL(window.location.href)
    url.searchParams.set("tab", currentTab)
    window.location.href = url.toString()
}

// 강의 목록 가져오기 (JSP에서 전달된 데이터)
function getCourses() {
    // 이 함수는 JSP에서 전달된 courses 배열을 반환
    const coursesData = document.getElementById("coursesData")
    if (coursesData) {
        try {
            return JSON.parse(coursesData.textContent)
        } catch (e) {
            console.error("강의 데이터 파싱 오류:", e)
            return []
        }
    }

    // JSP에서 전달된 데이터가 없는 경우, 스크립트 태그에서 직접 가져오기
    const scripts = document.querySelectorAll("script")
    for (const script of scripts) {
        const text = script.textContent
        if (text.includes("const courses =")) {
            try {
                // 스크립트에서 courses 배열 추출
                const match = text.match(/const courses = (\[.*?\]);/s)
                if (match && match[1]) {
                    return JSON.parse(match[1])
                }
            } catch (e) {
                console.error("스크립트에서 강의 데이터 파싱 오류:", e)
            }
        }
    }

    return []
}
