pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                bat label: '', script: 'teamcenter-server\\live-deployment\\build.bat'
            }
            post {
                success {
				script{
					zip archive: true, dir: 'teamcenter-server/live-deployment/', glob: 'deploy/**', zipFile: 'deploy.zip'
                    jiraSendBuildInfo branch: "${scm.branches[0]}".replaceFirst(~/origin\//, ""), site: 'citplm.atlassian.net'
                    cleanWs()
				  }                   
                }
            }
        }
    }   
}