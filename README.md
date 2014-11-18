# Sloef

Sloef is a small module that checks if online services (like web pages) are still online. On Failure it sends an email to a preconfigured email address.

## Installation

`npm install -g sloef`

## Configuration

A configuration file (`/etc/sloef.json`) should have the content:
```
{
  "server": {
    "user": "xxx@xxx.xx",
    "password": "xxx",
    "host": "smtp.gmail.com",
    "ssl": true
  },
  "from": "xxx@xxx.xx",
  "to": "xxx@xxx.xx",
  "retryDelay": 60,
  "retryCount": 5,
  "urls": [
    "http://www.nodejs.org"
  ]
}
```

## Systemd

After copying (and adapting) the systemd service and timer file, the timer (or service) can be enabled and sloef is running.
```
cp systemd/sloef.service /etc/systemd/system
cp systemd/sloef.timer /etc/systemd/system
sudo systemctl enable sloef.timer
```
