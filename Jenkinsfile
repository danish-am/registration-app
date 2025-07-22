pipeline{
  agent{ label 'Jenkins-Agent'}
  tools{
    jdk 'Java17'
    maven 'maven3'
  }
  stages{
    stage("Cleanup Workspace"){
      steps{
        cleanWs()
        }     
    }
   stages("Checkout from SCM"){
     steps{
       git branch: 'main', credentialsId: 'github', url: 'https://github.com/danish-am/registration-app'
        }
   }
   stages("Build Application"){
     steps{
       sh "mvn clean package"
     }
   }
    stages("Test Application"){
      steps{
        sh "mvn test"
      }
    }
  }
}
