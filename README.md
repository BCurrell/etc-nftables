# /etc/nftables

Collection of nftables configs, typically stored in `/etc/nftables/`.

## Installation

This repository was built based on a system using BTRFS subvolumes for core services. This is why there is a `.subvol-ext` directory containing `nftables.conf`, which we symlink into `/etc/`. However, these subvolumes aren't a requirement.

These instructions are for a Debian-based system, but Debian is not a requirement.

Install git and nftables.

```shell
apt update
apt install -y git nftables
```

Remove any existing nftables configuration.

```shell
rm -rf /etc/nftables.conf /etc/nftables/*
```

Clone this repository.

```shell
git clone https://github.com/BCurrell/etc-nftables.git /etc/nftables
```

Symlink `/etc/nftables.conf`.

```shell
ln -s /etc/nftables/.subvol-ext/nftables.conf /etc/nftables.conf
```

(Optional) Enable the systemd service.

```shell
systemctl enable nftables.service
```

(Optional) Start the systemd service.

```shell
systemctl start nftables.service
```

## Configuration

Most of the configuration of nftables is custom to the user / server. However, in order to get the full benefits of these base configs, there are some changes that are required.

### Configure Anti-DDoS

The `netdev ingress` chain for nftables requires defining a specific interface, rather than matching on all of them. This means we need to edit the config.

Open `/etc/nftables/10_antiddos.nft`.

```shell
nano /etc/nftables/10_antiddos.nft
```

You will see the following commented block:

```none
#	chain ingress{iface} {
#		# Priority needs to be before everything, earliest NF_IP_PRI_CONNTRACK_DEFRAG (-400)
#		type filter hook ingress device {iface} priority -500; policy accept;
#
#		jump ingress
#	}
```

Rather than uncommenting and editing this block, I recommend copying it, once for each interface you want to configure DDoS protection for.

The only change is to replace both instances of `{iface}` with the name of the interface. For example, for interface `eno1`:

```none
	chain ingresseno1 {
		# Priority needs to be before everything, earliest NF_IP_PRI_CONNTRACK_DEFRAG (-400)
		type filter hook ingress device eno1 priority -500; policy accept;

		jump ingress
	}
```

Save and close the file, then restart nftables:

```shell
systemctl restart nftables
```

## File Structure

| /etc/ | Description |
| --- | --- |
| nftables.conf | Symlink from /etc/nftables/.subvol-ext/nftables.conf. Entrypoint to nftables config |

| /etc/nftables/ | Description |
| --- | --- |
| 10_antiddos.nft | Rules for anti-DDoS protection, running as early as possible to reduce CPU load. |
| 20_blacklist.nft | Rules for specific blacklisting. Included chains can be used for fail2ban / SSHGuard / etc. |
| 30_ratelimit.nft | Rules for rate limiting inbound traffic. |
| 40_accesslist.nft | Rules for inbound, outbound and forwarding access control. Majority of user configuration happens here. |
| 50_nat.nft | Rules for inbound (port forward) and outbound (masquerade) NAT. |

| /etc/nftables/.subvol-ext | Description |
| --- | --- |
| nftables.conf | Symlink to /etc/nftables.conf. |

| /etc/nftables/vars/ | Description |
| --- | --- |
| bogons_v4.nft | Static list of invalid WAN-side IPv4 subnets. |
| bogons_v6.nft | Static list of invalid WAN-side IPv6 subnets. |
