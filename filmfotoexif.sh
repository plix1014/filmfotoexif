#!/bin/bash
#
# Peter Lidauer
# 2019-03-17
#
# script sets Exif tags

# https://www.l-camera-forum.com/topic/285808-adding-exif-to-film-scans/
#
# PhotoExif csv
# Number,Date,Camera,Film type,ASA value,Speed,Aperture,Lens,Focal,Latitude,Longitude,Comment
# 1,15/03/2017 10:31,Zeiss Ikon Contina Ia,Fuji Superia 200,200,1/125s,4,Novar Anastigmat 45mm f3.5,45,0,0,test 1
# 1,27/05/2017 17:42,Canon A1,Ilford HP5 Plus,400,1/500s,11,Canon FD 28mm f2.8,28,47.80423775179646,13.04239057668619,
#
# exiftool -s -G 20170311_164920_IMG_0751.CR2 |egrep  "Serial|Model|Lens| Make|ISO| ApertureValue|ShutterSpeed|GPS"
# [EXIF]          Make                            : Canon
# [EXIF]          Model                           : Canon EOS 70D
# [EXIF]          ISO                             : 200
# [EXIF]          ShutterSpeedValue               : 1/50
# [EXIF]          ApertureValue                   : 8.0
# [EXIF]          SerialNumber                    : 033021005868
# [EXIF]          LensInfo                        : 24mm f/?
# [EXIF]          LensModel                       : EF-S24mm f/2.8 STM
# [EXIF]          LensSerialNumber                : 000010c1c2
# [EXIF]          GPSVersionID                    : 2.2.0.0
# [EXIF]          GPSLatitudeRef                  : North
# [EXIF]          GPSLongitudeRef                 : East
# [EXIF]          GPSAltitude                     : 418.6356 m
# [XMP]           Lens                            : EF-S24mm f/2.8 STM
# [Composite]     GPSLatitude                     : 48 deg 16' 40.33" N
# [Composite]     GPSLongitude                    : 16 deg 20' 44.28" E
# [Composite]     GPSPosition                     : 48 deg 16' 40.33" N, 16 deg 20' 44.28" E
# [Composite]     ShutterSpeed                    : 1/50
# [Composite]     LensID                          : Canon EF-S 24mm f/2.8 STM


# default film speed
ISO=200


# Camera type
CAM=$1

# tif/jpg 
IN_PIC=$2

EXIF_ARTIST="Peter Lidauer"

# debug flag
DEBUG=1

# ----------------------------------------------------------

