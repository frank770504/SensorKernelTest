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
	echo "$0 ----------"
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

_PUSH_PATH="system/bin"

#push binary
push_bin()
{
#$1 the binary name
#$2 binary path
#$3 the push path

        adb push $2/$1 $3
        adb shell "chmod 755 $3/$1"
}


push_i2c_check_binary()
{
	echo "$0 ----------"
	push_bin "i2c-util" "." $_PUSH_PATH
	push_bin "i2cdetect" "i2ctool" "$_PUSH_PATH"
	push_bin "i2cdump" "i2ctool" "$_PUSH_PATH"
	push_bin "i2cget" "i2ctool" "$_PUSH_PATH"
	push_bin "i2cset" "i2ctool" "$_PUSH_PATH"
}

check_sensors_on_bus()
{
	echo "$0 ----------"
#$1 is the i2c bus bunber in the platform
#make SENtral get into passthrough mode first
	adb shell "rmmod em718x" #TODO what if SENtral init is failled
	adb shell "insmod system/lib/modules/em718x.ko SENstr=\"passthrough\""
	echo "all the device on i2c-$1"
	adb shell "i2cdetect -y -r $1"
	#TODO do other things like get sensors data direct from i2c
	adb shell "rmmod em718x"
	adb shell "insmod system/lib/modules/em718x.ko"
}


device_root
echo ""
checkc_regulator
push_i2c_check_binary
check_sensors_on_bus 2
