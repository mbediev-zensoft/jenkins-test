pipeline {
	agent any
	stages {
		stage('Show env variables') {
			when{
				expression {
				env.CHANGE_TARGET == 'master'
				}
			}
			steps {
				sh 'env'
			}
		}
		stage('Get linux verison on remote server'){
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
}