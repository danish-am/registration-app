pipeline {
  agent { label 'Jenkins-Agent' }

  tools {
    jdk 'Java17'
    maven 'maven3'
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
  }
}
