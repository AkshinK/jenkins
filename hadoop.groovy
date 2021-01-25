job('hadoop') {
    	parameters {
                stringParam('REPO', 'https://github.com/apache/hadoop.git', 'http://github.mtv.cloudera.com/szegedim/hadoop.git https://github.com/szegedim/hadoop.git')
                stringParam('BRANCH', 'trunk', 'Git branch')
                stringParam('MVN_PARAMS', 'clean package -fae -Pnative -Pdist -DskipTests', 'Maven parameters')        
            }
        properties {
            
            rebuild {
            autoRebuild(false)
        }
        }            
        scm {
        git {
            remote {
                url('$REPO')
            }
            branch('*/$BRANCH')

        }
        }
    triggers {
        cron('@monthly')
    }
   concurrentBuild(false)
     
    steps {
        shell('bash /hadoop_jenkins.sh')
    }
    
    publishers {
        archiveJunit('**/target/surefire-reports/*.xml') {
            allowEmptyResults()
            retainLongStdout(false)
            healthScaleFactor(1.0)
        }
    }
}

job('hadoop-sls-build') {
    	parameters {
                stringParam('REPO', 'https://github.com/apache/hadoop.git', 'Hadoop repo to pull upstream code')
            	stringParam('BASELINE_BRANCH', 'trunk', 'Git branch')
                stringParam('BRANCH', 'trunk', 'Git branch')
                stringParam('MVN_PARAMS', 'clean package -fae -Pnative -Pdist -DskipTests', 'Maven parameters')        
            }
        properties {
            
            rebuild {
            autoRebuild(false)
        }
        }            
        scm {
        git {
            remote {
                url('$REPO')
            }
            branch('*/BASELINE_BRANCH')
            branch('*/$BRANCH')

        }
        }
    triggers {
        cron('@monthly')
    }
   concurrentBuild(false)
     
    steps {
        shell('bash /sls_jenkins.sh')
    }
    
        publishers {
        archiveJunit('**/target/surefire-reports/*.xml') {
            allowEmptyResults()
            retainLongStdout(false)
            healthScaleFactor(1.0)
        }
    }
}
