#!/bin/bash

# Bash Bad Badge Generator
# Based on Badge Generator 2018 by https://github.com/ibrah
# Usage: ./badgen.sh data.csv badge_template.png +700-1650 800x800 0,-650 didactgothic-regular.ttf

# Define file paths and parameters
CSV_FILENAME="data.csv"
BADGE_TEMPLATE_FILENAME="badge_template.png"
QRCODE_OFFSET_X_Y=(-300+670) # FORMAT: +XXX-YYY
QRCODE_SIZE="250x250"         # FORMAT: 800x800
TEXT1_OFFSET_X_Y=(+00-100)
TEXT1_FONT_FILENAME="fonts/StagSans-Medium.otf"
TEXT2_OFFSET_X_Y=(+00+50)
TEXT2_FONT_FILENAME="fonts/StagSans-Medium.otf"
TEXT3_OFFSET_X_Y=(+00+200)
TEXT3_FONT_FILENAME="fonts/StagSans-Light.otf"
TEXT4_OFFSET_X_Y=(+00+350)
TEXT4_FONT_FILENAME="fonts/StagSans-Light.otf"
TEXT_SIZE=130
TEXT_COLOR="black"

# Counter initialization
counter=1

# Read CSV file line by line
while IFS=";" read f1 f2 f3 f4 f5 f6 f7 f8; do
    # Check if it's not the header row
    if [ $counter != 1 ]; then
        # Retrieve QRCODE
        url="https://api.qrserver.com/v1/create-qr-code/?size=255x255&data=BEGIN%3AVCARD%0AN%3A${f7}%20${f8}%0ATEL%3A${f5}%0AEMAIL%3A${f6}%0AEND%3AVCARD"
        wget -O out/temp_qrcode.png "$url"

        # Insert QRCODE in badge frame with ImageMagick
        convert -resize "$QRCODE_SIZE" out/temp_qrcode.png out/temp_qrcode.png
        composite -gravity center -quality 100 -geometry "${QRCODE_OFFSET_X_Y[@]}" out/temp_qrcode.png "$BADGE_TEMPLATE_FILENAME" out/result.png

        # Insert participant details
        convert -font "$TEXT1_FONT_FILENAME" -fill "$TEXT_COLOR" -pointsize "$TEXT_SIZE" -gravity center -quality 100 -draw "text ${TEXT1_OFFSET_X_Y[@]} '${f1}'" out/result.png out/result_withtext1_${counter}.png
        convert -font "$TEXT2_FONT_FILENAME" -fill "$TEXT_COLOR" -pointsize "$TEXT_SIZE" -gravity center -quality 100 -draw "text ${TEXT2_OFFSET_X_Y[@]} '${f2}'" out/result_withtext1_${counter}.png out/result_withtext2_${counter}.png
        convert -font "$TEXT3_FONT_FILENAME" -fill "$TEXT_COLOR" -pointsize "$TEXT_SIZE" -gravity center -quality 100 -draw "text ${TEXT3_OFFSET_X_Y[@]} '${f3}'" out/result_withtext2_${counter}.png out/result_withtext3_${counter}.png
        convert -font "$TEXT4_FONT_FILENAME" -fill "$TEXT_COLOR" -pointsize "$TEXT_SIZE" -gravity center -quality 100 -draw "text ${TEXT4_OFFSET_X_Y[@]} '${f4}'" out/result_withtext3_${counter}.png out/result_withtext4_${counter}.png

        # Convert to PDF for printing
        convert out/result_withtext4_${counter}.png -quality 100 out/result_withtext4_${counter}.pdf

        # Clean up temporary files
        rm -r out/result.png
        rm -r out/temp_qrcode.png
        rm -r out/result_withtext1_${counter}.png
        rm -r out/result_withtext2_${counter}.png
        rm -r out/result_withtext3_${counter}.png
    fi
    # Increment counter
    ((counter++))
done < "$CSV_FILENAME"
