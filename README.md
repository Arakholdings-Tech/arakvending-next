# Vending machine retail software

This software is used to accept payments on the vending machine via EftCorp's eSocket.POS.

This software communicates with the vending via RS232 serial connection usually with path `/dev/usb0`


## Installation
- To get started install the latest version of Ubuntu. Download an image of ubuntu on Ubuntu official website.

- If the vending machine has touch screen, download a desktop version of Ubuntu, otherwise get a server image

- Install Ubuntu on a mini PC

## Setting up the retail software
This software is built with Ruby on Rails
 - To get started install ruby using [Rbenv](https://github.com/rbenv/rbenv)
 - Follow the installation steps.
 - Once ruby is installed clone this repo
 - `git clone git@github.com:Arakholdings-Tech/arakvending-next.git`
 - Navigate to the directory by `cd arakvending-next`
 - Install dependincies by running `bundle install`
 - Seed the database by running `rails db:seed`
 - using a text editor like nano, edit the .env file `nano .env`
 - add the following
   ```bash
   ESOCKET_HOST=127.0.0.1
   ESOCKET_PORT=23001
   ESOCKET_TERMINAL_ID=TERMINAL
   ```
## Installing esocket.Pos
Install eSocket.POS from eft by following the steps outlined in this document
https://eftcorpdev.sharepoint.com/
Once eSocket.POS is installed. Configure the terminal id, You get this from your bank, also liase with eftCorp

### Starting and running the software
This software must run on startup and to archive this, install, `supervisor`
```bash
sudo apt-get install supervisor
```
Enable the supervisor service
```bash
sudo systemctl enable --now supervisor
```

Add the following configuration to run this program using supervisor
```bash
sudo nano /etc/supervisor/conf.d/vending.conf
```

add the following config
```bash
TODO: supervisor config
```

Save and reload supervisor

```bash
sudo supervisorctl reload
```

```bash
sudo supervisorctl start "vending:*"
```

The POS device should initialize


