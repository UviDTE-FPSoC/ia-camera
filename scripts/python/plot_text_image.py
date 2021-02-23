import matplotlib.pyplot as plt
import numpy as np

if __name__ == '__main__':
    input_file = "/home/roberto/git/custodian-camera/hw/sim/output_file.txt"
    img = np.loadtxt(input_file)
    print(img.shape)
    plt.imshow(img)
    plt.show()
