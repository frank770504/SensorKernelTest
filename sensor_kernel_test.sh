adb wait-for-device
adb root
adb wait-for-device
adb remount
adb wait-for-device
echo "adb root and remount ok!!!"

adb push/cygdrive/c/Users/Frank/Documents/W2/Tool/sensors system/bin
adb shell "chmod 755 system/bin/sensors"

adb shell "ls system/bin"
