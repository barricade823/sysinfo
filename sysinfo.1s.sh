#!/bin/bash
#
# this is simple and usable script from a newbie
# based on some findings on the internet
# based on Ganesh V BitBar script (https://github.com/ganeshv/mtop)
# author: fadeouter (https://github.com/fadeouter/)


scale="2"				    # if you have HIDPI screen
svg_font_size="9"			# probably you won't change this
svg_font_family="Ubuntu"	# set as theme font
#symbolic="-symbolic"		# uncomment to use multicolour icons


### LIGHT THEME

chart_color="rgba(0,0,0,0.7)"		# CPU chart main color
pie_fg_color="rgba(0,0,0,0.5)"		# pie foreground color
pie_bg_color="rgba(125,125,125,0.2)"	# pie background color
text_muted="#555555"			# font color of partition mountpoint
diskbar_font="#333333"			# font color of disk used space
diskbar_font_highlighted="green"	# font color of disk free space
diskbar_bg_color=$pie_bg_color		# disk bar bg color

	
### DARK THEME

chart_color="rgba(255,255,255,0.8)"	# CPU chart main color
pie_fg_color="rgba(255,255,255,0.8)"	# pie foreground color
pie_bg_color="rgba(0,0,0,0.3)"		# pie background color	
text_muted="#ccc"			# font color of partition mountpoint
diskbar_font="white"			# font color of disk used space
diskbar_font_highlighted="#7eff35"	# font color of disk free space
diskbar_bg_color=$pie_fg_color		# disk bar bg color



### SIZES OF SVG OBJECTS

icon_h=$(expr 12 \* $scale)
graph_h=$(expr 16 \* $scale)
graph_w=$(expr 32 \* $scale)
diskbar_h=$(expr 18 \* $scale)
diskbar_w=$(expr 120 \* $scale)
px='px'


################################################################
#
#  CPU
#
################################################################

### SET XXX to number of CPU cores '{ printf("%-4s %-s\n", $9 / XXX, $NF); }'

top=$(top -o "%CPU" -bn 1 | tr -d '[]|' | sed 's\`-\ \g' | sed 's\+\…\g' | head -n 14 | tail -n 6 | awk '{ printf("%-4s %-s\n", $9 / 4, $NF); }' | awk 1 ORS="\\\n")
CPU=$(echo $top | sed 's/\\n/ /g' | awk '{ print $1 + $3 + $5 + $7 + $9 + $12}' | awk '{ printf("%.0f\n", $1"%"); }')

########### cpu graph ################

HISTORY_FILE="${HOME}/.cpu.history"
touch "${HISTORY_FILE}"
PREVIOUS=$(tail -20 "${HISTORY_FILE}")
echo "$PREVIOUS" > "${HISTORY_FILE}"
echo "$CPU" >> "${HISTORY_FILE}"

CPU_GRAPH=$(cat $HISTORY_FILE | tr "\n" "\t" | awk '{print(100-$1,"L 5,"100-$2,"10,"100-$3,"15,"100-$4,"20,"100-$5,"25,"100-$6,"30,"100-$7,"35,"100-$8,"40,"100-$9,"45,"100-$10,"50,"100-$11,"55,"100-$12,"60,"100-$13,"65,"100-$14,"70,"100-$15,"75,"100-$16,"80,"100-$17,"85,"100-$18,"90,"100-$19,"95,"100-$20)}')

cpu_icon=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='56px' height='56px' viewBox='0 0 100 100'> <g transform='translate(0,0)'> <path style='fill:$chart_color;fill-opacity:1;fill-rule:evenodd;' d='M 0,100 V $CPU_GRAPH l 0,100' /> </g></svg>" | base64 -w 0) # fill style

########### cpu graph end ############

echo "| image=$cpu_icon imageHeight=$graph_h imageWidth=$graph_w" 
echo "---"
echo "<b>$CPU%</b> CPU | image=$cpu_icon imageHeight=$icon_h font=monospace size=10"
echo "$top| font=monospace size=9 iconName=utilities-system-monitor$symbolic  bash=gnome-system-monitor terminal=false"
echo "---"


################################################################
#
#  Mem
#
################################################################

raw_mem=$(free -m | grep Mem)
raw_swap=$(free -m | grep Swap)
mem_used=$(echo $raw_mem | awk '{print $2 - $7}')
mem_D=$(echo $raw_mem | awk '{print (($2 - $7) / $2) * 10}' | awk '{ printf("%.0f\n", $1); }' | awk '{print $0"0"}')
mem_full=$(echo $raw_mem | awk '{print $2}')
swap_used=$(echo $raw_swap | awk '{print $3}')
swap_full=$(echo $raw_swap | awk '{print $2}')
swap_D=$(echo $raw_swap | awk '{print ($3 / $2) * 10 }' | awk '{ printf("%.0f\n", $1); }' | awk '{print $0"0"}')


