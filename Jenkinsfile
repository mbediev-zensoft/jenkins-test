pipeline {
	agent any
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
		stage('run unit tests') {		// run unit tests insode docker container
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
		// stage('build')				// build docker container
		// stage('upload artifacts')	// tag doker container, auth on remote registry, upload docker container
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