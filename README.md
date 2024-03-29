# Run a Keycloak Dev Container on Google Cloud Compute Engine

**TLDR**: Run `terraform apply` and visit your Keycloak server on: `http://<EXTERNAL_IP>:8080`

Runs a Keycloak dev container on a Compute Engine instance with public IP address and firewall ingress rules to allow HTTP traffic from anywhere (CIDRS can be changed) over port 8080.

## How to run

1. Configure required `terraform.tfvars` (see terraform.tfvars.template)
2. Download credentials for your Service Account and set `export GOOGLE_APPLICATION_CREDENTIALS=</path/to/credentials.json>`.
3. Run `terraform apply` and note the external IP of your instance.

```
Outputs:
external_ip_address = "<EXTERNAL_IP>"
```

4. Visit <EXTERNAL_IP>:8080 and log in to the admin console and set up your realm (you can change them later).

- Admin user: "admin"
- Admin user password: "admin"

### Optional: Change firewall ingress CIDR to your IP

- Specify the `firewall` variable in your `terraform.tfvars`, e.g.

```
firewall = {
  cidrs = [ "<YOUR_IP>/32" ]
  ports = [ 8080 ]
}
```

## How it works

### Compute Engine Container Networking

- Host networking is the default on Compute Engine with containers. When debugging containers, use `docker run --network host`.
- Verify host network is used by container: Running `ip addr show` should not show additional network interfaces.
- Firewall & port setup: Container using port 8080 and firewall allow tcp over 8080.

### Disable ssl enforcing for Keycloak admin console (requires running webserver)

```bash
/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password admin
/opt/keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE
```

### Compute Engine Startup Scripts

- Startup script as daemons: `nohup` and `&` are not enough!

```bash
setsid bash -c disable_ssl >/home/startup.log 2>&1 < /dev/null &
```

- Debugging startup scripts: View output

```bash
sudo journalctl -u google-startup-scripts.service
```

- Debugging startup scripts: Run startup script manually

```bash
sudo google_metadata_script_runner startup
```

## Roadmap: HTTPS and custom domain support

- Use a registered domain and set up A records
- Set up Keycloak container with certs
- Set up HTTPS for all traffic

## References

- [Compute Engine Startup Scripts](https://cloud.google.com/compute/docs/instances/startup-scripts/linux)
- [Run Bash Script as Daemon](https://stackoverflow.com/questions/19233529/run-bash-script-as-daemon)
- [Networking using the host network](https://docs.docker.com/network/network-tutorial-host)
- [Set up Keycloak container with certs](https://stackoverflow.com/questions/49859066/keycloak-docker-https-required)
