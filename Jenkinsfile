pipeline {
  agent {
    kubernetes {
      yaml '''apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:18.06
    command: [\'cat\']
    tty: true
    volumeMounts:
    - name: dockersock
      mountPath: /var/run/docker.sock
  - name: maven
    command:
    - cat
    tty: true
    env:
    - name: BUILD_NUMBER
      value: ${env.BUILD_NUMBER}
    - name: BRANCH_NAME
      value: ${env.BRANCH_NAME}
    - name: _JAVA_OPTIONS
      value: -Xmx300M
    image: maven:3.6-jdk-7
    resources:
      limits:
        memory: 1500Mi
      requests:
        cpu: 100m
        memory: 500Mi
  volumes:
  - name: dockersock
    hostPath:
      path: /var/run/docker.sock
'''
      defaultContainer 'maven'
      label 'greenhouse'
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
                         sh 'mvn -Dmaven.test.skip=true clean package'
                         sh 'cat hello'
                         container ('docker') {
                             sh 'docker build -f Dockerfile -t docker.io/runzexia/greenhouse:SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER .'
                             withCredentials([usernamePassword(passwordVariable : 'DOCKER_PASSWORD' ,usernameVariable : 'DOCKER_USERNAME' ,credentialsId : "docker-id" ,)]) {
                                 sh 'echo "$DOCKER_PASSWORD" | docker login $REGISTRY -u "$DOCKER_USERNAME" --password-stdin'
                                 sh 'docker push   docker.io/runzexia/greenhouse:SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER'
                             }
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