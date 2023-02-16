pipeline {
    agent { label 'Teamcenter' }
    parameters {
        choice(name: 'Environment', choices: ['', 'Teamcenter'], description: 'Deploy to chosen environment')
    }
    stages {
        stage('Update job properties') {
            steps {
                script {
                    properties([[$class: 'BuildNowTextProperty', alternateBuildNow: 'Deploy']])
                }
            }
        }
        stage('Deploy Single Node') {
            when {
                expression {
                    return "$params.Environment" == ''
                }
            }
            steps {
                error "This is an initial build of the task. It can't have the Environment specified, but it is required for the next deployments to have it."
            }
        }
        stage('Deploy') {
            matrix {
                axes {
                    axis {
                       name 'NODE_TO_DEPLOY'
                       values 'LOCAL' // development

                   }
                }
                stages {
                    stage('Deploy Single Node') {
                        when {
                            beforeAgent true
                            expression {
                                return "$params.Environment".size() > 0 && Jenkins.get().getLabel("$NODE_TO_DEPLOY").getNodes().size() == 1 && Jenkins.get().getLabel("$params.Environment").getNodes().containsAll(Jenkins.get().getLabel("$NODE_TO_DEPLOY").getNodes())
                            }
                        }
                        options {
                            skipDefaultCheckout true
                        }
                        agent {
                            label "${NODE_TO_DEPLOY}"
                        }
                        steps {
                            fileOperations([fileDeleteOperation(excludes: '', includes: 'deploy.zip'), folderDeleteOperation('deploy'), folderDeleteOperation('customizations')])
                            echo "Deploying in ${ST4_ENVIRONMENT}/${NODE_TO_DEPLOY} from ${scm.branches[0]} as ${"${scm.branches[0]}".replaceFirst(~/origin\//, "")}"
                            copyArtifacts filter: "deploy.zip", fingerprintArtifacts: true, projectName: "Subtasks/TC12-build-customizations-git/${"${scm.branches[0]}".replaceFirst(~/origin\//, "").replaceFirst(~/\//, "%2F")}"
                            unzip dir: '', glob: '', quiet: true, zipFile: 'deploy.zip'
                            fileOperations([folderRenameOperation(destination: 'customizations', source: 'deploy')])
                            copyArtifacts filter: "deploy.zip", fingerprintArtifacts: true, projectName: "Subtasks/TC12-build-git/${"${scm.branches[0]}".replaceFirst(~/origin\//, "").replaceFirst(~/\//, "%2F")}"
                            unzip dir: '', glob: '', quiet: true, zipFile: 'deploy.zip'
                            bat label: '', script: '''call deploy\\deploy.bat
                                @echo errorlevel: %errorlevel%
                                if errorlevel 1 (
                                exit /B 1 
                                ) else ( exit /B 0
                                )'''
                            bat label: '', script: '''call customizations\\deploy.bat
                                @echo errorlevel: %errorlevel%
                                if errorlevel 1 (
                                exit /B 1 
                                ) else ( exit /B 0
                                )'''
                        }
                        post {
                            always {
                                jiraSendDeploymentInfo site: 'citplm.atlassian.net', environmentId: "$params.Environment", environmentName: "$params.Environment", environmentType: "$params.Environment" == "Production" || "$params.Environment" == "Training" ? 'production' : "$params.Environment" == "LOCAL" ? 'staging' : "$params.Environment" == "Integration" ? 'testing' : 'development'
                                archiveArtifacts 'deploy-*.log'
                            }
                            success {
                                cleanWs()
                            }
                        }
                    }
                }
            }
        }
    }
   
}