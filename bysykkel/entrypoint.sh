curl -s https://gbfs.urbansharing.com/oslobysykkel.no/station_status.json | jq '[.data.stations[] | {station_id, num_bikes_available, num_docks_available}]' | python main.py