pipeline {
    agent { label 'Teamcenter' }
    parameters {
        choice(name: 'Environment', choices: ['', 'LOCAL'], description: 'Deploy to chosen environment')
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
                       values 'Teamcenter' // development

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
							fileOperations([fileDeleteOperation(excludes: '', includes: 'deploy.zip'), folderDeleteOperation('deploy')])
                            echo "Deploying in ${ST4_ENVIRONMENT}/${NODE_TO_DEPLOY} from ${scm.branches[0]} as ${"${scm.branches[0]}".replaceFirst(~/origin\//, "")}"
                            copyArtifacts filter: "deploy.zip", fingerprintArtifacts: true, projectName: "Subtasks/CLEAR-LIBRARIES/TC12-clear-libraries-build/${"${scm.branches[0]}".replaceFirst(~/origin\//, "").replaceFirst(~/\//, "%2F")}"
                            unzip dir: '', glob: '', quiet: true, zipFile: 'deploy.zip'
                            bat label: '', script: '''call jenkins\\deploy_clear_libraries.bat
                                @echo errorlevel: %errorlevel%
                                if errorlevel 1 (
                                exit /B 1 
                                ) else ( exit /B 0
                                )'''
                        }
                        post {
                            always {
                                jiraSendDeploymentInfo site: 'citplm.atlassian.net', environmentId: "$params.Environment", environmentName: "$params.Environment", environmentType: "$params.Environment" == "Production" || "$params.Environment" == "Training" ? 'production' : "$params.Environment" == "Quality" ? 'staging' : "$params.Environment" == "Integration" ? 'testing' : 'development'
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
    post {
		success {  
             emailext body: "<p>Jenkins build of project ${currentBuild.fullProjectName}: ${currentBuild.displayName} has finished with status: ${currentBuild.currentResult}</p><p>Check console output at <a href=\"${currentBuild.absoluteUrl}\">${currentBuild.absoluteUrl}</a> to view the results.</p>", mimeType: 'text/html', recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider'], [$class: 'FailingTestSuspectsRecipientProvider'], [$class: 'FirstFailingBuildSuspectsRecipientProvider'], [$class: 'UpstreamComitterRecipientProvider']], subject: "Jenkins build #${currentBuild.number} of ${currentBuild.fullProjectName}: ${currentBuild.currentResult}", replyTo: "no-reply-jenkins@mt.com" 
         }  
         failure {  
             emailext body: "<p>Jenkins build of project ${currentBuild.fullProjectName}: ${currentBuild.displayName} has finished with status: ${currentBuild.currentResult}</p><p>Check console output at <a href=\"${currentBuild.absoluteUrl}\">${currentBuild.absoluteUrl}</a> to view the results.</p>", mimeType: 'text/html', recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider'], [$class: 'FailingTestSuspectsRecipientProvider'], [$class: 'FirstFailingBuildSuspectsRecipientProvider'], [$class: 'UpstreamComitterRecipientProvider']], subject: "Jenkins build #${currentBuild.number} of ${currentBuild.fullProjectName}: ${currentBuild.currentResult}", replyTo: "no-reply-jenkins@mt.com", to: "deepa.ramakrishna@vcadplm.com,Sarat.kanduri@mt.com,niraj.ravindra.shaha@accenture.com"
         }  
    }
}