import pandas as pd

import matplotlib.pyplot as plt
import re
import numpy as np

class SnaptoCursor(object):
    def __init__(self, ax, x, y):
        self.ax = ax
        self.ly = ax.axvline(x=x[0],color='k', alpha=0.2)  # the vert line
        self.marker, = ax.plot([x[0]],[y[0]], marker="o", color="crimson", zorder=3)
        self.x = x
        self.y = y
        self.txt = ax.text(0.7, 0.9, '')

    def mouse_move(self, event):
        if not event.inaxes: return
        x, y = event.xdata, event.ydata
        indx = np.searchsorted(self.x, [x])[0]
        if indx >= len(self.x):
            return
        x = self.x[indx]
        y = self.y[indx]
        self.ly.set_xdata(x)
        self.marker.set_data([x],[y])
        #self.txt.set_text('x=%1.2f, y=%1.2f' % (x, y))
        global df
        print(df.loc[[indx]]["Lane_0_FCHK"])
        #display(df.loc[[indx]]["timestamp"])
        self.txt.set_position((x,y))
        self.ax.figure.canvas.draw_idle()


log_jesd_path = "log_jesd.txt"
log_csv_path = "log.csv"

empty_data_frame = {
    "cnt": 0,
    "timestamp": "n/a",
    "phase": [],
    "jesd_status": {},
}


empty_status = {
    "Link": "n/a",
    "Measured Link Clock": "n/a",
    "Reported Link Clock": "n/a",
    "External reset": "n/a",
    "Lane rate": "n/a",
    "Lane rate / 40": "n/a",
    "LMFC rate": "n/a",
    "Link status": "n/a",
    "SYSREF captured": "n/a",
    "SYSREF alignment error": "n/a",
    "lanes": [],
    "temps": [],
    "regs": [],
	"LOs": [],
}
empty_lane_status = {
    "Errors": "n/a",
    "CGS state": "n/a",
    "Initial Frame Synchronization": "n/a",
    "Lane Latency": "n/a",
    "Initial Lane Alignment Sequence": "n/a",
    "DID": "n/a",
    "BID": "n/a",
    "LID": "n/a",
    "L": "n/a",
    "SCR": "n/a",
    "F": "n/a",
    "K": "n/a",
    "M": "n/a",
    "N": "n/a",
    "CS": "n/a",
    "N'": "n/a",
    "S": "n/a",
    "HD": "n/a",
    "FCHK": "n/a",
    "CF": "n/a",
    "ADJCNT": "n/a",
    "PHADJ": "n/a",
    "ADJDIR": "n/a",
    "JESDV": "n/a",
    "SUBCLASS": "n/a",
    "FC": "n/a",
}

empty_clk_status = {}


def parse_str(data, str):
    str = str.replace(",", "\n")
    str = str.splitlines()
    for line in str:
        if not line:
            continue
        keyval = re.compile("( is )|(: )").split(line)
        # keyval=line.split(": ")
        key = keyval[0].strip()
        # we can parse val more here
        val = keyval[-1].strip()
        data[key] = val
    return data


def parse_jesd_string(jesd_content):
    pattern = re.compile("test_nr: [0-9]+ sample_nr: [0-9]+")
    jesd_content = pattern.split(jesd_content)
    count = 0
    jesd_data = []
    sample_status = []
    for row in jesd_content:
        del sample_status
        sample_status = empty_status.copy()

        sample_content = re.split("\*\*\*",row)

        row = re.split("Errors",sample_content[0])
        if len(row) == 1:
            continue

        ## Split general status out
        status = row[0]
        # Remove blank lines first
        outlines = []
        for line in status.split("\n"):
            if len(line) > 2:
                outlines.append(line)
        #assert len(outlines) == 9, "Unhandled status case"
        if len(outlines)!=9:
            print("ERROR")
        status = "\n".join(outlines)
        sample_status = parse_str(sample_status, status)

        # sample_status.pop("lanes", None)
        sample_status["lanes"] = []
        # Process lanes
        print("----")
        all_lane_status = row[1:]
        i=0

        for lane_status in all_lane_status:
            lane_status = "Errors" + lane_status
            sample_status["lanes"].append(empty_lane_status.copy())
            sample_status["lanes"][-1] = parse_str(
                sample_status["lanes"][-1], lane_status
            )
            i=i+1

        #print(sample_content[1:])
        temps=sample_content[1].split(":")[1]
        temps=temps.split()
        sample_status["temps"] = []
        for temp in temps:
            sample_status["temps"].append(temp)
        #
        regs = sample_content[2].split(":")[1]
        regs = regs.split()
        sample_status["regs"] = []
        for reg in regs:
            sample_status["regs"].append(reg)
        #
        LOs = sample_content[3].split(":")[1]
        LOs = LOs.split()
        sample_status["LOs"] = []
        for LO in LOs:
            sample_status["LOs"].append(LO)
			
        print(len(sample_status["lanes"]))
        jesd_data.append(sample_status)
        count = count + 1
        print("Processed", count)
    print("done")
    return jesd_data


