import csv
from datetime import datetime
import matplotlib.pyplot as plt

timestamps = []
fps_values = []

# Open and read the CSV file.
with open('./data/fps_log_2025-06-09_18-36-36.csv', 'r') as file:
    reader = csv.DictReader(file)
    for row in reader:
        # Adjust the datetime format if needed.
        try:
            ts = datetime.fromisoformat(row['timestamp'])
        except ValueError:
            if row['timestamp'].isdigit():
                if len(row['timestamp']) == 13:
                    ts = datetime.fromtimestamp(int(row['timestamp']) / 1000)
                else:
                    ts = datetime.fromtimestamp(int(row['timestamp']))
            else:
                ts = datetime.strptime(row['timestamp'], "%Y-%d-%mT%H:%M:%S")
        timestamps.append(ts)
        fps_values.append(float(row['fps']))

if not timestamps:
    raise ValueError("No data found in CSV.")

# Convert timestamps to seconds relative to the first timestamp.
start_time = timestamps[0]
time_seconds = [(ts - start_time).total_seconds() for ts in timestamps]

# Filter for the last 97 seconds of data.
last_time = time_seconds[-1]
start_new = last_time - 97

filtered_time = []
filtered_fps = []
for t, fps in zip(time_seconds, fps_values):
    if t >= start_new:
        # Shift so that the new time axis starts at 0.
        filtered_time.append(t - start_new)
        filtered_fps.append(fps)

if not filtered_time:
    raise ValueError("No data in the last 97 seconds.")

# Plot FPS vs. time.
plt.figure(figsize=(10, 6))
plt.plot(filtered_time, filtered_fps, color='blue')

plt.xlabel('Time (s)')
plt.ylabel('Frames per second')
# Removed background grid.
# plt.grid(True)

# Highlight the video playing interval with a shaded region.
plt.axvspan(25, 41, color='gray', alpha=0.3, label='Video playing')
plt.axvspan(60, 97, color='gray', alpha=0.3)

# # Mark wearable connection and disconnection with dotted lines.
# plt.axvline(x=49, color='orange', linestyle=':', label='Wearable connected')
# plt.axvline(x=78, color='orange', linestyle=':', label='Wearable disconnected')

# Annotate sections with vertical dashed lines and text.
section_boundaries = [49, 78]  # x-values in seconds for the section boundaries.
section_labels = ['Example wearable\nconnected', 'Example wearable\ndisconnected']

ylim = plt.ylim()
for i, (boundary, label) in enumerate(zip(section_boundaries, section_labels)):
    plt.axvline(x=boundary, color='red', linestyle='--')
    if i == 0:  # First section: place label at the top.
        y_pos = ylim[1] * 0.9
    else:       # Second section: place label at the bottom.
        y_pos = ylim[0] + (ylim[1] - ylim[0]) * 0.1
    plt.text(boundary, y_pos, label, color='black',
             horizontalalignment='center', backgroundcolor='white')

# plt.legend()
plt.tight_layout()
plt.show()