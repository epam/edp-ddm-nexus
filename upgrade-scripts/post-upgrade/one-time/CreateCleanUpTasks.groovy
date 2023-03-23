void call() {
    // Define variables
    String NEXUS_ADMIN_USERNAME = sh(script: "oc get secret nexus-admin-password -o jsonpath={.data.user} " +
            "-n ${NAMESPACE} | base64 --decode", returnStdout: true)
    String NEXUS_ADMIN_PASSWORD = sh(script: "oc get secret nexus-admin-password -o jsonpath={.data.password} " +
            "-n ${NAMESPACE} | base64 --decode", returnStdout: true)
    String NEXUS_PATH = sh(script: "oc get route nexus -o jsonpath={.spec.path} -n $NAMESPACE", returnStdout: true).replaceAll("/\\z", "")
    String NEXUS_URL = "http://nexus.${NAMESPACE}.svc:8081$NEXUS_PATH"
    def scriptsRun = ['compact-blobstore-docker-registry':'resources/compact-blobstore-docker-registry.json',
                      'compact-blobstore-edp-maven':'resources/compact-blobstore-edp-maven.json',
                      'docker-delete-unused-manifest-and-tags':'resources/docker-delete-unused-manifest.json']
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
