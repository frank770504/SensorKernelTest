#adb root and remount the device
device_root()
{
        adb wait-for-device
        adb root
        adb wait-for-device
        adb remount
        adb wait-for-device
        echo "adb root and remount ok!!!"
}

_regulator="8226_l19 \
            8226_lvs1"

checkc_regulator()
{
	for _reg in $_regulator
	do
		echo "check regulator: $_reg"
		_enable=$( adb shell "cat d/regulator/$_reg/enable" | tr -d '\r')
		if [ $_enable == "1" ]; then
			echo "$_reg is endble"
		else
			echo "$_reg is disdble"
		fi
	done
}

PUSH_PATH="system/bin"
BIN_NAME=$1

#push binary
push_bin()
{
#$1 the binary name
#$2 the push path

        adb push ./$1 $2
        adb shell "chmod 755 $2/$1"
}


check_sensors_addr_on_bus()
{

}

device_root
echo "\n"
checkc_regulator

