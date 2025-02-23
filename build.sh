# F_CPU = 25175000UL
# mmcu  = atmega328pa

# https://forum.microchip.com/s/topic/a5C3l000000BqmjEAC/t391924

avrasm2 source/main.asm -fI
avrdude -c usbasp -v -p m328p -U flash:w:"main.hex":i -P usb
rm main.hex
