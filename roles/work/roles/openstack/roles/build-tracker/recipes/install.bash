#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    # Clean Up

    resetLogs

    # Install Apps

    "${appFolderPath}/../../../../../../essential.bash" 'build-tracker'
    "${appFolderPath}/../../../../../../../cookbooks/mongodb/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${OPENSTACK_NODE_JS_VERSION}" "${OPENSTACK_NODE_JS_INSTALL_FOLDER}"

    # Config SSH and GIT

    addUserSSHKnownHost "$(whoami)" "$(whoami)" "$(cat "${appFolderPath}/../files/known_hosts")"

    configUserGIT "$(whoami)" "${OPENSTACK_GIT_USER_NAME}" "${OPENSTACK_GIT_USER_EMAIL}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess

    # Display Notice

    displayNotice "$(whoami)"
}

main "${@}"