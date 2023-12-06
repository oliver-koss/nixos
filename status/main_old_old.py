#!/usr/bin/env python3

import subprocess
import time
from time import sleep
from lcd_i2c import LCD_I2C

def lc_display(text):
    lcd.write_text(text)

def status(service):
    try:
      return str(subprocess.check_output(['systemctl', 'is-active', service]).strip(), "utf-8")
    except:
      return str("dead")
#def info(service):
#    return '%s: %s' % (service, status(service))

lcd = LCD_I2C(39, 16, 2)

lcd.backlight.on()
#lcd.blink.on()

service = "pat"

while True:
    lcd.cursor.setPos(0, 0)
    lcd.write_text(service)

    lcd.cursor.setPos(2, 0)
    lcd.write_text(status('pat'))

    lcd.cursor.setPos(2, 8)
    lcd.write_text(time.strftime("%H:%M:%S"))
    sleep(1)

