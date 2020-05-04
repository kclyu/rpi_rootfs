#!/bin/bash
apt update
apt full-upgrade -y
apt install -y  gmodule-2.0 gtk+-3.0 libasound2-dev libavahi-client-dev libjpeg9-dev libpulse-dev
