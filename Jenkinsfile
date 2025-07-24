pipeline {
  agent any

  environment {
    IMAGE_NAME = 'mystic8642/chat-app:latest'
  }

  stages {

    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/vaibhav2972/ChatApp.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME .'
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push $IMAGE_NAME
          '''
        }
      }
    }

    stage('Debug Info') {
      steps {
        sh '''
          echo "Running as user: $(whoami)"
          id
          docker ps -a
          docker images
        '''
      }
    }

    stage('Deploy to EC2') {
      steps {
        sshagent (credentials: ['ec2-key']) {
          sh '''
            ssh -o StrictHostKeyChecking=no ubuntu@16.171.42.81 "
              docker pull mystic8642/chat-app:latest &&
              docker stop chatapp || true &&
              docker rm chatapp || true &&
              docker run -d -p 8000:8000 --env-file /home/ubuntu/server.env --name chatapp mystic8642/chat-app:latest
            "
          '''
        }
      }
    }
  }
}
