#!/usr/bin/env python3
"""Script to combine audio and video files of the same length.

Checks input files for length up to 6 decimals using ffprobe,
then combines those two input files to a video,
and transcodes to x264 if necessary.
Loops through folders to find all matching audio files to any given
video file, checking only by duration of the two input files.
"""

import subprocess as sp
import sys
import os
import datetime
import utils

if len(sys.argv) < 3:
    print("missing input")
    exit(1)

vinFolder = sys.argv[1]
ainFolder = sys.argv[2]
outformat = sys.argv[3]
outfolder = sys.argv[4]

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

if outformat == "master":
    outformat = "mov"

if outformat == "mov":
    outext = ".mov"
else:
    outformat = "8000"
    outext = ".mp4"

ff_header = [
    '/usr/bin/env', 'ffmpeg', '-hide_banner',
    '-loglevel', 'warning',
    '-stats',
    '-y',
]

ff_master = [
    '-map', '0:0', '-map', '1:0',
    '-c:v', 'copy',
    '-c:a', 'copy',
    '-f', 'mov',
]

ff_ref = [
    '-map', '0:0', '-map', '1:0',
    '-c:v', 'libx264',
    '-c:a', 'aac',
    '-b:v', outformat + 'k',
    '-b:a', '160k',
    '-pix_fmt', 'yuv420p',
    '-profile:v', 'high',
    '-level', '41',
    '-vf', 'scale=trunc(iw/2)*2:trunc(ih/2)*2',
    '-f', 'mp4',
]


def filterAudioFilesFromFilelist(filelist):
    """Search for audio file.

    Searches for audio files in filelist,
    returns list of files that end in a known audio extention
    """
    audioFileList = []
    for audioFilter in filelist:
        audioRoot, audioExt = os.path.splitext(audioFilter)
        if audioExt in ['.wav', '.aiff', '.aif']:
            audioFileList.append(audioFilter)
    # end for loop
    return audioFileList
# end getAudioFileFromFilelist


def getAudioFileFromFilelist(audiofiltered):
    """Search for audio file.

    Searches for audio files in filelist,
    returns filename if it ends in a known audio extention
    """
    for audioFile in audiofiltered:
        audioRoot, audioExt = os.path.splitext(audioFile)
        if audioExt in ['.wav', '.aiff', '.aif']:
            return audioFile
# end getAudioFileFromFilelist


def getVideoFilesFromFileList(filelist):
    """Search for video file.

    Searches for video files in filelist,
    returns filename if it ends in a known video extention
    """
    videoFileList = []
    for videoFile in filenames:
        videoRoot, videoExt = os.path.splitext(videoFile)
        if videoExt in ['.mov', '.mp4', '.mkv', '.avi']:
            videoFileList.append(videoFile)
    return videoFileList
# end getVideoFilesFromFileList


def getAudioLengthFromAudioFile(audiofileforlengthcheck):
    """Probe audio file for duration.

    Checks audio file duration using ffprobe
    returns duration up to 6 decimals.
    """
    aprobe = []
    aprobe.extend(probe_header)
    aprobe.extend(['-i', audiofileforlengthcheck])
    aprobe.extend(probe_arguments)
    aout = sp.check_output(
        aprobe
    )
    aint = aout.decode().strip()
    return aint
# end getAudioLengthFromAudioFile


def getVideoLengthFromVideoFile(videofileforlengthcheck):
    """Probe video file for duration.

    Checks video file duration using ffprobe
    returns duration up to 6 decimals.
    """
    vprobe = []
    vprobe.extend(probe_header)
    vprobe.extend(['-i', videofileforlengthcheck])
    vprobe.extend(probe_arguments)
    vout = sp.check_output(
        vprobe
    )
    vint = vout.decode().strip()
    return vint
# end getVideoLengthFromVideoFile


def outputNamingBase(video, audio):
    """Define an output naming basis.

    Defines the format for output filenames.
    This base is the same for both the video file,
    and the logfile that accompanies it.
    """
    outbase = os.path.join(
        outfolder,
        "{}_{}_{}_{}_{}".format(
            os.path.splitext(basev)[0],
            '___',
            os.path.splitext(basea)[0],
            '___',
            now,
        ))
    return outbase
# end outputNamingBase


def makeOutputFile():
    """Start building the output file settings."""
    ff_command = []
    ff_command.extend(ff_header)
    ff_command.extend(['-i', vin, '-i', ain])

    # Extend the ffmpeg command with the proper export settings
    if outformat == "mov":
        ff_command.extend(ff_master)
    else:
        ff_command.extend(ff_ref)
    ff_command.append(outname)

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
    # end makeOutputFile


if __name__ == "__main__":

    # Create lists for video and audio files, and their duration
    videoList = []
    audioList = []

    # Fill up the video and audio lists with filepath and duration of file
    for dirpath, dirnames, filenames in os.walk(vinFolder):
        # videoFileName = getVideoFilesFromFileList(filenames)
        filteredVideoFileList = utils.filterHiddenFiles(filenames)
        videoFileList = getVideoFilesFromFileList(filteredVideoFileList)
        if videoFileList:
            for videoFileName in videoFileList:
                fullVideoFilePath = os.path.join(dirpath, videoFileName)
                videoFileDur = getVideoLengthFromVideoFile(
                            videofileforlengthcheck=fullVideoFilePath
                            )
                videoList.append(
                    {'filepath': fullVideoFilePath,
                     'duration': videoFileDur}
                    )

    for dirpath, dirnames, filenames in os.walk(ainFolder):
        filteredAudioFileList = utils.filterHiddenFiles(filenames)
        audioFileList = filterAudioFilesFromFilelist(filteredAudioFileList)
        for audioFileName in audioFileList:
            if audioFileName is not None:
                fullAudioFilePath = os.path.join(dirpath, audioFileName)
                audioFileDur = getAudioLengthFromAudioFile(
                            audiofileforlengthcheck=fullAudioFilePath
                            )
                audioList.append(
                    {'filepath': fullAudioFilePath,
                     'duration': audioFileDur}
                    )

    # Check audio and video durations from the lists we created
    # in the previous walk loops. If the audio duration matches
    # the video duration, build an export command
    for v in videoList:
        for a in audioList:
            vin = v.get('filepath')
            ain = a.get('filepath')
            # define the name for the output files
            basev = os.path.basename(vin)
            basea = os.path.basename(ain)
            outname = outputNamingBase(vin, ain) + outext
            outlog = outputNamingBase(vin, ain) + '.log'

            if v.get('duration') == a.get('duration'):
                makeOutputFile()

            elif v.get('duration') != a.get('duration'):
                print("Length of video and audio files do not match!")
                print("Length of video file " + str(vin) + " is "
                      + str(v.get('duration')) + " seconds")
                print("Length of audio file " + str(ain) + " is "
                      + str(a.get('duration')) + " seconds")
#                ctn_choice = input("Continue? y/n    ")
#                if ctn_choice in ["y", "yes"]:
#                    makeOutputFile()
#                else:
#                    print("Skipping.")
                # ctn = input("Continue? y/n: ")
                # if ctn == "y" or ctn == "yes":
                #     makeOutputFile()
                # elif ctn == "n" or ctn == "no":
                #     print("Exiting")
                #     exit(1)
                # # Create the output directory and
                # execute the ffmpeg command
