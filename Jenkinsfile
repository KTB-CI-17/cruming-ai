pipeline {
    agent any

    environment {
        REPO                    = 'KTB-CI-17/cruming-ai'
        GIT_BRANCH              = 'product'
        GIT_CREDENTIALS_ID      = 'github_account' // 매니페스트 저장소 접근을 위한 크리덴셜 ID
        DOCKER_HUB_CREDENTIALS_ID = 'docker_hub_credentials' // Docker Hub 크리덴셜 ID
        DOCKER_HUB_REPO         = 'minyubo/ktb-cruming-ai'
        IMAGE_TAG               = "${env.BUILD_NUMBER}"

        // Kubernetes 매니페스트 저장소 설정
        K8S_MANIFEST_REPO         = 'KTB-CI-17/cruming-k8s'
        K8S_MANIFEST_BRANCH       = 'main'
        K8S_MANIFEST_CREDENTIALS  = 'github_account'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: "${GIT_BRANCH}",
                    credentialsId: "${GIT_CREDENTIALS_ID}",
                    url: "https://github.com/${REPO}.git"
            }
        }

        stage('Docker Test') {
            steps {
                script {
                    sh """
                        export PATH=\$PATH:~/.docker/cli-plugins
                        docker buildx version
                        docker buildx ls
                    """
                }
            }
        }


        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        export DOCKER_BUILDKIT=1
                        docker buildx build --platform linux/amd64 \
                            -t ${DOCKER_HUB_REPO}:${IMAGE_TAG} \
                            -t ${DOCKER_HUB_REPO}:latest \
                            --load .
                    """
                }
            }
        }


        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_HUB_CREDENTIALS_ID}") {
                        docker.image("${DOCKER_HUB_REPO}:${IMAGE_TAG}").push()
                        docker.image("${DOCKER_HUB_REPO}:latest").push()
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    // cruming-k8s 저장소 클론
                    sh """
                        git clone https://github.com/${K8S_MANIFEST_REPO}.git
                    """
                    dir('cruming-k8s') {
                        // cruming-ai deployment.yaml에서 이미지 태그 업데이트
                        sh """
                            sed -i 's|image: ${DOCKER_HUB_REPO}:.*|image: ${DOCKER_HUB_REPO}:${IMAGE_TAG}|' app/cruming-ai/deployment.yaml
                        """
                        // 변경 사항 커밋 및 푸시
                        withCredentials([string(credentialsId: 'github_account', variable: 'GIT_TOKEN')]) {
                            sh """
                                git config user.email "dtj06045@naver.com"
                                git config user.name "minyub"
                                git add app/cruming-ai/deployment.yaml
                                git commit -m "Update cruming-ai image to ${IMAGE_TAG}"
                                git push https://minyub:${GIT_TOKEN}@github.com/${K8S_MANIFEST_REPO}.git ${K8S_MANIFEST_BRANCH}
                            """
                        }
                    }
                }
            }
        }


        stage('Debug Environment Variables') {
            steps {
                script {
                    echo "REPO: ${REPO}"
                    echo "GIT_BRANCH: ${GIT_BRANCH}"
                    echo "DOCKER_HUB_CREDENTIALS_ID: ${DOCKER_HUB_CREDENTIALS_ID}"
                    echo "DOCKER_HUB_REPO: ${DOCKER_HUB_REPO}"
                    echo "IMAGE_TAG: ${IMAGE_TAG}"
                }
            }
        }

    }

    post {
        always {
            cleanWs()
            script {
                sh """
                    docker ps -a -q --filter ancestor=moby/buildkit:buildx-stable-1 | xargs -r docker stop
                    docker ps -a -q --filter ancestor=moby/buildkit:buildx-stable-1 | xargs -r docker rm
                    docker system prune -a -f --volumes
                """
            }
        }
    }
}