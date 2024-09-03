#!/bin/sh

SEARCH=$1

if [ "$SEARCH" = "" ]; then
	echo "Insert some device name"
	exit 1
fi

ids=$(xinput --list | awk -v search="$SEARCH" \
	'$0 ~ search {match($0, /id=[0-9]+/);\
		if (RSTART) \
			print substr($0, RSTART+3, RLENGTH-3)\
		}'\
	)
for id in $ids; do
	
	echo "[INFO] Setting props to Device=$id"
	
	echo "[INFO] Tap to click"
    	xinput set-prop $id 'libinput Tapping Enabled' 1

    	echo "[INFO] Natural scrolling"
	xinput set-prop $id 'libinput Natural Scrolling Enabled' 1
done

echo "[INFO] Done!"

exit 0
