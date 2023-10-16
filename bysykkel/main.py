import json
import sys
# Load mapping.json
with open('mapping.json', 'r') as f:
    mapping = json.load(f)

# Read from stdin
stations = json.loads(sys.stdin.read())

# Create a new list to store stations with valid mappings
updated_stations = []

for station in stations:
    station_id = station['station_id']
    if station_id in mapping:
        station['station_id'] = mapping[station_id]
        updated_stations.append(station)

# Report the result
smileys = ["😊", "😎", "🤓", "😜", "🥳", "😇", "🤠", "😺", "👽", "🤖"]
for idx, station in enumerate(updated_stations):
    smiley = smileys[idx % len(smileys)]  # Rotate through the smileys
    print(f"{smiley} {str.upper(station['station_id'])}:\n------------------------\n Sykkler: {station['num_bikes_available']}, Plasser: {station['num_docks_available']}\n\n")

# If you still want to save the data to a file, you can uncomment the below lines
# with open('updated_file.json', 'w') as f:
#     json.dump(updated_stations, f, indent=4)
