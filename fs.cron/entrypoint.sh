#!/bin/bash
set -e

gomplate --file /etc/crontab.tpl --out /tmp/crontab

exec supercronic -passthrough-logs /tmp/crontab
