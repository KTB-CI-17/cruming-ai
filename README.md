# cruming-ai

### Git-hub 전략을 따름
***
- product : 운영에 배포할 브랜치
- develop : 다음 출시 버전을 개발하는 브랜치
- feature : 기능을 개발하는 브랜치

### 커밋 메시지 컨벤션
***
한글로 작성. 기본 원칙 : 1 Action 1 Commit (최대한 작게 쪼개 한 커밋에 하나의 기능만 커밋되도록)

- feat: 새로운 기능 추가
- fix: 버그 수정
- docs: 문서 수정
- style: 코드 포맷팅, 세미콜론 누락, 코드 변경이 없는 경우
- design: CSS, HTML 등 변경
- refactor: 코드 리팩토링
- test: 테스트 코드, 리팩토링 테스트 코드 추가
- chore: 빌드 업무 수정, 패키지 매니저 수정
- rename: 파일 혹은 폴더 명 변경만 진행된 경우
- remove: 파일 혹은 폴더 삭제 작업만 진행된 경우


### 테스트 코드
***
curl -X POST -F "file=@images/hold-test.jpeg" http://localhost:8000/detect  
curl http://localhost:8000/health
