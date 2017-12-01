pipeline {
	agent any

    environment {
        PROJECT_NAME	= 'jenkins-test'											// container name
		AWS_BIN			= '/opt/jenkins/.local/bin/aws'
		AWS_REGION		= 'eu-west-1'
		ECR_REPO_URL	= 'https://174962129288.dkr.ecr.eu-west-1.amazonaws.com'	// ecr repository url
		ECR_CRED_ID		= 'ecr:eu-west-1:aws-user-jenkins'							// ecr:region_id:jenkins_cred_id
		S3_BUCKET		= 'elasticbeanstalk-eu-west-1-174962129288'
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
					def nodeDockerImage = docker.build("${env.PROJECT_NAME}:${env.BRANCH_NAME}-v${env.BUILD_ID}")
				}
			}
		}
		stage('upload') {
			steps {
				script {
					docker.withRegistry('https://174962129288.dkr.ecr.eu-west-1.amazonaws.com/', 'ecr:eu-west-1:aws-user-jenkins') {
						docker.image("${env.PROJECT_NAME}:${env.BRANCH_NAME}-v${env.BUILD_ID}").push("${env.BRANCH_NAME}-v${env.BUILD_ID}")
					}
				}
			}
		}
		stage('upload version conf to s3') {
			steps {
				script {
					withCredentials([[
						$class: 'AmazonWebServicesCredentialsBinding',
						credentialsId: 'aws-user-jenkins',
						accessKeyVariable: 'AWS_ACCESS_KEY_ID',
						secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
					]]) {
						sh "sed -i='' 's/<image_name>/${env.PROJECT_NAME}/' ${env.WORKSPACE}/Dockerrun.aws.json"
						sh "sed -i='' 's/<tag_name>/${env.BRANCH_NAME}-v${env.BUILD_ID}/' ${env.WORKSPACE}/Dockerrun.aws.json"
						sh "sed -i='' 's/<memory_placeholder>/250/' ${env.WORKSPACE}/Dockerrun.aws.json"
						sh "/usr/bin/zip -r ${env.WORKSPACE}/Dockerrun.aws.${env.BRANCH_NAME}-v${env.BUILD_ID}.zip ${env.WORKSPACE}/Dockerrun.aws.json"
						sh "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} AWS_DEFAULT_REGION=${AWS_REGION} \
						${AWS_BIN} s3 cp \
						${env.WORKSPACE}/Dockerrun.aws.${env.BRANCH_NAME}-v${env.BUILD_ID}.zip \
						s3://${S3_BUCKET}/"
					}
				}
			}
    	}
		stage('deploy to beanstalk') {
			steps {
				script {
					withCredentials([[
						$class: 'AmazonWebServicesCredentialsBinding',
						credentialsId: 'aws-user-jenkins',
						accessKeyVariable: 'AWS_ACCESS_KEY_ID',
						secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
					]]) {
						sh "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} AWS_DEFAULT_REGION=${AWS_REGION} \
						${AWS_BIN} elasticbeanstalk create-application-version \
						--application-name 'Jenkins-test' \
						--version-label '${env.BRANCH_NAME}-v${env.BUILD_ID}' \
						--source-bundle S3Bucket='${S3_BUCKET}',S3Key='Dockerrun.aws.${env.BRANCH_NAME}-v${env.BUILD_ID}.zip'"

						sh "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} AWS_DEFAULT_REGION=${AWS_REGION} \
						${AWS_BIN} elasticbeanstalk update-environment \
						--environment-name 'jenkins-test' \
						--version-label '${env.BRANCH_NAME}-v${env.BUILD_ID}'"
					}
				}
			}
		}

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