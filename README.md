# Laboratory 10 – Enterprise Cloud Architect

**Project:** Secure Multi-Tier Web Application
**Stack:** WordPress + MySQL 8.0 (Docker Compose) on Ubuntu Server (VirtualBox)
**Course:** CCM101 – Cloud Computing

**Name:** Bryan Sicat | [Glaiza Carmesis] | [Darlyn Mabutas] | [Rhon Jerald Sevilla] | [Alvinne Petina] 

## Summary

A private, hardened, self-backing-up WordPress deployment for CloudNova Technologies.

| Requirement | Implementation |
|---|---|
| Base infrastructure | VirtualBox VM, Ubuntu Server, NAT with port forwarding |
| Multi-tier deployment | `wordpress` (web tier) + `mysql` (database tier) via `docker-compose.yml` |
| Persistent storage | Named volumes `db_data` and `wp_data` |
| Security | UFW, default deny incoming, only 22/tcp and 80/tcp allowed; DB not published |
| Automation | `automation-script.sh` (DB backup + 7-day rotation) scheduled by cron at 02:00 |
| Documentation | `operational-manual.md`, `final-reflection.md` |

## Architecture

![Architecture diagram](architecture-diagram.png)

## Quick start

```bash
git clone https://github.com/hellomaster00/CCM101-jentorres.git
cd CCM101-jentorres/Laboratory-10-Enterprise-Cloud-Architect
cp .env.example .env && nano .env      # set strong passwords
docker compose up -d
docker compose ps
```

Open `http://localhost:8080` (VirtualBox forward) or `http://<server-ip>` and finish the WordPress setup.

## Files

- `docker-compose.yml` – infrastructure as code
- `.env.example` – template for secrets (the real `.env` is never committed)
- `automation-script.sh` – backup script
- `operational-manual.md` – handover manual
- `final-reflection.md` – Mission 1 to 10 reflection
