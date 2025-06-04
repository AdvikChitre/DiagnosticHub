import os
import re
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

base_dir = os.path.dirname(os.path.abspath(__file__))
cpu_file = os.path.join(base_dir, 'data', 'cpu_usage.csv')
mem_file = os.path.join(base_dir, 'data', 'mem_usage.csv')

def parse_cpu_file(file_path):
    times = []
    usages = []
    # matches lines starting with a time like "12:18:05 AM"
    time_pattern = re.compile(r'^\d{1,2}:\d{2}:\d{2}\s+(AM|PM)')
    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            if time_pattern.match(line):
                tokens = line.split()
                if len(tokens) < 3:
                    continue
                # Process data row that starts with "time period all"
                if tokens[2] == "all":
                    timestamp = f"{tokens[0]} {tokens[1]}"
                    try:
                        idle_val = float(tokens[-1])
                        # CPU usage computed as 100 - idle percentage
                        usage = 100 - idle_val
                        times.append(timestamp)
                        usages.append(usage)
                    except ValueError:
                        continue
    return times, usages

def parse_mem_file(file_path):
    times = []
    mem_usages = []
    # matches lines starting with a time like "12:18:05 AM"
    time_pattern = re.compile(r'^\d{1,2}:\d{2}:\d{2}\s+(AM|PM)')
    current_timestamp = None
    with open(file_path, 'r') as f:
        for line in f:
            stripped = line.strip()
            # Check if line starts with a timestamp.
            if time_pattern.match(stripped):
                current_timestamp = stripped
                continue
            # Look for the Mem data line.
            # Expected format: "Mem: total used free shared buff/cache available"
            if stripped.startswith("Mem:"):
                parts = stripped.split()
                if len(parts) < 3:
                    continue
                try:
                    total_mem = float(parts[1])
                    used_mem = float(parts[2])
                    # Compute percentage memory usage.
                    usage = used_mem / total_mem * 100 if total_mem else 0
                    if current_timestamp is None:
                        current_timestamp = f"Measurement {len(times)+1}"
                    times.append(current_timestamp)
                    mem_usages.append(usage)
                except ValueError:
                    continue
    return times, mem_usages

def convert_times_to_seconds(time_strs):
    # Assumes time_strs in "%I:%M:%S %p" format.
    base = datetime.strptime(time_strs[0], "%I:%M:%S %p")
    seconds = []
    for ts in time_strs:
        dt = datetime.strptime(ts, "%I:%M:%S %p")
        # Calculate elapsed seconds from base time.
        elapsed = (dt - base).total_seconds()
        seconds.append(elapsed)
    return seconds

# Process CPU data.
cpu_times, cpu_usages = parse_cpu_file(cpu_file)
cpu_seconds = convert_times_to_seconds(cpu_times)
print("CPU Times (s):", cpu_seconds)
print("CPU Usages (%):", cpu_usages)

plt.figure(figsize=(10, 5))
plt.plot(cpu_seconds, cpu_usages, marker='x', markersize=5, label="CPU Usage")
# Highlight period when server was switched off
plt.axvspan(40, 130, color='gray', alpha=0.3, label='Server switched off (t=40 to t=130)')
plt.xlabel("Time (s)")
plt.ylabel("CPU Usage (%)")
plt.xticks(np.arange(0, max(cpu_seconds)+10, 10))
# plt.legend()
plt.tight_layout()
plt.show()

# Process Memory data.
mem_times, mem_usage_percent = parse_mem_file(mem_file)
print("Memory Usage (%):", mem_usage_percent)

plt.figure(figsize=(10, 5))
plt.plot(cpu_seconds, mem_usage_percent, marker='x', markersize=5, color='r', label="Memory Usage")
# Highlight period when server was switched off
plt.axvspan(40, 130, color='gray', alpha=0.3, label='Server switched off (t=40 to t=130)')
plt.xlabel("Time (s)")
plt.ylabel("Memory Usage (%)")
plt.xticks(np.arange(0, max(cpu_seconds)+10, 10))
# plt.legend()
plt.tight_layout()
plt.show()