pipeline {
    agent { label 'master' }
    stages {
        stage('Build') {
            steps {
                bat label: '', script: 'teamcenter-server\\live-deployment\\awc\\build.bat'
            }
            post {
                success {
					script{
						zip archive: true, dir: 'teamcenter-server/live-deployment/awc/', glob: 'deploy/**', zipFile: 'deploy.zip'
						jiraSendBuildInfo branch: "${scm.branches[0]}".replaceFirst(~/origin\//, ""), site: 'citplm.atlassian.net'
						cleanWs()
						}
                }
            }
        }
//        stage('Dont build an initial commit') {
//            when {
//                expression {
//                    return ${currentBuild.number} == 1
//                }
//            }
//            steps {
//                error "This is an initial build of the task. It can't have the Environment specified, but it is required for the next deployments to have it."
//            }
//        }
    }
    post {
       // always {
         //   emailext body: "<p>Jenkins build of project ${currentBuild.fullProjectName}: ${currentBuild.displayName} has finished with status: ${currentBuild.currentResult}</p><p>Check console output at <a //href=\"${currentBuild.absoluteUrl}\">${currentBuild.absoluteUrl}</a> to view the results.</p>",
         //            mimeType: 'text/html',
         //            recipientProviders: [culprits(), developers(), requestor()],
        //             subject: "Jenkins build #${currentBuild.number} of ${currentBuild.fullProjectName}: ${currentBuild.currentResult}",
		//			 replyTo: "no-reply-jenkins@mt.com"
       // }
        success {
            cleanWs()
        }
    }
}