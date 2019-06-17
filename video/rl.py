#!/usr/bin/env python3
"""Script to combine audio and video files of the same length.

Checks input files for length up to 6 decimals using ffprobe,
then combines those two input files to a video,
and transcodes to x264 if necessary
"""

import subprocess as sp
import sys
import os
import datetime

if len(sys.argv) < 3:
    print("missing input")
    exit(1)

vin = sys.argv[1]
ain = sys.argv[2]
outformat = sys.argv[3]
outfolder = sys.argv[4]

basev = os.path.basename(vin)
now = datetime.datetime.now().strftime('%Y%m%d-%H%M')

probe_header = [
    '/usr/bin/env', 'ffprobe',
    '-v', 'error',
    '-hide_banner',
]
probe_arguments = [
    '-show_entries', 'format=duration',
    '-of', 'default=noprint_wrappers=1:nokey=1',
]

# Setting the bitrate and output format
# for selected version of video
if outformat == 'mov' or outformat == 'master' or outformat == 'apr422':
    outformat = 'mov'
    outext = 'mov'
    minrate = ''
    maxrate = ''
else:
    if outformat == 'mp4' or outformat == 'ref':
        outformat = '10000'
    outext = 'mp4'
    minrate = str((int(outformat)-2000))
    maxrate = str((int(outformat)+2000))

outname = os.path.join(
    outfolder,
    "{}_{}.{}".format(
        os.path.splitext(basev)[0],
        now,
        outext
    )
)
outlog = os.path.join(
    outfolder,
    "{}_{}.{}".format(
        os.path.splitext(basev)[0],
        now,
        'log'
    )
)

ff_header = [
    '/usr/bin/env', 'ffmpeg',
    '-hide_banner',
    '-loglevel', 'warning',
    '-stats',
    '-y',
    '-an', '-i', vin,
    '-i', ain,
    '-map', '0:v', '-map', '1:a'
]


ff_master = [
    '-c', 'copy',
    '-ac', '2',
    '-f', 'mov',
]

ff_422 = [
    '-c:v', 'prores_ks',
    '-profile:v', '5',
    '-ac', '2',
    '-c:a', 'copy',
    '-f', 'mov',
]

ff_color = [
    '-vendor', 'ap10',
    '-color_primaries', '1',
    '-color_trc', '1',
    '-colorspace', '1',
    outname
]

ff_ref = [
    '-c:v', 'libx264',
    '-b:v', outformat + 'k',
    '-minrate', minrate + 'k',
    '-maxrate', maxrate + 'k',
    '-bufsize', maxrate + 'k',
    '-pix_fmt', 'yuv420p',
    '-profile:v', 'high',
    '-level', '41',
    '-vf', 'scale=trunc(iw/2)*2:trunc(ih/2)*2',
    '-c:a', 'aac',
    '-b:a', '320k',
    '-f', 'mp4',
    outname
]

if __name__ == "__main__":

    vprobe = []
    vprobe.extend(probe_header)
    vprobe.extend(['-i', vin])
    vprobe.extend(probe_arguments)
    vout = sp.check_output(
        vprobe
    )
    vint = vout.decode().strip()

    aprobe = []
    aprobe.extend(probe_header)
    aprobe.extend(['-i', ain])
    aprobe.extend(probe_arguments)
    aout = sp.check_output(
        aprobe
    )
    aint = aout.decode().strip()

    ff_command = []
    ff_command.extend(ff_header)

    if outformat == "mov":
        ff_command.extend(ff_master)
        ff_command.extend(ff_color)
    elif outformat == "apr422":
        ff_command.extend(ff_422)
        ff_command.extend(ff_color)
    else:
        ff_command.extend(ff_ref)

    # test prints
    # print('audioint', {"audioint": aint})
    # print('vidint', vint)
    # print(" ".join(ff_command))

    if vint == aint:

        if not os.path.isdir(outfolder):
                os.makedirs(outfolder)
        logfile = open(outlog, 'w')
        if outformat == "mov" or outformat == "master":
            print("Creating Master file")
            sp.run(ff_command)
        elif outformat != "mov" or outformat != "master":
            print("Creating reference file")
            sp.run(ff_command)
        logfile.write(" ".join(ff_command))
        print("Done! Created file at ", outname)
    else:
        print("Error creating " + outname)
        print("Length of video and audio files do not match!")
        print("Length of video file is " + str(vint) + " seconds")
        print("Length of audio file is " + str(aint) + " seconds")
        ctn_choice = input("Continue? y/n     ")
        if ctn_choice == "y" or ctn_choice == "yes":
            if not os.path.isdir(outfolder):
                    os.makedirs(outfolder)
            logfile = open(outlog, 'w')
            if outformat == "mov" or outformat == "master":
                print("Creating Master file")
                sp.run(ff_command)
            elif outformat != "mov" or outformat != "master":
                print("Creating reference file")
                sp.run(ff_command)
            logfile.write(" ".join(ff_command))
            print("Done! Created file at ", outname)
        elif ctn_choice == "n" or ctn_choice == "no" or ctn_choice == "":
            print("Exiting")
            exit(1)
