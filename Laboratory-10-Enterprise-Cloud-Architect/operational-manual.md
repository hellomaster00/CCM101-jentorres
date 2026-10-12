# CCM101 – Cloud Computing
## Enterprise Cloud Architect – Operational Manual

**Project:** Secure Multi-Tier Web Application
**Application Stack:** WordPress + MySQL
**Prepared by:** Bryan Sicat | [Glaiza Carmesis] | [Darlyn Mabutas] | [Rhon Jerald Sevilla] | [Alvinne Petina] 
**Section:** [BSIT 4-H]
**Instructor:** Jenkielyn C. Torres
**Date:** October 11 2026

---

## 1. Overview

This manual lets the client's IT team deploy, secure and maintain a WordPress site backed by MySQL. The stack runs in Docker containers on an Ubuntu Server VM, protected by UFW, with automatic daily database backups.

| Item | Value |
|---|---|
| Server name | `cloudnova-server` |
| OS | Ubuntu Server (headless) |
| Hypervisor | Oracle VirtualBox |
| VM network | NAT, `10.0.2.15` |
| Containers | `cloudnova-wordpress`, `cloudnova-mysql` |
| Volumes | `db_data`, `wp_data` |

> Credentials are never stored in this repository. Use your own values in `.env`.


## 2. Architecture Diagram

![Architecture Diagram](architecture-diagram_1.png)
*Figure 1: Network topology at architecture ng Secure Multi-Tier WordPress + MySQL, mula sa host machine, VirtualBox, Ubuntu Server VM, UFW firewall, hanggang sa Docker containers at persistent volumes.*

Layers, top to bottom: Host laptop (browser) → VirtualBox → Ubuntu Server VM → UFW firewall → Docker network `backend` → containers → persistent volumes. The cron job and backup script run on the VM and write to `/home/bryan/backups`.

## 3. VM Setup and Networking

1. Create a VM in VirtualBox: Linux / Ubuntu 64-bit, 2048 MB RAM, 20 GB disk.
2. Attach the Ubuntu Server ISO and install. Hostname `cloudnova-server`, **tick "Install OpenSSH server"**.
3. After install, if SSH is missing: `sudo apt install -y openssh-server && sudo systemctl enable --now ssh`.
4. Settings → Network → Adapter 1 (NAT) → Port Forwarding:

| Name | Protocol | Host Port | Guest IP | Guest Port |
|---|---|---|---|---|
| SSH | TCP | 2222 | 10.0.2.15 | 22 |
| HTTP | TCP | 8080 | 10.0.2.15 | 80 |

5. From the host: `ssh -p 2222 bryan@127.0.0.1` and browse `http://localhost:8080`.

## 4. Docker Installation

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo usermod -aG docker bryan
```

Log out and in again, then verify:

```bash
groups                      # must list docker
docker --version
docker compose version
docker run hello-world
```

## 5. Deployment

```bash
mkdir -p ~/wordpress-stack && cd ~/wordpress-stack
cp .env.example .env && nano .env     # set passwords
docker compose config                 # validate
docker compose up -d
docker compose ps
```

### docker-compose.yml explained

| Part | Purpose |
|---|---|
| `db` / `mysql:8.0` | Database tier |
| `wordpress` / `wordpress:latest` | Web tier |
| `depends_on: db` | Start order |
| `${...}` variables | Read from `.env`, so no secrets in the file |
| `db_data:/var/lib/mysql` | Persists the database |
| `wp_data:/var/www/html` | Persists WordPress files and uploads |
| `networks: backend` | Private network linking both containers |
| `ports: "80:80"` (wordpress only) | Only the web tier is exposed |
| `restart: unless-stopped` | Containers return after a reboot |

### Persistence test

Publish a post, run `sudo reboot`, log in again, run `docker compose ps`. Both containers return as `Up` and the post is still present.

## 6. Security

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 80/tcp comment 'WordPress HTTP'
sudo ufw enable
sudo ufw status verbose
```

| Control | Reason |
|---|---|
| Default deny incoming | Anything not explicitly allowed is blocked |
| Allow 22/tcp | Remote administration |
| Allow 80/tcp | The web application |
| MySQL has no `ports:` entry | Reachable only inside the Docker network |
| `.env` excluded from Git | Secrets stay out of the repository |

**Note:** Docker-published ports can bypass UFW, so only port 80 is published.

