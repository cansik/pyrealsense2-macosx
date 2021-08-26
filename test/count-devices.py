import pyrealsense2 as rs

ctx = rs.context()
devices = ctx.query_devices()

print(f"Found {len(devices)} realsense devices!")
exit(0)