import requests
import json

BASE_URL = "http://127.0.0.1:8000/api/quiz/"

def test_api_endpoints():
    print("Testing API Endpoints...")
    
    # Test 1: Start Quiz (will fail without auth, but should return proper error)
    print("\n1. Testing Start Quiz:")
    try:
        response = requests.post(
            f"{BASE_URL}start-quiz/",
            json={"category": "computer"},
            headers={"Content-Type": "application/json"}
        )
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 2: Quiz Stats
    print("\n2. Testing Quiz Stats:")
    try:
        response = requests.get(f"{BASE_URL}quiz-stats/")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 3: Movement Violation
    print("\n3. Testing Movement Violation:")
    try:
        response = requests.post(
            f"{BASE_URL}report-movement-violation/",
            json={
                "violation_type": "looking_away",
                "reason": "Test violation",
                "quiz_session_id": 1
            },
            headers={"Content-Type": "application/json"}
        )
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_api_endpoints()