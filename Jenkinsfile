pipeline {
	agent any
	stages {
		stage('Simple stage') {
			steps {
				wrappers {
					credentialsBinding {
						string('slackToken', 'slack-token')
					}
				}
				// send build started notifications
				withCredentials([string(credentialsId: 'slack-token', variable: 'slackToken')]) {
					slackSend (color: '#FFFF00', message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
						baseUrl: "${slackToken}", teamDomain: 'p1gmale0n')	
				}
				sh 'env'
			}
		}
		stage('Run command on remote server'){
			when{
				branch 'master'
			}
			steps {
				sshagent(['5189bf45-1660-4fb6-b025-cbd0a1fdb300']) {
					sh 'ssh -o StrictHostKeyChecking=no -l ubuntu staging.goin.org uname -a'
				}
			}
		}
	}

	post {
		success {
		slackSend (color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
		}

		failure {
		slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
		}
	}
}