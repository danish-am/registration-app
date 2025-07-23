pipeline {
  agent { label 'Jenkins-Agent' }

  tools {
    jdk 'Java17'
    maven 'maven3'
  }

  environment {
    APP_NAME = "register-app-pipeline"
    RELEASE = "1.0.0"
    DOCKER_USER = "danish1729"
    IMAGE_NAME = "${DOCKER_USER}/${APP_NAME}"
    IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
    JENKINS_API_TOKEN = credentials("JENKINS_API_TOKEN")
  }

  stages {
    stage("Cleanup Workspace") {
      steps {
        cleanWs()
      }
    }

    stage("Checkout from SCM") {
      steps {
        git branch: 'main', credentialsId: 'github', url: 'https://github.com/danish-am/registration-app'
      }
    }

    stage("Build Application") {
      steps {
        sh "mvn clean package"
      }
    }

    stage("Test Application") {
      steps {
        sh "mvn test"
      }
    }

    stage("SonarQube Analysis") {
      steps {
        script {
          withSonarQubeEnv(credentialsId: 'jenkins-sonar-qube-token') {
            sh "mvn sonar:sonar"
          }
        }
      }
    }

    stage("Quality Gate") {
      steps {
        script {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage("Build and Push Docker Image") {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            def dockerImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")

            docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
              dockerImage.push("${IMAGE_TAG}")
              dockerImage.push("latest")
            }
          }
        }
      }
    }

    stage("Trivy Scan") {
      steps {
        script {
          sh """
            docker run \
              -v /var/run/docker.sock:/var/run/docker.sock \
              aquasec/trivy image ${IMAGE_NAME}:latest \
              --no-progress \
              --scanners vuln \
              --exit-code 0 \
              --severity HIGH,CRITICAL \
              --format table
          """
        }
      }
    }

    stage("Cleanup Artifacts") {
      steps {
        script {
          sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
          sh "docker rmi ${IMAGE_NAME}:latest || true"
        }
      }
    }

    stage("Trigger CD Pipeline") {
      steps {
        script {
          withCredentials([string(credentialsId: 'jenkins-api-token', variable: 'JENKINS_API_TOKEN')]) {
            sh """
              curl -v -k -u danish:${JENKINS_API_TOKEN} \\
              -X POST \\
              -H 'cache-control: no-cache' \\
              -H 'Content-Type: application/x-www-form-urlencoded' \\
              --data-urlencode 'IMAGE_TAG=${IMAGE_TAG}' \\
              'http://ec2-3-145-182-195.us-east-2.compute.amazonaws.com:8080/job/gitops-register-app-cd/buildWithParameters?token=gitops'
            """
          }
        }
      }
    }
  }
}