pie_start="<svg width='$hw' height='$hw' viewBox='0 0 90.146759 90.144005'><g transform='translate(-59.928 -103.428)'><circle cx='105' cy='148.5' r='45.979' fill='$pie_bg_color'/>"
pie_00="</g></svg>"
pie_10="<path d='M105 103.52a44.98 44.98 0 0 1 26.438 8.592L105 148.5z' fill='$pie_fg_color' /></g></svg>"
pie_20="<path d='M105 103.52a44.98 44.98 0 0 1 42.777 31.08L105 148.5z' fill='$pie_fg_color' /></g></svg>"
pie_30="<path d='M105 103.52a44.98 44.98 0 0 1 36.388 18.542 44.98 44.98 0 0 1 6.39 40.337L105 148.5z' fill='$pie_fg_color' /></g></svg>"
pie_40="<path d='M105 103.52a44.98 44.98 0 0 1 44.98 44.98A44.98 44.98 0 0 1 105 193.48V148.5z' fill='$pie_fg_color' /></g></svg>"
pie_50="<path d='M105 103.52a44.98 44.98 0 0 1 44.98 44.98A44.98 44.98 0 0 1 105 193.48V148.5z' fill='$pie_fg_color' /></g></svg>"
pie_60="<path d='M105 103.52a44.98 44.98 0 0 1 42.777 31.08 44.98 44.98 0 0 1-16.34 50.288 44.98 44.98 0 0 1-52.875 0L105 148.5z' fill='$pie_fg_color' /></g></svg>"
pie_70="<path d='M105 103.52a44.98 44.98 0 0 1 44.732 40.278 44.98 44.98 0 0 1-35.38 48.698 44.98 44.98 0 0 1-52.13-30.097L105 148.5z' fill='$pie_fg_color' /></g></svg>"
pie_80="<path d='M105 103.52a44.98 44.98 0 0 1 42.777 31.08 44.98 44.98 0 0 1-16.34 50.288 44.98 44.98 0 0 1-52.875 0 44.98 44.98 0 0 1-16.34-50.287L105 148.5z' fill='$pie_fg_color' /></g></svg>"
pie_90="<path d='M105 103.52a44.98 44.98 0 0 1 44.425 37.944 44.98 44.98 0 0 1-30.526 49.813 44.98 44.98 0 0 1-53.976-22.357 44.98 44.98 0 0 1 13.638-56.808L105 148.5z' fill='$pie_fg_color' /></g></svg>"
pie_100="<circle cx='105' cy='148.5' r='44.979' fill='$pie_fg_color' /></g></svg>"

pie_sw="pie_$swap_D"
pie_sw=$(echo "${!pie_sw}")
pie_sw=$(echo "$pie_start$pie_sw" | base64 -w 0)

pie_mem="pie_$mem_D"
pie_mem=$(echo "${!pie_mem}")
pie_mem=$(echo "$pie_start$pie_mem" | base64 -w 0)

echo "Mem: ${mem_used%%.*} / ${mem_full%%.*} MiB | image=$pie_mem"
echo "Swap: ${swap_used%%.*} / ${swap_full%%.*} MiB | image=$pie_sw"

echo "---"

################################################################
#
#  Disk cap
#
################################################################

OLDIFS=$IFS
name=()
used=()
free=()
cap=()
capacity=()

get_disk_stats() {
    local IFS=$'\n'
    local i dfdata

    dfdata=($(df -H | grep "/dev/mapper*\|/dev/sd*" | grep -v "/boot\|/shm" ))

    IFS=$OLDIFS
    for ((i = 0; i < ${#dfdata[@]}; i++)); do
        line=(${dfdata[$i]})
            name+=("${line[5]}")
            cap+=("${line[1]}")
            used+=("${line[2]}")
            free+=("${line[3]}")
            capacity+=("${line[4]/\%}")
    done
}

get_disk_stats

height="10"
disk_icon="drive-harddisk-system$symbolic"

for ((i = 0; i < ${#capacity[@]}; i++)); do

if [[ ${name[$i]} = \/media* ]]; then
disk_icon="drive-removable-media$symbolic"
fi
    echo "${cap[$i]}   <span color='$text_muted' font='10'>${name[$i]}</span> | iconName=$disk_icon  imageHeight=$icon_h length=20 bash='nautilus ${name[$i]}' terminal=false"
    #echo "${used[$i]} / <span color='green'>${free[$i]}</span> (${capacity[$i]} %)| refresh=false  iconName=image-filter$symbolic"
    diskbar_green=$(echo ${capacity[$i]} | awk '{print 255 - $0 * 2.55 }' | awk '{ printf("%.0f\n", $1); }')
    diskbar_red=$(echo ${capacity[$i]} | awk '{print $0 * 2.55 }' | awk '{ printf("%.0f\n", $1); }')
    diskbar_color="rgba($diskbar_red,$diskbar_green,0,0.7)"
    diskbar=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='$diskbar_w$px' height='$diskbar_h$px' viewBox='0 0 100 11'> <rect width='100' height='2' x='0' y='$height' fill='$diskbar_bg_color' rx='1px'/> <rect width='${capacity[$i]}' height='2' x='0' y='$height' fill='$diskbar_color' rx='1px'/> <text x='0' y='7' font-size='$svg_font_size' font-family='$svg_font_family'><tspan fill='$diskbar_font'>${used[$i]} / <tspan fill='$diskbar_font_highlighted'>${free[$i]}</tspan> (${capacity[$i]} %)</tspan></text> </svg>" | base64 -w 0)
    echo "|image=$diskbar iconName=baobab$symbolic imageHeight=$diskbar_h"
    echo "---"
done


echo "Check free space | iconName=baobab$symbolic bash=baobab terminal=false"
echo "Open System Monitor | iconName=utilities-system-monitor$symbolic bash=gnome-system-monitor terminal=false"
print

