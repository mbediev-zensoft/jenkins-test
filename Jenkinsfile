pipeline {
	agent any
	stages {
		stage('Simple stage') {
			steps {
				withCredentials([[$class: 'StringBinding', credentialsId: 'slack-token', variable: 'SLACK_TOKEN']]) {
					slackSend channel: '#random',
								color: '#439FE0',
								message: "*STARTED*: Job '${env.JOB_NAME}' \n <${env.RUN_DISPLAY_URL}|*Build Log [${env.BUILD_NUMBER}]*>",
								token: env.SLACK_TOKEN,
								teamDomain: 'p1gmale0n'
				}
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
			withCredentials([[$class: 'StringBinding', credentialsId: 'slack-token', variable: 'SLACK_TOKEN']]) {
				slackSend channel: '#random',
							color: 'good',
							message: "*SUCCESSFUL*: Job '${env.JOB_NAME}'. \n <${env.RUN_DISPLAY_URL}|*Build Log [${env.BUILD_NUMBER}]*>",
							token: env.SLACK_TOKEN,
							teamDomain: 'p1gmale0n'
			}
		}

		failure {
			withCredentials([[$class: 'StringBinding', credentialsId: 'slack-token', variable: 'SLACK_TOKEN']]) {
				slackSend channel: '#random',
							color: 'danger',
							message: "@here ALARM! \n *FAILED*: Job '${env.JOB_NAME}' \n <${env.RUN_DISPLAY_URL}|*Build Log [${env.BUILD_NUMBER}]*>",
							token: env.SLACK_TOKEN,
							teamDomain: 'p1gmale0n'
			}
		}
	}
}