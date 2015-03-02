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
	echo "${FUNCNAME} ----------"
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
	echo "${FUNCNAME} ----------"
	push_bin "i2c-util" "." $_PUSH_PATH
	push_bin "i2cdetect" "i2ctool" "$_PUSH_PATH"
	push_bin "i2cdump" "i2ctool" "$_PUSH_PATH"
	push_bin "i2cget" "i2ctool" "$_PUSH_PATH"
	push_bin "i2cset" "i2ctool" "$_PUSH_PATH"
}

check_sensors_on_bus()
{
#$1 is the i2c bus bunber in the platform
#make SENtral get into passthrough mode first
	echo "${FUNCNAME} ----------"
	adb shell "rmmod em718x" #TODO what if SENtral init is failled
	adb shell "insmod system/lib/modules/em718x.ko SENstr=\"passthrough\""
	echo "all the device on i2c-$1"
	adb shell "i2cdetect -y -r $1"
	#TODO do other things like get sensors data direct from i2c
	adb shell "rmmod em718x"
	adb shell "insmod system/lib/modules/em718x.ko"
}

declare -a _Strform

get_sensor_list() #TODO
{
        echo "${FUNCNAME} ----------"
        _eveList=$(adb shell "cd /dev/input; ls event*"  | tr -d '\r')
        _ind=0
        for dev in $_eveList; do
               _event="/sys/class/input/$dev"
                _inputdev="$_event/device"
                _hwdev="$_inputdev/device"
                _sensors="$_hwdev/sensors"

                _devname=$(adb shell "cat $_hwdev/name  2>/dev/null"  | tr -d '\r')
               #echo "event: $_event dev: $_devname"

                if [ "$_devname" == "em7180" ]; then
                        _sensorname=$( adb shell "cat $_inputdev/name 2>/dev/null"  | tr -d '\r')
                        _sensortype=$( adb shell "cat $_inputdev/phys 2>/dev/null"  | tr -d '\r' | awk -F':' '{     print $2; }' )

                        #echo "sensorname: $_sensorname"
                        #echo "sensortype: $_sensortype"
                        _status=$( adb shell "cat $_inputdev/sensor/enable 2>/dev/null"  | tr -d '\r')
                        echo "$_sensortype:$_sensorname           $dev           status:$_status"
                        temp=$(printf "%s %s %s %s " "$_sensortype" "$_sensorname" "$dev" "$_status")
                        _Strform=("${_Strform[@]}" "$temp")
                        #echo "${#_Strform[@]}"
                fi
        done

        echo "test"
        _end=$( printf "%d" ${#_Strform[@]} )
        _end="$[$_end-1]"
        if [ "$_Strform" != "" ]; then
                for _ind in $( eval echo {1..$_end} ); do
                        echo ${_Strform[$_ind]}
                done
        fi
}



do_sensor_cmd()
{
        case $1 in
                "en")
                adb shell "echo 1 >> \"/sys/class/input/input$2/sensor/enable\""
                ;;
                "dis")
                adb shell "echo 0 >> \"/sys/class/input/input$2/sensor/enable\""
                ;;
                "get")
                adb shell "echo 1 >> \"/sys/class/input/input$2/sensor/enable\""
                adb shell "getevent \"/dev/input/event$2\""
                ;;
                *)
                get_sensor_list
                ;;
        esac
}


#get_motion_sebsor_event() #TODO
#{

#}



device_root
echo ""
checkc_regulator
push_i2c_check_binary
check_sensors_on_bus 2
echo "device reboot"
device_root
get_sensor_list
