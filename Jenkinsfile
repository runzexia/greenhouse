pipeline {
  agent {
    node {
      label 'maven'
    }
  }

    parameters {
        string(name:'TAG_NAME',defaultValue: '',description:'')
    }
     stages {
            stage ('checkout scm') {
                steps {
                    checkout(scm)
                }
            }

             stage ('build & push') {
                 steps {
                     container ('maven') {
                         sh 'mvn -o -Dmaven.test.skip=true clean package'
                         sh 'docker build -f Dockerfile -t docker.io/runzexia/greenhource:SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER .'
                         withCredentials([usernamePassword(passwordVariable : 'DOCKER_PASSWORD' ,usernameVariable : 'DOCKER_USERNAME' ,credentialsId : "docker-id" ,)]) {
                             sh 'echo "$DOCKER_PASSWORD" | docker login $REGISTRY -u "$DOCKER_USERNAME" --password-stdin'
                             sh 'docker push   docker.io/runzexia/greenhource:SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER'
                         }
                     }
                 }
             }
             stage('deploy to dev') {
               when{
                 branch 'master'
               }
               steps {
                 input(id: 'deploy-to-dev', message: 'deploy to dev?')
                 kubernetesDeploy(configs: 'deploy/**', enableConfigSubstitution: true, kubeconfigId: "demo-kubeconfig")
               }
             }
      }
}