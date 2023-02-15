import os
from PIL import Image
for filename in os.listdir("./"):
    if filename.endswith(".png") and filename.startswith("type"):
        image = Image.open(filename)
        image = image.resize((16,16),Image.ANTIALIAS)
        newfilename = f"out/{filename[4:]}"
        image.save(fp=newfilename)
        continue
    else:
        continue