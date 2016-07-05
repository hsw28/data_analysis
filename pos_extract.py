import pandas as pd
import numpy as np
import re

#np.set_printoptions(formatter={'float': '{: 0.3f}'.format})

with open("test.json", "r") as js:
    raw_data = [d.strip() for d in js.readlines() if d.find("pos_xy") > 0]

# clean true, false (otherwise json won't parse)
# use eval to bypass the nonsense warnings json is giving me.
raw_data1 = [re.sub("false", "0", d) for d in raw_data]
raw_data2 = [re.sub("true", "1", d) for d in raw_data1]
raw_data3 = [eval(d) for d in raw_data2]

# Creates a list of [time, x, y].
raw_data4 = np.array([[d["time"], d["pos_xy"][0], d["pos_xy"][1]] for d in raw_data3])

# Saves time, x, and y as their own arrays.
time, x, y = raw_data4[:,0], raw_data4[:,1], raw_data4[:,2]


# UNCOMMENT THESE AND PUT IN WHERE YOU WANT THEM TO GO.
# time.tofile()
# x.tofile()
# y.tofile()