**Known limitation:** `mysqldump -p` prints a warning that passwords on the command line are insecure. For production, use a MySQL option file or Docker secrets.

## 7. Automation

`automation-script.sh` dumps the WordPress database, compresses it to `/home/bryan/backups/wordpress_db_<timestamp>.sql.gz`, deletes backups older than 7 days, and logs to `backup.log`.

```bash
chmod +x automation-script.sh
./automation-script.sh        # manual test
crontab -e
```

Cron entry (daily at 02:00, VM time is UTC):

```
0 2 * * * /home/bryan/wordpress-stack/automation-script.sh
```

Verify with `crontab -l`, `cat ~/backups/backup.log`, `ls -lh ~/backups`.

## 8. Maintenance and Troubleshooting

**Restore a backup**

```bash
gunzip < ~/backups/<file>.sql.gz | docker exec -i cloudnova-mysql mysql -u root -p wordpress
```

**Common tasks**

| Task | Command |
|---|---|
| Status | `docker compose ps` |
| Logs | `docker compose logs -f wordpress` / `db` |
| Update images | `docker compose pull && docker compose up -d` |
| Stop (keep data) | `docker compose down` |
| Stop and delete data | `docker compose down -v` (destructive) |
| Firewall status | `sudo ufw status verbose` |

**Problems we met and fixed**

| Problem | Cause | Fix |
|---|---|---|
| SSH "Connection aborted" | OpenSSH server not installed | `sudo apt install openssh-server` |
| VirtualBox "port forwarding rules not valid" | Bad character in an IP cell | Clear the cell or leave IPs blank |
| `yaml: unmarshal errors ... already defined` | Compose content pasted twice | Recreate the file once with `cat > ... << 'EOF'` |
| `permission denied ... docker.sock` | User not in `docker` group | `sudo usermod -aG docker bryan`, then re-login |
| `connection reset by peer` during pull | Unstable network | Re-run `docker compose up -d`; layers resume |
| DB password change has no effect | Old password stored in `db_data` | Use `docker compose down -v` on a fresh setup only |


## 9. Evidence (Screenshots)

### 9.1 Port Forwarding
*Figure 1: Port forwarding configuration para ma-access ang WordPress mula sa labas ng VM.*
![Port Forwarding](screenshots/01-port-forwarding.png)


### 9.2 Docker Compose Status
*Figure 2: Output ng `docker compose ps` na nagpapakitang running ang mga container.*
![Docker Compose PS](screenshots/02-docker-compose-ps.png)

### 9.3 WordPress Dashboard
*Figure 3: WordPress admin dashboard pagkatapos ng successful installation.*
![WordPress Dashboard](screenshots/03-wordpress-dashboard.png)

### 9.4 Data Persistence
*Figure 4: Test post na nanatili pa rin matapos i-restart ang mga container.*
![Persistence Post](screenshots/04-persistence-post.png)


### 9.5 Firewall Status
*Figure 5: UFW status na nagpapakita ng mga allowed na port.*
![UFW Status](screenshots/05-ufw-status.png)

### 9.6 Backup Test
*Figure 6: Resulta ng backup test gamit ang automation script.*
![Backup Test](screenshots/06-backup-test.png)


### 9.7 Scheduled Backup (Cron)
*Figure 7: Crontab entry para sa automated na backup.*

![Crontab](screenshots/07-crontab.png)


### 9.8 Docker 
*Figure 8: Listahan ng Docker volumes na ginagamit para sa persistent storage.*
![Docker Volumes](screenshots/08-docker-volumes.png)




## 10. Restoration

### 9. Restore test: before (post deleted)
![Restore before](screenshots/09-restore-before.png)

### 10. Restore test: restore command
![Restore command](screenshots/10-restore-command.png)

### 11. Restore test: after (post recovered)
![Restore after](screenshots/11-restore-after.png)


## 11. KillerCoda (screenshots)

### KillerCoda: containers running
![KillerCoda containers](screenshots/12-killercoda-compose-ps.png)

### KillerCoda: WordPress via Traffic / Ports
![KillerCoda WordPress](screenshots/13-killercoda-wordpress.png)

### KillerCoda: UFW status
![KillerCoda UFW](screenshots/14-killercoda-ufw.png)

### KillerCoda: backup run and cron proof
![KillerCoda backup](screenshots/15-killercoda-backup.png)

### KillerCoda: crontab
![KillerCoda crontab](screenshots/16-killercoda-crontab.png)





























