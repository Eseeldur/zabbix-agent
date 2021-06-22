DISK=$1

case "$2" in
"rrqm/s")
        NUMBER=2
;;
"wrqm/s")
        NUMBER=3
;;
"r/s")
        NUMBER=4
;;
"w/s")
        NUMBER=5
;;
"rmB/s")
        NUMBER=6
;;
"wmB/s")
        NUMBER=7
;;
"avgrq-sz")
        NUMBER=8
;;
"avgqu-sz")
        NUMBER=9
;;
"await")
        NUMBER=10
;;
"svctm")
        NUMBER=11
;;
"%util")
        NUMBER=12
;;
esac

A=$(iostat -xdm 1 2 | awk 'BEGIN {check=0;} {if(check==2 && $1!=""){print $0}if($1=="Device:"){check=check+1}}'| tr '\n' '|' | tr ',' '.')
echo $A| sed 's/|/\n/g' | grep $DISK | cut -f$NUMBER -d' '

