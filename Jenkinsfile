pipeline {
    agent any

    environment {
        REPO                    = 'KTB-CI-17/cruming-ai'
        DOCKER_IMAGE_NAME       = 'choiseu98/ktb-cruming-ai'
        DOCKER_CREDENTIALS_ID   = 'docker_account'
        EC2_USER                = 'ubuntu'
        CONTAINER_NAME          = 'ktb-cruming-ai'
        REMOTE_PORT             = '8000'
        IMAGE_TAG               = 'latest'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'product',
                    credentialsId: 'github_account',
                    url: "https://github.com/${REPO}.git"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} .
                    """
                    sh """
                        docker tag ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest
                    """
                }
            }
        }

       stage('Push to Docker Hub') {
           steps {
               script {
                   withDockerRegistry([ credentialsId: "${DOCKER_CREDENTIALS_ID}", url: "" ]) {
                       sh """
                           docker push ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}
                       """
                   }
               }
           }
       }

        stage('Deploy to AI Server') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'ai_ip', variable: 'PRIVATE_IP')
                    ]) {
                        sshagent(['ec2_ssh']) {
                            sh """
                            ssh -v -o StrictHostKeyChecking=no ubuntu@${PRIVATE_IP} \\
                            "sudo docker pull ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} && \\
                            sudo docker stop ${CONTAINER_NAME} || true && \\
                            sudo docker rm ${CONTAINER_NAME} || true && \\
                            sudo docker run -d --name ${CONTAINER_NAME} -p ${REMOTE_PORT}:${REMOTE_PORT} ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                            """
                        }
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'ai_ip', variable: 'PRIVATE_IP')
                    ]) {
                        sshagent(['ec2_ssh']) {
                            sh """
                            ssh -v -o StrictHostKeyChecking=no ubuntu@${PRIVATE_IP} \\
                            'for i in {1..12}; do \\
                                curl -sf http://localhost:${REMOTE_PORT}/health && echo "Health check succeeded" && exit 0 || \\
                                (echo "Attempt \$i: Health check failed, retrying in 5 seconds..." && sleep 5); \\
                            done; \\
                            echo "Health check failed after all attempts" && exit 1'
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
            script {
                sh 'docker system prune -a -f --volumes'
            }
        }
    }
}