def main():
    with open(log_jesd_path, "r") as f:
        jesd_content = f.read()
    with open(log_csv_path, "r") as f:
        csv_content = f.readlines()

    jesd_data = parse_jesd_string(jesd_content)
    print(len(jesd_data))

    # Flatten data for dataframe
    jesd_data_flat = dict()
    for i, data in enumerate(jesd_data):
        print(i)
        jesd_data_flat[i] = jesd_data[i].copy()
        # Flatten lanes
        del jesd_data_flat[i]["lanes"]
        for j, lane in enumerate(jesd_data[i]["lanes"]):
            for field in lane:
                new_field_name = "Lane_" + str(j) + "_" + field
                jesd_data_flat[i][new_field_name] = jesd_data[i]["lanes"][j][field]

        for j, temp in enumerate(jesd_data[i]["temps"]):
                new_field_name = "Temp_" + str(j)
                jesd_data_flat[i][new_field_name] = jesd_data[i]["temps"][j]

        for j, reg in enumerate(jesd_data[i]["regs"]):
                new_field_name = "Reg_" + str(j)
                jesd_data_flat[i][new_field_name] = jesd_data[i]["regs"][j]

        for j, LO in enumerate(jesd_data[i]["LOs"]):
                new_field_name = "LO_" + str(j)
                jesd_data_flat[i][new_field_name] = jesd_data[i]["LOs"][j]

    # Get phase information
    j = 0
    i = 0
    data_frames = []
    for sample in csv_content:
        data_frame = empty_data_frame.copy()
        del data_frame["phase"]
        sample = sample.split(",")
        data_frame["cnt"] = j*3+i
        data_frame["timestamp"] = float(sample[0].strip())
        for k, ph in enumerate(sample[1:]):
            ph.strip()
            ph = float(ph)
            data_frame["phase_" + str(k)] = ph

        data_frame = {**data_frame, **jesd_data_flat[int(j)].copy()}
        print(i, j)
        data_frames.append(data_frame)

        if i == 2:
            i = 0
            j = j + 1
            # break
        else:
            i = i + 1

    # Remove old field name
    for i in range(len(data_frames)):
        del data_frames[i]["jesd_status"]

    print("Writing output files")
    global df
    df = pd.DataFrame.from_dict(data_frames)
    df.to_csv("out.csv", index=False)
    #pandas_data.to_excel("output.xlsx")

    print("plotting")
    #fig,axs=plt.subplots(2)
    ax = plt.gca()


    df["Lane_0_Errors"] = df["Lane_0_Errors"].astype(int)
    df.plot(kind='line',x='cnt',y='phase_0',ax=ax)
    df.plot(kind='line',x='cnt',y='phase_1', color='red', ax=ax)
    df.plot(kind='line', x='cnt', y='phase_2', ax=ax)
    df.plot(kind='line', x='cnt', y='Lane_0_Errors', ax=ax) # ar trebui multiple y axis aici
    #df.plot(kind='line', x='timestamp', y='Lane_0_Errors',  ax=ax)

    cursor = SnaptoCursor(ax, df["cnt"], df["phase_0"])
    cid = plt.connect('motion_notify_event', cursor.mouse_move)


    print(df.loc[[0]])
    plt.show()
main()