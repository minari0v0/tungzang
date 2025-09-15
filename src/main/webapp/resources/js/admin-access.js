// 관리자 페이지 숨겨진 접근 기능
document.addEventListener("DOMContentLoaded", () => {
    let adminKeySequence = ""
    const targetSequence = "admin"
    const contextPath = "" // contextPath 변수 선언 및 초기화

    // 키보드 이벤트 리스너 추가
    document.addEventListener("keydown", (e) => {
        // 입력 필드에 포커스가 있는지 확인
        const activeElement = document.activeElement
        const isInputFocused =
            activeElement.tagName === "INPUT" || activeElement.tagName === "TEXTAREA" || activeElement.isContentEditable

        // 입력 필드에 포커스가 없을 때만 키 시퀀스 기록
        if (!isInputFocused) {
            // 알파벳 키만 기록
            if (e.key.length === 1 && e.key.match(/[a-z]/i)) {
                adminKeySequence += e.key.toLowerCase()

                // 시퀀스가 너무 길어지면 앞부분 자르기
                if (adminKeySequence.length > 10) {
                    adminKeySequence = adminKeySequence.substring(adminKeySequence.length - 10)
                }

                // 'admin' 시퀀스가 입력되었는지 확인
                if (adminKeySequence.includes(targetSequence)) {
                    console.log("관리자 모드 활성화")
                    adminKeySequence = "" // 시퀀스 초기화
                    window.location.href = contextPath + "/admin/login"
                }
            }
        }
    })
})