usage() {
    echo
    echo "usage: ${0##*/} <csv>"
    echo
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

CSV=$1
if [ ! -r "$CSV" ]; then
    usage
fi
CAM=canon50

if [ "$CAM" = "canon50" ]; then
    # 1978
    MAKE="Canon"
    MODEL="Canon A-1"
    LENS="Canon 50mm f/1.4"
    ISO=400
    C_SER="1622035"
    L_SER="102016"
elif [ "$CAM" = "canon28" ]; then
    # 1978
    MAKE="Canon"
    MODEL="Canon A-1"
    LENS="Canon 28mm f/2.8"
    ISO=400
    C_SER="1622035"
    L_SER=
elif [ "$CAM" = "nikon" ]; then
    # 1989
    MAKE="Nikon"
    MODEL="Nikon TW20 AF"
    LENS="Nikon 35/55mm f/3.8-5.7"
    L_SER=
elif [ "$CAM" = "praktica" ]; then
    # 1978
    MAKE="Praktica"
    MODEL="Praktica LTL3"
    LENS="Carl Zeiss Jena Tessar 50mm f/2.8"
    L_SER=
elif [ "$CAM" = "yashica" ]; then
    # 1978
    MAKE="Yashica"
    MODEL="Yashica Auto Focus"
    LENS="Yashica 38mm f/2.8"
    C_SER="5022258"
    L_SER=
elif [ "$CAM" = "zeiss" ]; then
    # 1956
    MAKE="Zeiss"
    MODEL="Zeiss Ikon Contina Ia"
    LENS="Novar-Anastigmat 45mm f/3.5"
    C_SER="526/24"
    L_SER=
else
    echo
    echo "ERROR: unknown camera type"
    echo
    usage
    exit 2

fi

#if [ ! -r "$IN_PIC" ]; then
#    echo
#    echo "ERROR: cannot read $IN_PIC"
#    echo
#    exit 2
#fi

# ----------------------------------------------------------

IN_PIC=47640001.JPG

OS=$(uname -s)
# save current time of file
if [ "$OS" = "Linux" ]; then
    #SAVE_MTIME=$(stat -c "%y"  $IN_PIC | cut -c1-19 | sed -e 's,:,,g' -e 's, ,,g')
    SAVE_MTIME=$(date -d @$(stat -c"%Y" $IN_PIC) +"%Y%m%d%H%M.%S")
else
    SAVE_MTIME=$(stat -f "%Sm" -t "%Y%m%d%H%M.%S" $IN_PIC)
fi

#printf "$IN_PIC ... "
# 47640001.JPG

PREFIX=476400

egrep -v "^$|Number" $CSV | while IFS=',' read -r -a line; do
    
    NR=${line[0]}
    if [ $NR -le 9 ]; then
	NR="0$NR"
    fi

    IMG=$(ls ${PREFIX}*${NR}.JPG 2>/dev/null)
    if [ -f "$IMG" ]; then
	printf "$IMG: ${line[*]} "
	# Number,Date,Camera,Film type,ASA value,Speed,Aperture,Lens,Focal,Latitude,Longitude,Comment
	# 0      1    2      3         4         5     6        7    8     9        10        11
	DATE=${line[1]}
	MAKE=${line[2]}
	FILM_T=${line[3]}
	ISO=${line[4]}
	SPEED=${line[5]}
	APERTURE=${line[6]}
	LENS=${line[7]}
	FOCAL=${line[8]}
	GPSLAT=${line[9]}
	GPSLON=${line[10]}
	COMMD="${line[11]}"

	MOMAK=(${line[2]})
	MODEL=${MAKE}
	MAKE=${MOMAK[0]}

	LMOMAK=(${LENS})
	LMAKE=${LMOMAK[0]}
	LMODEL="${LMOMAK[1]} ${LMOMAK[2]} ${LMOMAK[3]}"

	MAXAPERTURE="${LMOMAK[${#LMOMAK[@]}-1]}"
	MAXAPERTURE=$(echo "${MAXAPERTURE}" | sed -e 's,[fF],,g')

	YY=${DATE:6:4}
	MM=${DATE:3:2}
	DD=${DATE:0:2}
	HH=${DATE:11:5}

	YYMMDDHH="${YY}-${MM}-${DD} ${HH}"
	if [ -z "$COMMD" ]; then
	    COMMD="Film: $FILM_T"
	else
	    COMMD="$COMMD, Film: $FILM_T"
	fi
	# save original make/model
	ORIG_MAKE=$(exiftool  -Make $IMG | awk -F":" '{print $2}')
	ORIG_MODEL=$(exiftool -Model $IMG | awk -F":" '{print $2}')
	ORIG_SOFTW=$(exiftool -Software $IMG | awk -F":" '{print $2}')

	COMMD="$COMMD, SCANNER: Make: $ORIG_MAKE, Model: $ORIG_MODEL, Software: $ORIG_SOFTW"
        COPYR="c${YY} $EXIF_ARTIST"

	#echo "copyright: $COPYR"
	#echo "l1       : ${LMOMAK[1]}"
	#echo "l2       : ${LMOMAK[2]}"
	#echo "l3       : ${LMOMAK[3]}"
	#echo

	#[EXIF]          ImageDescription                : PhotoExif - Camera: Canon A1, Film: Kodak Tri-X, Comment:
	#[EXIF]          Model                           : Canon A1
	#[EXIF]          Software                        : PhotoExif
	#[EXIF]          ModifyDate                      : 2017:05:27 17:35:09
	#[EXIF]          Artist                          : Peter Lidauer
	#[EXIF]          Copyright                       : Peter Lidauer
	#[EXIF]          ExposureTime                    : 1/333
	#[EXIF]          FNumber                         : 9.5
	#[EXIF]          ISO                             : 400
	#[EXIF]          ExifVersion                     : 0220
	#[EXIF]          DateTimeOriginal                : 2017:05:27 17:35:09
	#[EXIF]          CreateDate                      : 2017:05:27 17:35:09
	#[EXIF]          ShutterSpeedValue               : 1
	#[EXIF]          ApertureValue                   : 9.5
	#[EXIF]          FocalLength                     : 28.0 mm
	#[EXIF]          UserComment                     : PhotoExif - Camera: Canon A1, Film: Kodak Tri-X, Comment:
	#[EXIF]          FocalLengthIn35mmFormat         : 28 mm
	#[EXIF]          LensModel                       : Canon FD 28mm f2.8
	#[EXIF]          GPSLatitudeRef                  : North
	#[EXIF]          GPSLongitudeRef                 : East
	#[XMP]           Lens                            : Canon FD 28mm f2.8
	#[XMP]           Creator                         : Peter Lidauer
	#[XMP]           Rights                          : Peter Lidauer
	#[XMP]           Subject                         : Canon A1, Canon FD 28mm f2.8, Kodak Tri-X, PhotoExif
	#[XMP]           Description                     : PhotoExif - Camera: Canon A1, Film: Kodak Tri-X, Comment:
	#[Composite]     DateTimeCreated                 : 2017:05:27 17:35:09
	#[Composite]     GPSLatitude                     : 47 deg 48' 13.08" N
	#[Composite]     GPSLongitude                    : 13 deg 2' 34.39" E
	#[Composite]     GPSPosition                     : 47 deg 48' 13.08" N, 13 deg 2' 34.39" E
	#[Composite]     FocalLength35efl                : 28.0 mm (35 mm equivalent: 28.0 mm)

	if [ $DEBUG ]; then
	    echo
	    echo "DEBUG: exiftool "
	    echo "DEBUG: -EXIF:AllDates=\"${YYMMDDHH}\"" 
	    echo "DEBUG: -EXIF:DateTimeOriginal=\"${YYMMDDHH}\"" 
	    echo "DEBUG: -EXIF:CreateDate=\"${YYMMDDHH}\""

	    echo "DEBUG: -EXIF:Make=\"$MAKE\"" 
	    echo "DEBUG: -EXIF:Model=\"$MODEL\"" 
	    echo "DEBUG: -EXIF:Artist=\"$EXIF_ARTIST\"" 
	    echo "DEBUG: -EXIF:Copyright=\"$COPYR\"" 
	    echo "DEBUG: -EXIF:ExposureTime=\"${SPEED%?}\"" 
	    echo "DEBUG: -EXIF:FNumber=\"$APERTURE\"" 
	    echo "DEBUG: -EXIF:ISO=\"$ISO\"" 
	    echo "DEBUG: -EXIF:FocalLength=\"$FOCAL\"" 
	    echo "DEBUG: -EXIF:LensModel=\"$LMODEL\"" 
	    echo "DEBUG: -EXIF:UserComment=\"$COMMD\""
	    echo "DEBUG: -EXIF:ImageDescription=\"$COMMD\""
	    echo "DEBUG: -EXIF:ShutterSpeedValue=\"${SPEED%?}\""
	    echo "DEBUG: -EXIF:ApertureValue=\"$APERTURE\""
	    echo "DEBUG: -EXIF:FocalLengthIn35mmFormat=\"$FOCAL\"" 
	    echo "DEBUG: -XMP:GPSLatitude=\"$GPSLAT\"" 
	    echo "DEBUG: -XMP:GPSLongitude=\"$GPSLON\"" 
	    echo "DEBUG: -XMP:Lens=\"$LENS\"" 
	    echo "DEBUG: -MaxApertureValue=\"$MAXAPERTURE\"" 
	    echo "DEBUG: -LensMake=\"$LMAKE\"" 
	    echo
	fi


    # Exif
    #-EXIF:DateTimeOriginal="${YYMMDDHH}" \
    #-EXIF:CreateDate="${YYMMDDHH}" \

    # MakerNotes
    # -MaxApertureValue="$MAXAPERTURE" \

    # Composite
    #-EXIF:FocalLengthIn35mmFormat="$FOCAL" \
    #-XMP:Lens="$LENS" \

    # ???
    #-LensMake="$LMAKE" \

    exiftool \
	-EXIF:AllDates="${YYMMDDHH}" \
	-EXIF:Make="${MAKE}" \
	-EXIF:Model="${MODEL}" \
	-EXIF:Artist="${EXIF_ARTIST}" \
	-EXIF:Copyright="${COPYR}" \
	-EXIF:ExposureTime="${SPEED%?}" \
	-EXIF:FNumber="${APERTURE}" \
	-EXIF:ISO="${ISO}" \
	-EXIF:FocalLength="${FOCAL}" \
	-EXIF:LensModel="${LMODEL}" \
	-EXIF:UserComment="${COMMD}" \
	-EXIF:ImageDescription="${COMMD}" \
	-EXIF:ShutterSpeedValue="${SPEED%?}" \
	-EXIF:ApertureValue="${APERTURE}" \
	-EXIF:FocalLengthIn35mmFormat="${FOCAL}" \
	-XMP:GPSLatitude="${GPSLAT}" \
	-XMP:GPSLongitude="${GPSLON}" \
	-XMP:Lens="${LENS}" \
	-MaxApertureValue="${MAXAPERTURE}" \
	-LensMake="${LMAKE}" \
	${IN_PIC} 1>/dev/null

    if [ $? -eq 0 ]; then
	echo "ok"
	touch -t $SAVE_MTIME $IN_PIC
	if [ -f "${IN_PIC}_original" ]; then
	    rm ${IN_PIC}_original
	fi
    else
	echo "failed"
	echo "ERROR: $IN_PIC not updated"
    fi

    else
	echo "ERROR: could not find ${PREFIX}*${NR}.JPG for line: ${line[*]}"
    fi
done

