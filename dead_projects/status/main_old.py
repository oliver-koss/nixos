#!/usr/bin/env python3

import subprocess
from time import sleep
from lcd_i2c import LCD_I2C

def lc_display(text):
    lcd.write_text(text)

def status(service):
    return str(subprocess.check_output(['systemctl', 'is-active', service]).strip(), "utf-8")

def info(service):
    return '%s: %s' % (service, status(service))

lcd = LCD_I2C(39, 16, 2)

lcd.backlight.on()
lcd.blink.on()

while True:
    lc_display(info('yggdrasil'))
    sleep(1000)
