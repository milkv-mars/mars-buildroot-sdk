#!/bin/sh
ISP_CTRL_NAME=/root/ISP/stf_isp_ctrl

# Default sensor
SENSOR_CFG="imx219mipi -j 0 -a 1"

USAGE="Usage:
          isp_ctrl_daemon.sh [start/stop] [imx219mipi/ov4689mipi/sc2235dvp] &"

if [ "$1" = "start" ];then
	echo "Start ${ISP_CTRL_NAME}"
elif [ "$1" = "stop" ];then
# Only kill the stf_isp_ctrl here, should be called by start-stop-daemon to kill this script.
	killall -9 stf_isp_ctrl
	exit 0
else
	echo "$USAGE"
	exit 0
fi

case "$2" in
	imx219mipi)
		SENSOR_CFG="imx219mipi -j 0 -a 1"
		echo "Select sensor imx219"
	;;
	ov4689mipi)
		SENSOR_CFG="ov4689mipi -j 0 -a 1"
		echo "Select sensor ov4689"
	;;
	sc2235dvp)
		SENSOR_CFG="sc2235dvp -i 0 -a 0"
		echo "Select sensor sc2235"
	;;
	*)
		echo "$USAGE"
		exit 0
esac

while true ; do

# Get the running stf_isp_ctrl number
NUM=`ps aux | grep ${ISP_CTRL_NAME} | grep -v grep |wc -l`

# If there are less than 1 stf_isp_ctrl, start one.
if [ "${NUM}" -lt "1" ];then
    ${ISP_CTRL_NAME} -m ${SENSOR_CFG} &

# If there are more than 1 stf_isp_ctrl, kill all of them and restart one.
elif [ "${NUM}" -gt "1" ];then
    echo "more than 1 ${ISP_CTRL_NAME},killall & restart ${ISP_CTRL_NAME}"
    killall -9 $ISP_CTRL_NAME
    ${ISP_CTRL_NAME} -m ${SENSOR_CFG} &
fi

# Kill the zombie stf_isp_ctrl
NUM_STAT=`ps aux | grep ${ISP_CTRL_NAME} | grep T | grep -v grep | wc -l`
if [ "${NUM_STAT}" -gt "0" ];then
    killall -9 ${ISP_CTRL_NAME}
    ${ISP_CTRL_NAME} -m ${SENSOR_CFG} &
fi

sleep 5;

done

# Never reach
exit 0

