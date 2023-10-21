<!-- markdownlint-disable MD033 -->

# Host-Proxy Install/Update Script

<div align="center">
<h1 align="center">
<img src="https://upload.wikimedia.org/wikipedia/commons/9/9c/SMS_Proxy.png" width="200" />

<p align="center">
<img src="https://img.shields.io/badge/GNU%20Bash-4EAA25.svg?style&logo=GNU-Bash&logoColor=white" alt="GNU%20Bash" />
<img src="https://img.shields.io/badge/Markdown-000000.svg?style&logo=Markdown&logoColor=white" alt="Markdown" />
<img src="https://img.shields.io/badge/JSON-000000.svg?style&logo=JSON&logoColor=white" alt="JSON" />
</p>
<img src="https://img.shields.io/github/license/ThePhaseless/Fireword_install?style&color=5D6D7E" alt="GitHub license" />
<img src="https://img.shields.io/github/last-commit/ThePhaseless/Fireword_install?style&color=5D6D7E" alt="git-last-commit" />
<img src="https://img.shields.io/github/commit-activity/m/ThePhaseless/Fireword_install?style&color=5D6D7E" alt="GitHub commit activity" />
<img src="https://img.shields.io/github/languages/top/ThePhaseless/Fireword_install?style&color=5D6D7E" alt="GitHub top language" />
</div>

---
<!-- markdownlint-disable MD051 -->
## 📖 Table of Contents

