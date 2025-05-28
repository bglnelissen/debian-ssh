# Debian SSH Docker Container

A secure SSH-enabled Debian Docker container with the following features:
- SSH key-based authentication only (password auth disabled)
- Dynamic host key generation on first start
- Mounted volume support for persistent data
- Random password generation for sudo access
- Secure by default configuration

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/bglnelissen/debian-ssh.git
cd debian-ssh
```

2. Add your SSH public key:
```bash
# Copy your public key to authorized_keys
cat ~/.ssh/id_ed25519.pub >> authorized_keys  # or id_rsa.pub
```

3. Build and run:
```bash
docker build -t debian-ssh .
docker run -d --name debian-ssh -p 2222:22 -v /path/to/data:/home/bas/todo debian-ssh
```

4. Connect:
```bash
ssh -p 2222 bas@localhost
```

## Features

- **Secure by Default**:
  - Password authentication disabled
  - Root login disabled
  - Key-based authentication only
  - Fresh host keys generated on container start

- **User Setup**:
  - Non-root user 'bas' with sudo rights
  - Random password generated for sudo access (shown during build)
  - SSH authorized_keys configuration

- **Volume Support**:
  - Mount local directories for persistent data
  - Default mount point: `/home/bas/todo`

## Security Notes

1. Host keys are generated on first container start and persist for the container's lifetime
2. A new random password is generated during build for sudo access
3. All sensitive files are excluded via .gitignore
4. No passwords or private keys are stored in the repository

## Configuration

The container can be customized through:
- Modifying the Dockerfile
- Adding SSH public keys to authorized_keys
- Mounting different volumes
- Changing exposed ports

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is open source and available under the MIT License. 

## Credits

Created by [Bastiaan Nelissen](https://github.com/bglnelissen), a medical professional who loves to code. Check out my other projects at [github.com/bglnelissen](https://github.com/bglnelissen). 