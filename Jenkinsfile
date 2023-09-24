#!groovy
def lastCommitInfo = ""
def commitContainsSkip = 0
def shouldBuild = false
def nightlyBuild = false

// Multi-branch pipeline. Build once a day from a "develop" branch only
// different triggers can be found https://www.jenkins.io/doc/book/pipeline/syntax/
// every day at time 5
CRON_SETTINGS = env.BRANCH_NAME == "develop" ? '0 1 * * *': ''

def isTimeTriggeredBuild() {
    for (Object currentBuildCause : currentBuild.rawBuild.getCauses()) {
        return currentBuildCause.class.getName().contains('TimerTriggerCause')
    }
    return false
}

boolean isTimeTriggered = isTimeTriggeredBuild()

def cancelBuild() {
    def jobname = env.JOB_NAME
    def buildnum = env.BUILD_NUMBER.toInteger()

    def job = Jenkins.instance.getItemByFullName(jobname)
    for (build in job.builds) {
        if (!build.isBuilding()) { continue }
        if (buildnum == build.getNumber().toInteger()) { continue; println 'equals' }
        build.doStop()
    }
}

pipeline {
    agent iOS
    triggers {
        cron(CRON_SETTINGS)
    }

    environment {
        LC_ALL = 'en_US.UTF-8'
        LANG    = 'en_US.UTF-8'
        LANGUAGE = 'en_US.UTF-8'
        FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT=60
    }

    stages {
        stage('Init') {
            steps {
                cancelBuild()
                script {
                    lastCommitInfo = sh(script: "git log -1", returnStdout: true).trim()
                    commitContainsSkip = sh(script: "git log -1 | grep '.*\\[skip ci\\].*'", returnStatus: true)
                    if (isTimeTriggered == true) {
                        env.nightlyBuild = true 
                        env.shouldBuild = false  
                    }
                }
            }
        }

        // this stage is needed to avoid a build that is not needed when we create release branch from master
        stage('Master Merge') {
            when {
                branch 'main'
                beforeAgent true
                expression {
                    return env.shouldBuild != "false"
                }
            }

            steps {
                script {
                    try { 
                        sh 'bundle config set --local path vendor/bundle'               
                        sh 'bundle install'
                        sh 'bundle exec fastlane buildForTest'
                    } catch(exc) {
                        sh "echo '${error}'"
                        currentBuild.result = "UNSTABLE"
                        error('There are failed tests.')
                    }
                }
            }
        }
    }

    post {
        // Clean after build
        always {
            cleanWs cleanWhenFailure: false, notFailBuild: true
        }
    }
}
