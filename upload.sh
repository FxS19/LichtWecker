if ! [ -z "$1" ]
then
	echo "die Datei - $1"
	./luac -o out/$1 $1 && ./wcc -p /dev/ttyUSB0 -up out/$1 $1 && stty -F /dev/ttyUSB0 sane && stty -F /dev/ttyUSB0 115200 -echo && stty -F /dev/ttyUSB0 && echo "os.exit()"$'\n' > /dev/ttyUSB0 && cutecom /dev/ttyUSB0 115200
else
	for f in *.lua
	do
		echo "die Datei - $f --Kein debug"
		#-s
		./luac -o out/$f $f && ./wcc -p /dev/ttyUSB0 -up out/$f $f
	done
	stty -F /dev/ttyUSB0 sane
	stty -F /dev/ttyUSB0 115200 -echo
	stty -F /dev/ttyUSB0
	echo "os.exit()"$'\n' > /dev/ttyUSB0
	cutecom /dev/ttyUSB0 115200
fi
