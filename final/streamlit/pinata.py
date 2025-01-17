import os
import json
import requests
from dotenv import load_dotenv

load_dotenv()

file_headers = {'pinata_api_key': os.getenv('PINATA_API_KEY'), 'pinata_secret_api_key': os.getenv('PINATA_SECRET_API_KEY')}
json_headers = {'Content-Type': 'application/json', 'pinata_api_key': os.getenv('PINATA_API_KEY'), 'pinata_secret_api_key': os.getenv('PINATA_SECRET_API_KEY')}

def convert_data_to_json(content):
    data = {'pinataOptions': {'cidVersion': 1}, 'pinataContent': content}
    return json.dumps(data)

def pin_file_to_ipfs(data):
    r = requests.post('https://api.pinata.cloud/pinning/pinFileToIPFS', files = {'file': data}, headers = file_headers)
    print(r.json())
    ipfs_hash = r.json()['IpfsHash']
    return ipfs_hash

def pin_json_to_ipfs(json):
    r = requests.post('https://api.pinata.cloud/pinning/pinJSONToIPFS', data = json, headers = json_headers)
    print(r.json())
    ipfs_hash = r.json()['IpfsHash']
    return ipfs_hash

def pin_artwork(artwork_name, artwork_file):
    ipfs_file_hash = pin_file_to_ipfs(artwork_file.getvalue())
    token_json = {'name': artwork_name, 'image': ipfs_file_hash}
    json_data = convert_data_to_json(token_json)
    json_ipfs_hash = pin_json_to_ipfs(json_data)
    return json_ipfs_hash, token_json

def pin_appraisal_report(report_content):
    json_report = convert_data_to_json(report_content)
    report_ipfs_hash = pin_json_to_ipfs(json_report)
    return report_ipfs_hash
