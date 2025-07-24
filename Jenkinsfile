pipeline {
  agent any

  parameters {
    string(name: 'EC2_IP', defaultValue: '', description: 'Public IP address of the EC2 instance')
  }

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
        withCredentials([sshUserPrivateKey(credentialsId: 'ec2-key', keyFileVariable: 'SSH_KEY')]) {
          sh '''
            chmod 600 $SSH_KEY

            ssh -o StrictHostKeyChecking=no -i $SSH_KEY ubuntu@${EC2_IP} << EOF
              set -e

              # Install Docker if not present
              if ! command -v docker &> /dev/null; then
                echo "Docker not found. Installing..."
                sudo apt update
                sudo apt install -y docker.io
                sudo usermod -aG docker ubuntu
                sudo systemctl enable docker
                sudo systemctl start docker
              fi

              # Pull latest image and run container
              sudo docker pull mystic8642/chat-app:latest
              sudo docker stop chatapp || true
              sudo docker rm chatapp || true
              sudo docker run -d -p 8000:8000 \\
                --env-file /home/ubuntu/server.env \\
                --env CORS_ORIGIN=http://${EC2_IP}:8000 \\
                --name chatapp mystic8642/chat-app:latest
            EOF
          '''
        }
      }
    }
  }
}
