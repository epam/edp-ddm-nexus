void call() {
    sh "oc delete edpcomponent nexus -n ${NAMESPACE} --ignore-not-found=true"
}
return this;