# Using Tailscale with an OrbStack VM on macOS

This repository demonstrates how to use **OrbStack** on macOS to provision an Ubuntu virtual machine (VM), and then add it to your tailnet.

Unlike minimal container runtimes that lack native kernel modules, OrbStack provides a fully capable Linux kernel environment. This allows Tailscale to leverage standard kernel networking (`/dev/net/tun`) rather than relying on userspace-networking workarounds.

OrbStack first spins up a temporary VM instance which allows `cloud-init` to pull its configuration from `dev-server.yml` and then stops the VM. Then OrbStack wakes up the pre-configured VM, adds it to your tailnet using an auth key and enables Tailscale SSH. You can then SSH to your VM from anywhere, without exposing host ports.

This example also demonstrates a macOS-specific method for securely storing your Tailscale auth key in Apple Keychain. Due to macOS security sandbox restrictions, the guest VM cannot directly execute `security find-generic-password` to pull secrets from the host. Instead, the credential must be injected from the host macOS environment during provisioning, as shown in `run.sh`.

NB: Apple's Security Framework is designed around an interactive desktop login session. Remote SSH sessions are not the same as local GUI login sessions, so they don't usually have access to the user's unlocked login keychain. In practice, this means you can't remotely run the `run.sh` script to create an OrbStack VM.

## Modify access controls

Before launching the VM, configure your Tailscale Access Control Lists (ACLs) to handle the automated registration and permissions.

### Create a tag

Go to [Access controls > Tags](https://login.tailscale.com/admin/acls/visual/tags) and define a server tag:

* **Tag name:** `myservers`
* **Tag owners:** `your-email@example.com`

### Modify the Tailscale SSH access controls

Go to [**Access controls > Tailscale SSH**](https://login.tailscale.com/admin/acls/visual/tailscale-ssh/) and ensure your policy permits access to the tagged servers and specified users:

```json
{
  "action": "accept",
  "src": ["autogroup:admin"],
  "dst": ["tag:myservers"],
  "users": ["player1", "player2"]
}
```

* Add your new tag (`"myservers"`) to the **Destination** (`dst`) array.
* Add the Linux usernames defined in your `cloud-config` (`"player1", "player2"`) to the **Destination users** (`users`) array.
* Change `"action"` from `"check"` to `"accept"` for seamless SSH access.

## Create a Tailscale auth key

1. Generate an auth key via the [Tailscale Admin Keys panel](https://login.tailscale.com/admin/settings/keys) with these configurations:
* **Reusable:** Enabled
* **Pre-authorized:** Enabled
* **Tags:** Choose the newly created tag: `tag:myservers`

2. Store the newly created auth key in Keychain:

```
./store-ts-key-keychain.sh
```

*(Note: This creates an entry named `tailscale-auth-key-dev-server` in your Keychain).*

## Build and provision the VM

```
./build.sh
```

## Start the VM and add it to your tailnet

```
./run.sh
```

## Connect to the VM

Once `run.sh` finishes authenticating the machine, you can connect directly over your tailnet using Tailscale SSH or jump straight into the machine locally via OrbStack:

* **MagicDNS name:** `ssh player1@dev-server`
* **built-in local SSH proxy:** `ssh player1@dev-server@orb`
* **CLI:** `orb -m dev-server`

## Example: git

Once Tailscale SSH is setup correctly, it's simple to use `git` remotely. Let's
assume that we have a `git` repo on `dev-server`. We can simply clone it directly without any extra authentication:

```
git clone https://github.com/player1/my_proj
```

---

## Files

* `dev-server.yml`: A `cloud-init` recipe that specifies environment configurations, system locales, default development packages, user access profiles and installation tasks for the Tailscale engine.
* `build.sh`: Builds and provisions an Ubuntu 25.10 environment using the `cloud.init` configuration in `dev-server.yml`.
* `run.sh`: Pulls the auth key from Keychain and brings up the Tailscale interface (`tailscale up`) inside the VM with SSH enabled.
* `cleanup.sh`: Fully tears down the setup. It logs out the VM from your tailnet, destroys the OrbStack instance, and wipes the auth key from Keychain.
* `store-ts-key-keychain.sh`: Copies the auth key from the system clipboard and stores it in Keychain.
