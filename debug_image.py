
import requests
import sys

BASE_URL = "http://127.0.0.1:5000"
FILENAME = "eb687676-d686-4fd5-8aeb-ef561bca909c.jpg" # Using one of the existing files

try:
    url = f"{BASE_URL}/uploads/{FILENAME}"
    print(f"Requesting: {url}")
    response = requests.get(url)
    
    print(f"Status Code: {response.status_code}")
    print(f"Headers: {response.headers}")
    
    if response.status_code == 200:
        print(f"Content Length: {len(response.content)}")
    else:
        print(f"Response Body: {response.text}")

except Exception as e:
    print(f"Error: {e}")
