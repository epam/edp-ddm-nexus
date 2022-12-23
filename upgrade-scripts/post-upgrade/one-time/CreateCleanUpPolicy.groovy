void call() {
    // Define variables
    String NEXUS_ADMIN_USERNAME = sh(script: "oc get secret nexus-admin-password -o jsonpath={.data.user} " +
            "-n ${NAMESPACE} | base64 --decode", returnStdout: true)
    String NEXUS_ADMIN_PASSWORD = sh(script: "oc get secret nexus-admin-password -o jsonpath={.data.password} " +
            "-n ${NAMESPACE} | base64 --decode", returnStdout: true)
    String NEXUS_PATH = sh(script: "oc get route nexus -o jsonpath={.spec.path} -n $NAMESPACE", returnStdout: true).replaceAll("/\\z", "")
    String NEXUS_URL = "http://nexus.${NAMESPACE}.svc:8081$NEXUS_PATH"
    def scriptsDelete =[ 'create-repo-docker-hosted','create-repo-maven-hosted']
    def scriptsRun = ['update-cleanup-task':'resources/updateExistinCleanUp.json']
    scriptsDelete.each { name ->
        // Delete script
        sh "curl -u ${NEXUS_ADMIN_USERNAME}:${NEXUS_ADMIN_PASSWORD} --header 'Content-Type: application/json' -X DELETE \"${NEXUS_URL}/service/rest/v1/script/${name}\""
    }
    scriptsRun.each { key, value ->
        // Put script
        sh "curl -u ${NEXUS_ADMIN_USERNAME}:${NEXUS_ADMIN_PASSWORD} --header 'Content-Type: application/json' -X POST \"${NEXUS_URL}/service/rest/v1/script/\"" +
                " -d @${value}"
        // Run script
        sh "curl -u ${NEXUS_ADMIN_USERNAME}:${NEXUS_ADMIN_PASSWORD} --header 'Content-Type: application/json' -X POST \"${NEXUS_URL}/service/rest/v1/script/${key}/run\""
    }
    // Boost reconciliation
    sh "oc delete pods -n ${NAMESPACE} -l mdtu-ddm.projects.epam.com/operator-name=nexus-operator"
}

return this;