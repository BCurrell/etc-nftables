#!/usr/sbin/nft -f

if [[ "${#}" -lt 1 ]]
then
    echo "Invalid argument count. Minumum 1, got ${#}" >&2
    exit 1
fi

TEMPLATE="/etc/nftables/includes/antiddos_ingress/template"

IFACES=( "${@}" )
CHANGED=0

for IFACE in "${IFACES[@]}"
do
    TARGET="/etc/nftables/includes/antiddos_ingress/${IFACE}.nft"

    if ! ip link show dev "${IFACE}" &> /dev/null
    then
        echo "Invalid interface: ${IFACE}"
    elif [[ -f "${TARGET}" ]]
    then
        echo "Interface already added: ${IFACE}"
    elif IFACE="${IFACE}" envsubst < "${TEMPLATE}" > "${TARGET}"
    then
        ((CHANGED=CHANGED+1))

        echo "Interface added: ${IFACE}"
    else
        echo "Unknown error adding ${IFACE}"
    fi
done

if [[ "${CHANGED}" = 0 ]]
then
    echo "No changes made."
else
    echo "${CHANGED} changes made. Remember to reload nftables."
fi

exit 0
