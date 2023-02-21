pipeline {
	agent { label 'LOCAL' }   
    stages {
        stage('Build') {
            steps {
                bat label: '', script: 'configuration\\build.bat'
            }
            post {
                success {
				script{
					zip archive: true, dir: 'configuration/', glob: 'deploy/**', zipFile: 'deploy.zip'
                    jiraSendBuildInfo branch: "${scm.branches[0]}".replaceFirst(~/origin\//, ""), site: 'citplm.atlassian.net'
					 cleanWs()
                   
				  }                   
                }
            }
        }
    }   
}