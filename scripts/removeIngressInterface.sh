#!/bin/bash

if [[ "${#}" -lt 1 ]]
then
    echo "Invalid argument count. Minumum 1, got ${#}" >&2
    exit 1
fi

IFACES=( "${@}" )
CHANGED=0

for IFACE in "${IFACES[@]}"
do
    TARGET="/etc/nftables/includes/antiddos_ingress/${IFACE}.nft"

    if [[ ! -f "${TARGET}" ]]
    then
        echo "Interface not added: ${IFACE}"
    elif rm -f "${TARGET}"
    then
        ((CHANGED=CHANGED+1))

        echo "Interface removed: ${IFACE}"
    else
        echo "Unknown error removing ${IFACE}"
    fi
done

if [[ "${CHANGED}" = 0 ]]
then
    echo "No changes made."
else
    echo "${CHANGED} changes made. Remember to reload nftables."
fi

exit 0
