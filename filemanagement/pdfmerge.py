#!/usr/bin/env python3

import os
import sys
from PyPDF2 import PdfFileMerger

inputDir = sys.argv[1]
pdflist = os.walk(inputDir)

print(pdflist)
# pdflist = [file for file in  if file.endswith(".pdf")]

# merger = PdfFileMerger()
#
# for pdf in pdflist:
#     merger.append(pdf)
#
# merger.write("{}_merged.pdf".format(
#              os.path.basename(inputDir))
#              )
# merger.close()