- [📖 Table of Contents](#-table-of-contents)
- [📍 Overview](#-overview)
- [📂 Repository Structure](#-repository-structure)
- [⚙️ Modules](#-modules)
- [🚀 Getting Started](#-getting-started)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 📍 Overview

A script that saves time (and sanity) by automating the installation of a home server stack that can be proxied by other server.

---

## 📂 Repository Structure

```sh
└── Fireword_install/
    ├── .gitignore
    ├── .vscode/
    │   └── settings.json
    ├── Host/
    │   ├── fireword-compose.yml
    │   ├── fireword.env.example
    │   ├── home-compose.yml
    │   ├── home.env.example
    │   ├── traefik-compose.yml
    │   └── traefik.env.example
    ├── Proxy/
    │   ├── proxy-compose.yml
    │   └── proxy.env.example
    ├── Scripts/
    │   ├── .zshrc
    │   ├── host-install.sh
    │   ├── proxy-install.sh
    │   ├── push_traefik_config.sh
    │   ├── screen-off.service
    │   ├── setup_mergerfs.sh
    │   ├── setup_portainer.sh
    │   ├── setup_raid0.sh
    │   ├── setup_rclone.sh
    │   ├── setup_samba.sh
    │   ├── setup_sudo_patch.sh
    │   ├── setup_vscode.sh
    │   ├── setup_zsh.sh
    │   ├── sync_backups.sh
    │   ├── update_proxy_stack.sh
    │   ├── update_traefik_conf.sh
    │   ├── upload_acme.sh
    │   └── vscode_web.service
    ├── installer.sh
    ├── readme.md
    └── settings.conf
```

---

## ⚙️ Modules

<details closed><summary>Root</summary>

| File                                                                                      | Summary                   |
| ---                                                                                       | ---                       |
| [installer.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/installer.sh)   | Self installs git and runs apropriate script |
| [settings.conf](https://github.com/ThePhaseless/Fireword_install/blob/main/settings.conf) | Git locations if you want to use your own config files |

</details>

<details closed><summary>Scripts</summary>

| File                                                                                                                | Summary                   |
| ---                                                                                                                 | ---                       |
| [update_proxy_stack.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/update_proxy_stack.sh)   | Pulls and starts Proxy containers (Traefik and Authelia) |
| [setup_zsh.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/setup_zsh.sh)                     | Downloads ZSH, Oh My ZSH and applies .zshrc for user |
| [update_traefik_conf.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/update_traefik_conf.sh) | Clones/Pulls Traefik Config to adequate folder |
| [.zshrc](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/.zshrc)                                 | My Oh My ZSH config |
| [upload_acme.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/upload_acme.sh)                 | Script that uploades Traefiks acme.json from Proxy to Host so that HTTPS works locally |
| [setup_sudo_patch.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/setup_sudo_patch.sh)       | Removes sudo password restrictions |
| [setup_mergerfs.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/setup_mergerfs.sh)           | Formats and creates pseudo Raid0 array and ensures that is mounted all the time |
| [setup_rclone.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/setup_rclone.sh)               | Install and config rclone |
| [host-install.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/host-install.sh)               | Script that Host device should run |
| [setup_raid0.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/setup_raid0.sh)                 | Formats and creates RAID0 array and ensures that is mounted all the time |
| [screen-off.service](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/screen-off.service)         | Service causing attached screen to turn off after 2 mins of no activity (usefull for laptops) |
| [vscode_web.service](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/vscode_web.service)         | Starts VS Code web serve as a service |
| [proxy-install.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/proxy-install.sh)             | Script that Proxy device should run |
| [sync_backups.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/sync_backups.sh)               | Uploads folders/files with rclone to backup file server |
| [setup_portainer.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/setup_portainer.sh)         | Starts portainer |
| [push_traefik_config.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/push_traefik_config.sh) | Pushes Traefik config to git |
| [setup_vscode.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/setup_vscode.sh)               | Installs VS Code |
| [setup_samba.sh](https://github.com/ThePhaseless/Fireword_install/blob/main/Scripts/setup_samba.sh)                 | Sets up samba with choosen dirs to localhost |

</details>

<details closed><summary>Proxy</summary>

| File                                                                                                    | Summary                   |
| ---                                                                                                     | ---                       |
| [proxy.env.example](https://github.com/ThePhaseless/Fireword_install/blob/main/Proxy/proxy.env.example) | Env file for compose file |
| [proxy-compose.yml](https://github.com/ThePhaseless/Fireword_install/blob/main/Proxy/proxy-compose.yml) | Proxy Traefik and Authelia file |

</details>

<details closed><summary>Host</summary>

| File                                                                                                         | Summary                   |
| ---                                                                                                          | ---                       |
| [fireword.env.example](https://github.com/ThePhaseless/Fireword_install/blob/main/Host/fireword.env.example) | Media management env file |
| [traefik.env.example](https://github.com/ThePhaseless/Fireword_install/blob/main/Host/traefik.env.example)   | Traefik env file |
| [home.env.example](https://github.com/ThePhaseless/Fireword_install/blob/main/Host/home.env.example)         | Home services env file |
| [home-compose.yml](https://github.com/ThePhaseless/Fireword_install/blob/main/Host/home-compose.yml)         | Home services compose file |
| [traefik-compose.yml](https://github.com/ThePhaseless/Fireword_install/blob/main/Host/traefik-compose.yml)   | Traefik compose file |
| [fireword-compose.yml](https://github.com/ThePhaseless/Fireword_install/blob/main/Host/fireword-compose.yml) | Media management compose file |

</details>

---

## 🚀 Getting Started

1. Fork the project and clone it on both devices.

### 2. Proxy

0. Go to `Proxy` folder.
1. Change `proxy.env.example` to your liking and rename it to `proxy.env`.
2. Change `settings.conf` to your liking.
3. Run `proxy-install.sh` on the proxy device.
4. Follow the instructions on the screen.
5. After setting up Traefik and creating acme.json file, run `bash Scripts/upload_acme.sh --force` on the proxy device.

### 3. Host

1. Go to `Host` folder.
2. Change `traefik.env.example` to your liking and rename it to `traefik.env`.
3. Change `home.env.example` to your liking and rename it to `home.env`.
4. Change `fireword.env.example` to your liking and rename it to `fireword.env`.
5. Change `settings.conf` to your liking.
6. Run `host-install.sh` on the host device.
7. Follow the instructions on the screen.
8. It is recommended to set up Host stacks using Portainer.

## 🤝 Contributing

Contributions are always welcome! Please follow these steps:

1. Fork the project repository. This creates a copy of the project on your account that you can modify without affecting the original project.
2. Clone the forked repository to your local machine using a Git client like Git or GitHub Desktop.
3. Create a new branch with a descriptive name (e.g., `new-feature-branch` or `bugfix-issue-123`).

```sh
git checkout -b new-feature-branch
```

4. Make changes to the project's codebase.
5. Commit your changes to your local branch with a clear commit message that explains the changes you've made.

```sh
git commit -m 'Implemented new feature.'
```

6. Push your changes to your forked repository on GitHub using the following command

```sh
git push origin new-feature-branch
```

7. Create a new pull request to the original project repository. In the pull request, describe the changes you've made and why they're necessary.
The project maintainers will review your changes and provide feedback or merge them into the main branch.

---

## 📄 License

This project is licensed under the `ℹ️  LICENSE-TYPE` License. See the [LICENSE-Type](LICENSE) file for additional info.

---

[↑ Return](#Top)

---
