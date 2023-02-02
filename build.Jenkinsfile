pipeline {
    agent { label 'master' }
    stages {
        stage('Build') {
            steps {
                bat label: '', script: 'teamcenter-server\\live-deployment\\build.bat'
            }
            post {
                success {
				script{
                    zip archive: true, dir: 'teamcenter-server/live-deployment/', glob: 'deploy/**', zipFile: 'deploy.zip'
                    } 
                   // zip archive: true, dir: 'teamcenter-server/live-deployment/', glob: 'deploy/**', zipFile: 'deploy.zip'
                    jiraSendBuildInfo branch: "${scm.branches[0]}".replaceFirst(~/origin\//, ""), site: 'citplm.atlassian.net'
                    cleanWs()
                }
            }
        }
    }
    post {
        always {
            emailext body: "<p>Jenkins build of project ${currentBuild.fullProjectName}: ${currentBuild.displayName} has finished with status: ${currentBuild.currentResult}</p><p>Check console output at <a href=\"${currentBuild.absoluteUrl}\">${currentBuild.absoluteUrl}</a> to view the results.</p>",
                     mimeType: 'text/html',
                     recipientProviders: [culprits(), developers(), requestor()],
                     subject: "Jenkins build #${currentBuild.number} of ${currentBuild.fullProjectName}: ${currentBuild.currentResult}",
					 replyTo: "no-reply-jenkins@mt.com"
        }
        success {
            cleanWs()
        }
    }
}