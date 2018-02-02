#!/usr/bin/groovy

podTemplate(label: 'jenkins-pipeline', containers: [
    containerTemplate(name: 'jnlp', image: 'jenkinsci/jnlp-slave:3.14-1-alpine', args: '${computer.jnlpmac} ${computer.name}', workingDir: '/home/jenkins', resourceRequestCpu: '200m', resourceLimitCpu: '300m', resourceRequestMemory: '256Mi', resourceLimitMemory: '512Mi'),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.9.2', command: 'cat', ttyEnabled: true)
],
volumes:[
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
]){

 node ('jenkins-pipeline') {

   def project = 'spearce'
   def appName = 'k8s-app'
   def imageTag = "docker.io/${project}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"

 checkout scm

 stage ('Build image') {
   container('docker') 
   sh("docker build -t ${imageTag} .")
 }
 
 stage ('Run tests') {
   container('kubectl') 
   sh("kubectl get nodes")
 }

}
}
