import os
from datetime import datetime, timedelta, timezone

import requests
from flask import Flask, session, render_template

app = Flask(__name__)
app.secret_key = 'make this a long random string'

BASE_URL = 'https://mware-dev.crscreditapi.com'


@app.route('/')
def root():
    if 'token' not in session:
        return '<a href="/login">Please login.</a>'

    email = session['email']
    token = session['token']
    created_at = datetime.fromisoformat(session['created_at'])
    expires = session['expires']
    remaining_time = timedelta(seconds=expires)
    expires_at = created_at - remaining_time
    is_valid = expires_at < datetime.now(timezone.utc)

    return render_template('index.html', email=email, token=token, expires_at=expires_at, is_valid=is_valid)


@app.route('/report')
def report():
    if 'token' not in session:
        return '<a href="/login">Please login.</a>'

    payload = {
        "consumers": {
            "name": [
                {
                    "identifier": "current",
                    "firstName": "ASAD",
                    "lastName": "YCSWL"
                }
            ],
            "socialNum": [
                {
                    "identifier": "current",
                    "number": "666176062"
                }
            ],
            "dateOfBirth": "05061985",
            "addresses": [
                {
                    "identifier": "current",
                    "houseNumber": "8615",
                    "streetName": "Black Tern",
                    "streetType": "LN",
                    "city": "HOUSTON",
                    "state": "TX",
                    "zip": "77040"
                }
            ],
            "phoneNumbers": [
                {
                    "identifier": "current",
                    "number": "7135551212"
                }
            ]
        }
    }
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + session['token']
    }
    response = requests.post(BASE_URL + '/api/equifax/credit-report', headers=headers, json=payload)

    return response.json()


@app.route('/login')
def login():
    data = {
        "username": os.environ.get("CRS_API_USERNAME"),
        "password": os.environ.get("CRS_API_PASSWORD")
    }
    headers = {"Content-Type": "application/json"}
    response = requests.post(BASE_URL + '/api/users/login', headers=headers, json=data)

    response_data = response.json()
    if 'token' not in response_data:
        return response_data

    session['token'] = response_data['token']
    session['email'] = response_data['email']
    session['name'] = response_data['name']
    session['created_at'] = response_data['createdAt']
    session['expires'] = response_data['expires']

    return response_data, response.status_code


if __name__ == '__main__':
    app.run(debug=True)