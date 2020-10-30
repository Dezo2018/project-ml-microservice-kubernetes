pipeline {
    agent none
    stages {
        stage('Build start') {
            agent any
            steps {
                sh 'echo "Starting the project!"'
            }
        }
        stage('Lint HTML') {
            agent any
            steps {
                sh 'tidy -q -e *.html'
            }
        }
        stage('Lint flask python app') {
            agent { docker { image 'python:3.7.2' } }
            steps {
                withEnv(["HOME=${env.WORKSPACE}"]) {
                sh '''
                    python --version
                    pip install --upgrade --user pip
                    pip install -r requirements.txt
                    #apt-get install -y pylint
                    #pylint --disable=R,C,W1203,W1202 app.py || exit 0
                    python test.py
                '''
                }
            }
        }
	    stage('Security Scan') {
	        agent any
            steps {
                 aquaMicroscanner imageName: 'alpine:latest', notCompliesCmd: 'exit 1', onDisallowed: 'fail', outputFormat: 'html'
            }
        }
        stage('Upload to AWS') {
            agent any
            steps {
                withAWS(region:'us-east-1',credentials:'jenkins1') {
                s3Upload(pathStyleAccessEnabled: true, payloadSigningEnabled: true, file:'index.html', bucket:'cloudbucket55')
                }
            }
        }
	    stage('Building docker image') {
	        agent any
	        steps {
			    sh 'docker build -t udacity .'
	        }
	    }
	    stage('Push docker image to docker-hub') {
	        agent any
		    steps {
			    withDockerRegistry([url: "", credentialsId: "desjenkins"]){
			        sh "docker tag udacity desjenkins/udacity:latest"
			        sh "docker push desjenkins/udacity:latest"
			    }
            }
		}
        stage('Deploy to AWS EKS') {
            agent any
              steps{
                  withAWS(credentials: 'jenkins1', region: 'us-east-1') {
                    sh "aws eks --region us-east-1 update-kubeconfig --name production"
                    sh "kubectl config use-context arn:aws:eks:us-east-1:526037358249:cluster/production"
                    sh "kubectl get nodes"
                    sh "kubectl get deployments"
                    sh "kubectl apply -f deployment.yml"
                    sh "kubectl set image deployments/udacity udacity=desjenkins/udacity:latest"
                    sh "kubectl get deployments"
                    sh "kubectl rollout status deployments/udacity"
                    sh "kubectl get service/udacity"
                  }
              }
        }
    }
}
