pipeline {
    agent none
    parameters {
        choice(name: 'Environment', choices: ['Dev 600', 'Dev 601', 'Dev 602', 'Dev 603', 'Dev 604', 'Dev 605', 'Dev 606', 'Dev 607', 'Dev 608', 'Dev 609', 'Dev 610', 'Quality', 'Integration', 'Production', 'Training'], description: 'Deploy to chosen environment')
        gitParameter(name: 'Branch', type: 'PT_BRANCH', defaultValue: '', description: 'Branch to deploy from', sortMode: 'ASCENDING_SMART', listSize: '20')
    }
    stages {
        stage('Update job properties') {
            steps {
                script {
                    properties([[$class: 'BuildNowTextProperty', alternateBuildNow: 'Deploy']])
                }
            }
        }
        stage('Deploy') {
            matrix {
                axes {
                    axis {
                       name 'NODE_TO_DEPLOY'
                       values 'ch00sa600',
                              'ch00sa601',
                              'ch00sa602',
                              'ch00sa603',
                              'ch00sa604',
                              'ch00sa605',
                              'ch00sa606',
                              'ch00sa607',
                              'ch00sa608',
                              'ch00sa609',
                              'ch00sa610',
                              'ch00sa502',
                              'ch00sa503',
                              'ch00sa504',
                              'ch00sa495',
                              'ch00sa496',
                              'ch00sa474',
                              'ch00sa449',
                              'ch00sa451',
                              'ch00sa455',
                              'ch00sa525',
                              'ch00sa526',
                              'ch00sa527',
                              'ch00sa563',
                              'ch00sa572',
                              'ch00sa578',
                              'ch00sa580'
                   }
                }
                options {
                    skipDefaultCheckout true
                }
                stages {
                    stage('Deploy Single Node') {
                        when {
                            beforeAgent true
                            expression {
                                return Jenkins.get().getLabel("$NODE_TO_DEPLOY").getNodes().size() == 1 && Jenkins.get().getLabel("$params.Environment").getNodes().containsAll(Jenkins.get().getLabel("$NODE_TO_DEPLOY").getNodes())
                            }
                        }
                        options {
                            skipDefaultCheckout true
                        }
                        agent {
                            label "${NODE_TO_DEPLOY}"
                        }
                        steps {
                            echo "Deploying in ${MT4_ENVIRONMENT}/${NODE_TO_DEPLOY} from ${params.Branch} as ${params.Branch.replaceFirst(~/origin\//, "")}"
                            copyArtifacts filter: "deploy.zip", fingerprintArtifacts: true, projectName: "Subtasks/TC12-build-git/${params.Branch.replaceFirst(~/origin\//, "").replaceFirst(~/\//, "%2F")}"
                            unzip dir: '', glob: '', quiet: true, zipFile: 'deploy.zip'
                            bat label: '', script: '''call deploy\\deploy.bat
                                @echo errorlevel: %errorlevel%
                                if errorlevel 1 (
                                exit /B 1 
                                ) else ( exit /B 0
                                )'''
                        }
                        post {
                            always {
                                archiveArtifacts 'deploy-*.log'
                            }
                            cleanup {
                                cleanWs()
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            emailext body: "<p>Jenkins deploy of ${params.Branch} to ${params.Environment} has finished with status: ${currentBuild.currentResult}</p><p>Check console output at <a href=\"${currentBuild.absoluteUrl}\">${currentBuild.absoluteUrl}</a> to view the results.</p>", mimeType: 'text/html', recipientProviders: [requestor()], replyTo: 'no-reply-jenkins@mt.com', subject: "Jenkins build #${currentBuild.number} of ${currentBuild.fullProjectName}: ${currentBuild.currentResult}", to: '\'bartosz.blaszkiewicz@mt.com\', \'saratChandra.kanduri2@mt.com\''
        }
    }
}