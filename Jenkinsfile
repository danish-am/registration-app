pipeline {
  agent { label 'Jenkins-Agent' }

  tools {
    jdk 'Java17'
    maven 'maven3'
  }

  environment {
    APP_NAME     = "register-app-pipeline"
    RELEASE      = "1.0.0"
    DOCKER_USER  = "danish1729"
    IMAGE_NAME   = "${DOCKER_USER}/${APP_NAME}"
    IMAGE_TAG    = "${RELEASE}-${BUILD_NUMBER}"
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
        // Only build the 'webapp' module and its dependencies
        sh "mvn clean install -pl webapp -am"
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
            docker.withRegistry('https://index.docker.io/v1/', DOCKER_PASS) {
              def docker_image = docker.build("${IMAGE_NAME}")
              docker_image.push("${IMAGE_TAG}")
              docker_image.push('latest')
            }
          }
        }
      }
    }
  }
}
