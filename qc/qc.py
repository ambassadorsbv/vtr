#!/usr/bin/env python3.7

import sys
import subprocess as sp
import json

if len(sys.argv) < 1:
    print("Missing input. Please input a file path.")
    exit(1)

inFile = sys.argv[1]


def vidlen(inFile):
    """Read the video and determine the duration."""
    ff_header = [
        '/usr/bin/env', 'ffprobe',
        '-v', 'error',
        '-hide_banner', '-i',
    ]
    ff_opts = [
        '-show_entries', 'format=duration',
        '-of', 'json',
        '-v', 'quiet',
    ]
    ff_command = []
    ff_command.extend(ff_header)
    ff_command.append(inFile)
    ff_command.extend(ff_opts)
    process = sp.run(ff_command, capture_output=True)
    data = json.loads(process.stdout)["format"]
    dur = data["duration"]
    return dur
# End reading duration.


def thumbmaker(inFile, vidlen_out):
    """Create the thumbnail output."""
    thumb_start = int(float(vidlen_out) / 10)
    thumb_interval = int(float(vidlen_out) / 3)
    ff_opts = [
        'select=not(mod(t\,',
        str(thumb_interval),
        ')),scale=320:-2,tile=3x1']
    ff_opts = "".join(ff_opts)
    ff_thumb = [
        '/usr/bin/env', 'ffmpeg', '-ss', str(thumb_start),
        '-hide_banner', '-loglevel', 'error',
        '-y', '-i', inFile,
        '-frames', '1', '-vsync', '0',
        '-vf', ff_opts,
        'thumb.png'
    ]
    sp.run(ff_thumb)


def run_all(functionInput):
    """Run all the defined functions as a single test."""
    vidlen_out = vidlen(functionInput)
    thumbmaker(functionInput, vidlen_out)


if __name__ == "__main__":

    run_all(inFile)
