# Final Reflection – Mission 1 to Mission 10

**Name:** Bryan Sicat
**Course:** CCM101 – Cloud Computing

## The journey

I started as a Junior Trainee typing basic Linux commands and ended as an Enterprise Cloud Architect designing a full stack by myself. [Add one or two sentences about Missions 2 to 9: the tools and skills you learned in each.]

## What I built

A WordPress + MySQL stack on Ubuntu Server in VirtualBox, deployed with Docker Compose, using persistent volumes, protected by UFW with a default deny policy, and backed up daily by a Bash script run through cron.

## Challenges I overcame

- **SSH was not installed.** The connection kept aborting until I found `ssh.service` missing and installed OpenSSH.
- **Port forwarding.** I learned why a NAT address like `10.0.2.15` cannot be reached directly and how forwarding fixes it.
- **YAML errors.** A double paste duplicated my compose file. I learned that indentation and structure matter, and to validate with `docker compose config`.
- **Docker permissions.** Adding my user to the `docker` group and logging in again solved the socket error.
- **Slow, unstable network.** Image downloads failed midway, and I learned that Docker resumes completed layers.
- **Cron.** I forgot to save one edit and my test schedule kept running every minute. I learned to always verify with `crontab -l`.

## What I learned

1. Infrastructure as Code makes a system repeatable.
2. Security is layered: firewall, unpublished database, secrets outside Git.
3. Automation and backups are what make a system production-ready.
4. Documentation is part of the product.
5. Troubleshooting means reading the error and checking one layer at a time.

## What I would improve

Use HTTPS with a reverse proxy, store secrets with Docker secrets, send backups off the server, and add monitoring and alerts.

## Closing

[This course changed the way I see cloud computing. Before, I thought it was simply about storing files and accessing applications over the internet. Now, I understand that it also involves building, managing, securing, and maintaining reliable systems. Throughout the missions, I learned that becoming a cloud professional requires patience, problem-solving, and a willingness to keep learning. This journey has helped me become more confident in my technical skills and has motivated me to continue exploring cloud computing and other technologies. I know I still have a lot to learn, but I am proud of how far I have come and excited to apply what I have learned to future projects and my career in IT..]
