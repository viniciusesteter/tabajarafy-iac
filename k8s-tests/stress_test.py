import requests
from concurrent.futures import ThreadPoolExecutor
import threading
import time

APP_URL = "http://a04f9c20d7e014ee4ba04d7106a3f749-642663165.us-east-1.elb.amazonaws.com/" # Change
NUM_REQUESTS = 100
NUM_THREADS = 20
DURATION = 120
SLEEP_BETWEEN_REQUESTS = 0.05

STOP_TEST = False

def hit():
    try:
        response = requests.get(APP_URL)
        print(f"Status: {response.status_code}")
    except Exception as e:
        print(f"Error: {e}")

def stress():
    while not STOP_TEST:
        try:
            r = requests.get(APP_URL, timeout=2)
            print(f"Status: {r.status_code}")
        except Exception as e:
            print(f"Error: {e}")
        time.sleep(SLEEP_BETWEEN_REQUESTS)

if __name__ == "__main__":
    with ThreadPoolExecutor(max_workers=NUM_REQUESTS) as executor:
        for _ in range(NUM_REQUESTS):
            executor.submit(hit)
    
    threads = []
    for _ in range(NUM_THREADS):
        t = threading.Thread(target=stress)
        t.start()
        threads.append(t)

    print(f"Running stress test with {NUM_THREADS} threads for {DURATION} seconds...")
    time.sleep(DURATION)
    STOP_TEST = True

    for t in threads:
        t.join()

    print("Stress test completed!")
