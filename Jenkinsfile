#!/usr/bin/groovy

podTemplate(label: 'jenkins-pipeline', containers: [
    containerTemplate(name: 'jnlp', image: 'jenkinsci/jnlp-slave:3.19-1-alpine', args: '${computer.jnlpmac} ${computer.name}', workingDir: '/home/jenkins', resourceRequestCpu: '200m', resourceLimitCpu: '300m', resourceRequestMemory: '256Mi', resourceLimitMemory: '512Mi'),
    containerTemplate(name: 'docker', image: 'docker:17.12', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.10.1', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'curl', image: 'cfmanteiga/alpine-bash-curl-jq:latest', command: 'cat', ttyEnabled: true)
],
volumes:[
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
]){

 node ('jenkins-pipeline') {

   def project = 'spearce'
   def appName = 'k8s-app'
   def imageTag = "docker.io/${project}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
   def feSvcName = "apache-svc"
   def MASTER_BRANCH_NAME = "prod"

 checkout scm

 stage ('Build image') {
   container('docker') { 
   sh("docker build -t ${imageTag} .")
   }
 }
 
 stage ('Run tests') {
   container('kubectl') { 
   sh("kubectl get nodes")
   }
 }

 stage('Push Docker Image to Registry') {
   container('docker') {

                withCredentials([[$class: 'UsernamePasswordMultiBinding', 
                        credentialsId: 'docker_creds',
                        usernameVariable: 'DOCKER_HUB_USER', 
                        passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
                    
                    sh "docker login -u ${env.DOCKER_HUB_USER} -p ${env.DOCKER_HUB_PASSWORD} "
                    sh "docker push ${imageTag} "
                }
            }
        }

 stage ('Deploy Application') { 
  container('kubectl') { 
  switch (env.BRANCH_NAME) {
    // Roll out to production
    case "master":
        // Create namespace if it doesn't exist
        sh("kubectl get ns ${env.BRANCH_NAME} || kubectl create ns ${env.BRANCH_NAME}")
        // Change deployed image to the one we just built
        sh("sed -i.bak 's#gceme:1.0.0#${imageTag}#' ./k8s/production/*.yaml")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/services/")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/production/")
      container('curl') {
        sh("echo http://`kubectl --namespace=${env.BRANCH_NAME} get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
        break

    // Roll out a dev environment
    default:
        // Create namespace if it doesn't exist
        sh("kubectl get ns ${env.BRANCH_NAME} || kubectl create ns ${env.BRANCH_NAME}")
        // Don't use public load balancing for development branches
        sh("sed -i.bak 's#LoadBalancer#ClusterIP#' ./k8s/services/*.yaml")
        sh("sed -i.bak 's#gceme:1.0.0#${imageTag}#' ./k8s/dev/*.yaml")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/services/")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/dev/")
        echo 'To access your environment run `kubectl proxy`'
        echo "Then access your service via http://localhost:8001/api/v1/namespaces/${env.BRANCH_NAME}/services/${feSvcName}/proxy"
       }
    }
  }
}

   stage ('Run tests') {
     container('kubectl') { 
       sh("kubectl get svc -n ${env.BRANCH_NAME} | grep ${feSvcName} | awk '{print \$3}'")
       def foo = ("date")
       sh("echo ${foo}")
     container('curl') {
       sh("curl -I http://${feSvcName}.${env.BRANCH_NAME}") 
       }
    }
     
    }
  }
}
