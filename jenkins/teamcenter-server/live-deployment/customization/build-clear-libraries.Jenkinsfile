pipeline {
    agent { label 'Teamcenter' }
    stages {
        stage('Build') {
            steps {
				zip archive: true, dir: 'customization', glob: 'jenkins/**', zipFile: 'deploy.zip'
				jiraSendBuildInfo branch: "${scm.branches[0]}".replaceFirst(~/origin\//, ""), site: 'citplm.atlassian.net'
				cleanWs()
            }
        }
    }
}