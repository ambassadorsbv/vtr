#!/usr/bin/env python3.7

import sys
import subprocess as sp
import json
import os
import PIL

from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import cm
from reportlab.lib.colors import HexColor

from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
pdfmetrics.registerFont(TTFont('GothamBold', 'Gotham-Bold.ttf'))
pdfmetrics.registerFont(TTFont('GothamBook', 'Gotham-Book.ttf'))
pdfmetrics.registerFont(TTFont('GothamMed', 'Gotham-Medium.ttf'))

import reportlab.platypus
import PIL


if len(sys.argv) < 1:
    print("Missing input. Please input a file path.")
    exit(1)

inFile = sys.argv[1]
inFileDir = os.path.dirname(inFile)
inFileName = os.path.splitext(os.path.basename(inFile))[0]

outThumb = os.path.join(
              "{inDir}/{inFileName}_thumb.png".format(inDir=inFileDir,inFileName=inFileName)
)

outLog = os.path.join(
              "{inDir}/{inFileName}.log".format(inDir=inFileDir,inFileName=inFileName)
)

outPDF = os.path.join(
              "{inDir}/{inFileName}.pdf".format(inDir=inFileDir,inFileName=inFileName)
)


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
    print("Probing input file...")
    process = sp.run(ff_command, capture_output=True)
    probe_data = json.loads(process.stdout)
    print("Probe complete.")
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
    fileSize = (os.path.getsize(inFile) / 1048576)
    fileSize = "{0:.2f}".format(fileSize)
    for stream in probe_data["streams"]:
        streamcheck = stream.get("codec_type")
        if streamcheck == "video":
            width = stream.get("width")
            height = stream.get("height")
            ratio = stream.get("display_aspect_ratio")
            order = stream.get("field_order")
            fps = stream.get("r_frame_rate")
            vcodec = stream.get("codec_name")
            vcodec_long = stream.get("codec_long_name")
            date = stream.get("tags")["creation_time"]
        if streamcheck == "audio":
            achannels = stream.get("channels")
            acodec = stream.get("codec_name")
            acodec_long = stream.get("codec_long_name")
            samplerate = stream.get("sample_rate")
    fileinfo_out = {"FileSize" : fileSize,
                    "Width" : width, 
                    "Height" : height, 
                    "Ratio" : ratio, 
                    "Order" : order, 
                    "FPS" : fps, 
                    "VideoCodec" : vcodec,
                    "VideoCodecLong" : vcodec_long,
                    "AudioCodec" : acodec,
                    "AudioCodecLong" : acodec_long,
                    "AudioChannels" : achannels,
                    "SampleRate" : samplerate,
                    "Date" : date}
    return fileinfo_out
# End fileinfo.


def loudness(inFile, probe_data):
    """Probe the input file and read the audio stream loudness."""
    for stream in probe_data["streams"]:
        if stream.get("codec_type") == "audio":
            ff_opts = "amovie='{inFile}',ebur128=metadata=1".format(inFile=inFile)
            ff_command = ["/usr/bin/env", "ffprobe",
                          "-f", "lavfi", ff_opts,
                          "-show_frames", "-of", "json", "-v", "quiet"
            ]
            print("Reading input file loudness...")
            process = sp.run(ff_command, capture_output=True)
            r128_data = json.loads(process.stdout)
            for frame in r128_data['frames']:
                tags = frame["tags"]
                if tags:
                    loudness = tags.get("lavfi.r128.I")
            print("Loudness check complete.")
    R128check = "No"
    if -23.5 < float(loudness) < -22.5:
        R128check = "Yes"
    return loudness, R128check
# End loudness.


