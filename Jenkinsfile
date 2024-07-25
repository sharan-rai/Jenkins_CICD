pipeline {
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node'
    }
    environment{
        SCANNER_HOME=tool 'sonarqube-scanner'
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/sharan-rai/Jenkins_CICD.git'
            }
        }
        stage('Sonar Code analysis') {
            steps {
                script{
                    withSonarQubeEnv('sonar-server') {
                     sh ''' 
                     $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Jenkins_CICD \
                     -Dsonar.projectKey=Jenkins_CICD '''
                    }
                }
            }
        }
        stage('Qaulity Gate') {
            steps {
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }        
        stage('NPM') {
            steps {
            sh 'npm install'
            }
        }
        stage('OWASP FS Scan'){
            steps{
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'owasp_dependency_check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('Trivy FS Scan'){
            steps{
                sh 'trivy fs . >trivyfs.txt'
            }
        }
        stage('Docker Build and Push') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker') {
                        sh '''
                        docker rm -f jenkins_cicd
                        docker build -t jenkins_cicd .
                        docker tag jenkins_cicd sharanrai1997/jenkins_cicd:latest
                        docker push sharanrai1997/jenkins_cicd:latest
                        '''
                    }
                }
            }
        }
        stage('Trivy Image Scan'){
            steps{
                sh 'trivy image sharanrai1997/jenkins_cicd:latest >trivyimagescan.txt'
            }
        }
        stage('Run Nodejs app'){
            steps{
                sh 'docker run -d --name jenkins_cicd -p 3000:3000 sharanrai1997/jenkins_cicd'
            }
        }

    }
}
