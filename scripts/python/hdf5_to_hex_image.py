import numpy as np
from hdf5reader import Hdf5Reader

class Numpy2Hex():
    """
    Converts a numpy array to a python array with strings in hexadecimal
    16-bit format.
    """
    def __init__(self):
        pass

    def convert(self, image):
        """
        Convert numpy image (2D array) to hex text array 2D array.
        """

        hex_array = [["0" for j in range(image.shape[1])]
                                                for i in range(image.shape[0])]

        for i in range(image.shape[0]):
            for j in range(image.shape[1]):
                hex_array[i][j] = "%0.4X" % int(image[i][j])

        return hex_array

if __name__ == '__main__':

    # HDF5 file to extract the imege
    input_file = "/media/roberto/Data/Roberto/Datasets/Custodian/LBW/04-Pruebas RyCO LBW_2019_04_08/Videos NIT/Prueba 40.hdf5"
    # Image number
    image_number = 2560
    # Output text file with the image values in hexadecimal
    output_file = "/home/roberto/git/custodian-camera/hw/sim/meltpool_image_hex.txt"

    # read image from hdf5 file
    reader = Hdf5Reader()
    reader.open(input_file)
    image = reader.read_image(0, image_number).squeeze()
    reader.close()

    # convert to hex
    converter = Numpy2Hex()
    hex_image = converter.convert(image)

    # save to output text file
    writer = open(output_file,"w")
    # for each line
    for i in range(image.shape[0]):
        # compress all elemens in a single string
        text_line = " ".join(hex_image[i]) + "\n"
        # write to file
        writer.write(text_line)
    writer.close()
