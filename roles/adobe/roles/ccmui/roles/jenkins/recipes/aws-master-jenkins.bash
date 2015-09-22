#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../cookbooks/jenkins/attributes/master.bash"
    source "${appPath}/../../../../../../../cookbooks/nginx/attributes/default.bash"
    source "${appPath}/../../../../../../../libraries/util.bash"
    source "${appPath}/../attributes/amazon-master.bash"

    # Clean Up

    resetLogs

    # Extend HD

    "${appPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_JENKINS_DISK}" "${CCMUI_JENKINS_MOUNT_ON}"

    # Install Apps

    local -r hostName='jenkins-pub.ccmui.adobe.com'

    "${appPath}/../../../../../../essential.bash" "${hostName}"
    "${appPath}/../../../../../../../cookbooks/maven/recipes/install.bash"
    "${appPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CCMUI_JENKINS_NODE_JS_VERSION}" "${CCMUI_JENKINS_NODE_JS_INSTALL_FOLDER}"
    "${appPath}/../../../../../../../cookbooks/jenkins/recipes/install-master.bash"
    "${appPath}/../../../../../../../cookbooks/jenkins/recipes/install-master-plugins.bash" "${CCMUI_JENKINS_INSTALL_PLUGINS[@]}"
    "${appPath}/../../../../../../../cookbooks/jenkins/recipes/safe-restart-master.bash"
    "${appPath}/../../../../../../../cookbooks/packer/recipes/install.bash"
    "${appPath}/../../../../../../../cookbooks/ps1/recipes/install.bash" --host-name "${hostName}" --users "${JENKINS_USER_NAME}, $(whoami)"

    # Config Nginx

    "${appPath}/../../../../../../../cookbooks/nginx/recipes/install.bash"

    header 'CONFIGURING NGINX PROXY'

    local -r nginxConfigData=(
        '__NGINX_PORT__' "${NGINX_PORT}"
        '__JENKINS_TOMCAT_HTTP_PORT__' "${JENKINS_TOMCAT_HTTP_PORT}"
    )

    createFileFromTemplate "${appPath}/../templates/nginx.conf.conf" "${NGINX_INSTALL_FOLDER}/conf/nginx.conf" "${nginxConfigData[@]}"

    stop "${NGINX_SERVICE_NAME}"
    start "${NGINX_SERVICE_NAME}"

    # Clean Up

    cleanUpSystemFolders
}

main "${@}"