def thumbmaker(inFile, inFile_dur):
    """Create the thumbnail output."""
    thumb_ss = int(float(inFile_dur) * 0.1)
    thumb_tc = int(float(inFile_dur) * 0.5 - thumb_ss)
    ff_opts = "select=not(mod(t\\,{timebase})),scale=300:-2,tile=3x1".format(
        timebase=thumb_tc
        )
    ff_thumb = [
        '/usr/bin/env', 'ffmpeg', '-ss', str(thumb_ss),
        '-hide_banner', '-loglevel', 'error',
        '-y', '-i', inFile,
        '-frames', '1', '-vsync', '0',
        '-vf', ff_opts,
        outThumb
    ]
    print("Creating thumbnail file...")
    sp.run(ff_thumb)
    print("Thumbnail created.")
    ff_thumbProbe = [ 
        '/usr/bin/env', 'ffprobe', outThumb,
        '-show_streams', '-of', 'json', '-v', 'quiet'
    ]
    process = sp.run(ff_thumbProbe, capture_output=True)
    thumbProbe_data = json.loads(process.stdout)
    for stream in thumbProbe_data["streams"]:
        thumbWidth = stream.get("width")
        thumbHeight = stream.get("height")
    return thumbWidth, thumbHeight
# End thumbmaker.


def pdfmaker(probe_data, loudness):
    """Create a pdf report from our test data."""
    ## Set canvas parameters.
    x = 30
    y = 800
    c = canvas.Canvas(outPDF, pagesize=A4, bottomup=1, pageCompression=0)
    cWidth, cHeight = A4
    c.setAuthor("Ambassadors VFX")
    c.setTitle(inFileName)

#    def centeredString(string, font, size):
#        width = pdfmetrics.stringWidth(string, font, size)
#        width += (len(string) - 1)
#        centeredString = ((cWidth/2)- (width/2))
#        return centeredString
    ## End canvas parameters.

    ## Set File Info
    fileSize = str(fileinfo["FileSize"])
    fileWidth = str(fileinfo["Width"])
    fileHeight = str(fileinfo["Height"])
    fileRatio = str(fileinfo["Ratio"])
    fileOrder = str(fileinfo["Order"])
    fileFPS = str(fileinfo["FPS"])
    fileVCodec = str(fileinfo["VideoCodec"])
    fileVCodecLong = str(fileinfo["VideoCodecLong"])
    fileACodec = str(fileinfo["AudioCodec"])
    fileACodecLong = str(fileinfo["AudioCodecLong"])
    fileAChannels = str(fileinfo["AudioChannels"])
    fileSampleRate = str(fileinfo["SampleRate"])
    fileLoudness = str(loudness[0])
    fileR128 = str(loudness[1])
    fileDate = str(fileinfo["Date"][:10])

    
    ## Draw a colored box to set background color.
    c.setFillColor(HexColor("#e7e5dd"))
    c.rect(-1*cm,-5,25*cm,30*cm, fill=1)
    ## End background color.
    ## Reset the color to Ambassadors Green for writing text.
    c.setFillColor(HexColor("#3e3905"))

    ## Import the logo image. 
    c.drawImage("/AMSHARED/AMBASSADORS/ARTWORK/AMBASSADORS_BRANDING_2016/LOGO_DARK_GREEN/Ambassadors_LogoName_Banner_DRK_RGB_1224px.png",
                30, cHeight-100,
                width=cWidth/2,
                height=(cWidth/2)/4,
                mask='auto'
    )
    ## End logo image.
    ## Print the file info.
    y_fileDetails = y-130

    c.setFont("GothamBold", 22)
    c.drawString(x, y_fileDetails, "File Technical Report:")

    c.setFont("GothamMed", 10)
    c.drawString(x+10, y_fileDetails-20, "File Name:")
    c.drawString(x+130, y_fileDetails-20, "{val}".format(
                 val=inFileName[:-6]))
    c.drawString(x+10, y_fileDetails-33, "Master Number:")
    c.drawString(x+130, y_fileDetails-33, "{val}".format(
                val=inFileName[-5:]))
    c.drawString(x+10, y_fileDetails-46, "Date Created:")
    c.drawString(x+130, y_fileDetails-46, "{val}".format(
                 val=fileDate))
    c.drawString(x+10, y_fileDetails-59, "File Size:")
    c.drawString(x+130, y_fileDetails-59, "{val} MB".format(
                 val=fileSize))
    ## End file info.
    ## Show the thumbnail image.
    thumbWidth = thumbSizes[0]
    thumbHeight = thumbSizes[1]
    y_thumb = y_fileDetails-180
    c.drawImage(outThumb, 
                30, y_thumb, 
                width=thumbWidth / 2,
                height=thumbHeight / 2,
                mask='auto'
    )
