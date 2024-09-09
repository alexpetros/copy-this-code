# A collection of ffmpeg stuff with explanations of the relevant controls

# Make a gif
# -pix_fmt rbg8       sets the color mode to rgb8
# -r 10               set the framerate to 10fps
# -ss 00:00:00        start the transcoding at the beginning
# -t 00:00:10         end the transcoding at 10 seconds in
# output.gif          output the file as a GIF to output.gif
ffmpeg -i input.mov -pix_fmt rgb8 -r 10 -ss 00:00:00 -t 00:00:10 output.gif
