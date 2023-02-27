pipeline {
    agent { label 'Teamcenter' }
    stages {
        stage('Build') {
            steps {
                bat label: '', script: 'customization\\build.bat'
            }
            post {
                success {                    
					script{
					zip archive: true, dir: 'customization/', glob: 'deploy/**', zipFile: 'deploy.zip'
                    jiraSendBuildInfo branch: "${scm.branches[0]}".replaceFirst(~/origin\//, ""), site: 'citplm.atlassian.net'
					 cleanWs()
                   
				  }
                }
            }
        }
    }   
}