#    if os.path.isfile(outThumb):
#        os.remove(outThumb)
    ## End thumbnail image.

    ## Print the technical video details. 
    y_vidDetails = y_thumb-50

    c.setFont("GothamBold", 22)
    c.drawString(x, y_vidDetails, "Video specifications")    

    c.setFont("GothamMed", 10)
    c.drawString(x+10, y_vidDetails-20, "Resolution:") 
    c.drawString(x+130, y_vidDetails-20, "{width}x{height}".format(
                 width=fileWidth,
                 height=fileHeight))
    c.drawString(x+10, y_vidDetails-33, "Aspect Ratio:")
    c.drawString(x+130, y_vidDetails-33, "{val}".format(
                 val=fileRatio))
    c.drawString(x+10, y_vidDetails-46, "Framerate:")
    c.drawString(x+130, y_vidDetails-46, "{val}".format(
                 val=fileFPS))
    c.drawString(x+10, y_vidDetails-59, "Video Codec:")
    c.drawString(x+130, y_vidDetails-59, "{val}".format(
                 val=fileVCodec))
    c.drawString(x+10, y_vidDetails-72, "Field Order:")
    c.drawString(x+130, y_vidDetails-72, "{val}".format(
                 val=fileOrder))
    ## End video details.

    ## Print the technical video details. 
    y_audDetails = y_vidDetails-120

    c.setFont("GothamBold", 22)
    c.drawString(x, y_audDetails, "Audio specifications")    

    c.setFont("GothamMed", 10)
    c.drawString(x+10, y_audDetails-20, "Audio Channels:") 
    c.drawString(x+130, y_audDetails-20, "{val}".format(
                 val=fileAChannels))
    c.drawString(x+10, y_audDetails-33, "Audio Codec:")
    c.drawString(x+130, y_audDetails-33, "{val}".format(
                 val=fileACodecLong))
    c.drawString(x+10, y_audDetails-46, "Sample Rate:")
    c.drawString(x+130, y_audDetails-46, "{val} kHz".format(
                 val=fileSampleRate))
    c.drawString(x+10, y_audDetails-59, "Overall Loudness:")
    c.drawString(x+130, y_audDetails-59, "{val} LUFS".format(
                 val=fileLoudness))
    c.drawString(x+10, y_audDetails-72, "R128 compliant:")
    c.drawString(x+130, y_audDetails-72, "{val}".format(
                 val=fileR128))
    ## End audio details.
    
    ## Footer.
    c.setFont("GothamMed", 6)
    footerString = "Ambassadors B.V. - https://www.ambassadors.com/ - AMS +31 20 435 7171 - NYC +1 347 308 5857"
    c.drawCentredString(cWidth/2, y-780, footerString)
    #footer = c.beginText()
    #footer.setFont("GothamMed", 6)
    #footer.setTextOrigin(centeredString(footerString, "GothamMed", 6), y-780)
    #footer.textLine(footerString)
    #c.drawText(footer)
    ## End footer.
    c.showPage()
    c.save()
    print("QC reported can be found at {}".format(outPDF))
    
# End pdfmaker.

if __name__ == "__main__":

    probe_data = probe_infile(inFile)
    loudness = loudness(inFile, probe_data)
    fileinfo = fileinfo(probe_data)

#    with open(outLog, "a") as logfile:
#        for line in fileinfo:
#            print(line, file=logfile)
#        print(loudness, file=logfile)

    inFile_dur = vidlen(probe_data)
    thumbSizes = thumbmaker(inFile, inFile_dur)
    pdfmaker(probe_data, loudness)