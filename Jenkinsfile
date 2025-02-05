pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'AWSCredentials'  
        AWS_REGION = 'us-east-1'  
        ECR_REPO_NAME = 'p3-amazon-prime'  
        IMAGE_TAG = "latest"  
        SONARQUBE_CREDENTIALS = 'Sonar-token'  
        SONARQUBE_SERVER = 'sonar-server'  
        SCANNER_HOME = tool 'sonar-scanner' 
        CLUSTER_NAME= 'amazon-prime-cluster' 
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()  
            }
        }

        stage('Checkout Code from GitHub') {
            steps {
                git branch: 'main', url: 'https://github.com/soumyatata/P3-Amazon-Prime-Video-CICD.git'
            }
        }

        stage('SonarQube Code Quality Check') {
            steps {
                script {
                    withSonarQubeEnv("${SONARQUBE_SERVER}") {  
                        sh """${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectName=p3-amazon-prime \
                        -Dsonar.projectKey=p3-amazon-prime \
                        -Dsonar.sources=."""
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, 
                    credentialsId: "${SONARQUBE_CREDENTIALS}"  
                }
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs . > trivyfs.txt'
            }
        }

        stage('Authenticate to AWS ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                       // Retrieve and store the AWS Account ID as an environment variable
                        def awsAccountId = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
                        echo "AWS Account ID: ${awsAccountId}"
                        // Store it as a global environment variable for subsequent use
                        env.AWS_ACCOUNT_ID = awsAccountId
                        
                        // Perform the login to AWS ECR
                        sh '''aws ecr get-login-password --region ${AWS_REGION} \
                        | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com'''
                    }
                }
            }
        }

        stage('Create ECR Repository if not exists') {
            steps {
                script {
                    withCredentials([aws(credentialsId: 'AWSCredentials', 
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        
                        // Configure AWS CLI with the credentials
                        sh '''
                            aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                            aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        '''
                        
                        // Check if the repository exists
                        def repoExists = sh(script: 'aws ecr describe-repositories --repository-names ${ECR_REPO_NAME} --region ${AWS_REGION} || echo "not found"', returnStdout: true).trim()
                        echo "Repository existence check status: ${repoExists}"

                        // If the repository does not exist, create it
                        if (repoExists.contains("not found")) {
                            sh "aws ecr create-repository --repository-name ${ECR_REPO_NAME} --region ${AWS_REGION}"
                        } else {
                            echo "Repository already exists, skipping creation."
                        }
                    }
                }
            }
        }

        stage('Build and Tag Docker Image') {
            steps {
                script {
                    sh '''
                        docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} .
                        docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    '''
                    
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    sh '''
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }
        stage('Cleanup Images in Jenkins Server') {
            steps {
                sh '''
                    docker rmi ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    docker images
                '''
            }
        }

        stage("Login to EKS") {
            steps {
                script {
                    withCredentials([aws(credentialsId: 'AWSCredentials', 
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        // Update kubeconfig
                        sh '''
                            aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}
                        '''
                        
                    }
                }
            }
        }

        stage ("Select Image Version") {
            steps {
                script {
                        def ECR_IMAGE_NAME = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
                        sh "sed -i 's|image: .*|image: ${ECR_IMAGE_NAME}|' k8s_files/deployment.yaml"
                }	
            }
        }
    }
}
