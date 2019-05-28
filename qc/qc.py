#!/usr/bin/env python3.7

import sys
import subprocess as sp
import json
import os

if len(sys.argv) < 1:
    print("Missing input. Please input a file path.")
    exit(1)

inFile = sys.argv[1]
inFileName = os.path.basename(inFile)


def probe_infile(inFile):
    """Probe the input file to get the relevant meta data."""
    ff_header = [
        '/usr/bin/env', 'ffprobe',
        '-v', 'error',
        '-hide_banner', '-i',
    ]
    ff_opts = [
        '-show_format', '-show_streams',
        '-of', 'json',
        '-v', 'quiet',
    ]
    ff_command = []
    ff_command.extend(ff_header)
    ff_command.append(inFile)
    ff_command.extend(ff_opts)
    process = sp.run(ff_command, capture_output=True)
    probe_data = json.loads(process.stdout)
    return probe_data
# End probing the input video.


def vidlen(probe_data):
    """Read the json log and determine the duration."""
    formats = probe_data["format"]
    dur = formats.get("duration")
    return dur
# End reading duration.


def fileinfo(probe_data):
    """Read the json log and output file information."""
    for stream in probe_data["streams"]:
        vidcheck = stream.get("codec_type")
        if vidcheck == "video":
            width = stream.get("width")
            height = stream.get("height")
            ratio = stream.get("display_aspect_ratio")
            order = stream.get("field_order")
            fps = stream.get("r_frame_rate")
            codec = stream.get("codec_name")
            codec_long = stream.get("codec_long_name")
    fileinfo_out = [width, height, ratio, order, fps, codec, codec_long]
    return fileinfo_out
# End fileinfo.


def thumbmaker(inFile, inFile_dur):
    """Create the thumbnail output."""
    thumb_ss = int(float(inFile_dur) * 0.1)
    thumb_tc = int(float(inFile_dur) * 0.5 - thumb_ss)
    ff_opts = "select=not(mod(t\\,{timebase})),scale=150:-2,tile=3x1".format(
        timebase=thumb_tc
        )
    outFileName = os.path.join(
                  "./output/",
                  "{}_thumb.png".format(os.path.splitext(inFileName)[0])
    )
    ff_thumb = [
        '/usr/bin/env', 'ffmpeg', '-ss', str(thumb_ss),
        '-hide_banner', '-loglevel', 'error',
        '-y', '-i', inFile,
        '-frames', '1', '-vsync', '0',
        '-vf', ff_opts,
        outFileName
    ]
    sp.run(ff_thumb)
# End thumbmaker.


def run_all(functionInput):
    """Run all the defined functions as a single test."""
    probe_data = probe_infile(functionInput)
    fileinfo(probe_data)
    inFile_dur = vidlen(probe_data)
    thumbmaker(functionInput, inFile_dur)
# End run all.


if __name__ == "__main__":

    run_all(inFile)
