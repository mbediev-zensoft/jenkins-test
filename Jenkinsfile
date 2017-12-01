pipeline {
	agent any

    environment {
        PROJECT_NAME	= 'jenkins-test'											// container name
		ECR_REPO_URL	= 'https://174962129288.dkr.ecr.eu-west-1.amazonaws.com'	// ecr repository url
		ECR_CRED_ID		= 'ecr:eu-west-1:aws-user-jenkins'							// ecr:region_id:jenkins_cred_id
		
    }

	stages {
		stage('Send Slack notification') {
			steps {
				withCredentials([[$class: 'StringBinding', credentialsId: 'slack-token', variable: 'SLACK_TOKEN']]) {
					slackSend channel: '#random',
						color: '#439FE0',
						message: "*STARTED*: Job '${env.JOB_NAME}' \n <${env.RUN_DISPLAY_URL}|*Build Log [${env.BUILD_NUMBER}]*>",
					teamDomain: 'p1gmale0n',
					token: env.SLACK_TOKEN
				}
			}
		}
		stage('tests') {
			steps {
				script {
					def node = docker.image('node:carbon-stretch')
					node.pull()
					node.inside {
						sh 'HOME=/tmp npm install'
						sh 'HOME=/tmp npm run test'
					}
				}
			}
		}
		stage('build') {
			steps {
				script {
					def nodeDockerImage = docker.build("${env.PROJECT_NAME}:${env.BRANCH_NAME}-${env.BUILD_ID}")
				}
			}
		}
		stage('upload') {
			steps {
				script {
					docker.withRegistry('https://174962129288.dkr.ecr.eu-west-1.amazonaws.com', 'ecr:eu-west-1:aws-user-jenkins') {
						docker.image("${env.PROJECT_NAME}:${env.BRANCH_NAME}-${env.BUILD_ID}").push("${env.BRANCH_NAME}-${env.BUILD_ID}")
					}
				}
			}
		}
		stage('upload version conf to s3') {
			steps {
				script {
					withAWS(credentials:'aws-user-jenkins') {
						s3Upload(file:'package.json', bucket:'elasticbeanstalk-eu-west-1-174962129288', path:'/package.json')
					}
				}
			}
		}

		// stage('deploy')				// deploy container from registry to server

		// stage('Run command on remote server'){
		// 	when{
		// 		branch 'master'
		// 	}
		// 	steps {
		// 		sshagent(['5189bf45-1660-4fb6-b025-cbd0a1fdb300']) {
		// 			sh 'ssh -o StrictHostKeyChecking=no -l ubuntu staging.goin.org uname -a'
		// 		}
		// 	}
		// }
	}

	post {
		success {
			withCredentials([[$class: 'StringBinding', credentialsId: 'slack-token', variable: 'SLACK_TOKEN']]) {
				slackSend channel: '#random',
					color: 'good',
					message: "*SUCCESSFUL*: Job '${env.JOB_NAME}'. \n <${env.RUN_DISPLAY_URL}|*Build Log [${env.BUILD_NUMBER}]*>",
					teamDomain: 'p1gmale0n',
					token: env.SLACK_TOKEN
			}
		}

		failure {
			withCredentials([[$class: 'StringBinding', credentialsId: 'slack-token', variable: 'SLACK_TOKEN']]) {
				slackSend channel: '#general',
					color: 'danger',
					message: "@here ALARM! \n *FAILED*: Job '${env.JOB_NAME}' \n <${env.RUN_DISPLAY_URL}|*Build Log [${env.BUILD_NUMBER}]*>",
					teamDomain: 'p1gmale0n',
					token: env.SLACK_TOKEN
			}
		}
	}
}