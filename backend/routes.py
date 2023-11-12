from flask import Flask, request, jsonify, Response
import requests
import base64

import os
import random
import mysql.connector
from datetime import datetime
import string
import random
def generate_invite_code(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

def generate_uid(size=8, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

app = Flask(__name__)

@app.route('/speech', methods=['GET'])
def speech_data():
    text = request.args.get('text', '')

    formdata = {
        'customerid': '7',
        'voice': "Jack-DNN",
        'lang': "en_au",
        'url': 'https://www.readspeaker.com/languages-voices/',
        'audioformat': 'ogg',
        'selectedhtml_base64': base64.b64encode(text.encode()).decode()
    }

    formdata['speed'] = "100"

    response = requests.post(
        "https://app-eu.readspeaker.com/cgi-bin/rsent",
        data=formdata,
        headers={'Content-Type': 'application/x-www-form-urlencoded'},
        allow_redirects=True
    )

    if response.status_code != 200:
        return "Error fetching audio", 500

    return Response(response.content, mimetype='audio/ogg')

def get_db_connection():
    return mysql.connector.connect(
        host=os.environ.get('DB_HOST', 'localhost'),
        port=3307,
        user=os.environ.get('DB_USER', 'USERNAME'),
        password=os.environ.get('DB_PASSWORD', 'PASSWORD'),
        database=os.environ.get('DB_NAME', 'bearrun')
    )

@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()

    uid = generate_uid()
    hue_deg = random.randint(0, 360)
    my_invite_code = generate_invite_code()
    phone_number = data.get('phone_number', '')  

    query = """
    INSERT INTO users (uid, bear_name, invite_code, hue_deg, my_invite_code, phone_number) 
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    values = (uid, data['bear_name'], data['invite_code'], hue_deg, my_invite_code, phone_number)

    cursor.execute(query, values)
    conn.commit()

    cursor.close()
    conn.close()

    return jsonify({'message': 'User created', 'uid': uid, 'hue_deg': hue_deg, 'my_invite_code': my_invite_code}), 201

@app.route('/update_location', methods=['POST'])
def update_location():
    data = request.json
    uid = data['uid']
    lat_long = data['lat_long']

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("UPDATE users SET lat_long = %s WHERE uid = %s", (lat_long, uid))
    conn.commit()

    cursor.close()
    conn.close()

    return jsonify({'message': 'Location updated successfully'}), 200



import requests

# 46elks API credentials
auth = (
    '46ELKS_USER',
    '46ELKS_PASS'
    )


def get_today_steps(uid, cursor):
    today = datetime.now().strftime('%Y-%m-%d')
    cursor.execute("SELECT steps FROM steps WHERE uid = %s AND date = %s", (uid, today))
    result = cursor.fetchone()
    return result[0] if result else 0

def threaten():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT uid, bear_name, phone_number FROM users WHERE phone_number IS NOT NULL AND phone_number != ''")
    users = cursor.fetchall()

    for uid, bear_name, phone_number in users:
        streak = calculate_streak(uid)
        time_remaining = get_time_remaining()
        today_steps = get_today_steps(uid, cursor)
        steps_left = max(0, 10000 - today_steps)  

        print(phone_number)
        print(f"Bear Name: {bear_name}, Time Remaining: {time_remaining}, Streak: {streak}, Steps Left Today: {steps_left}")

        voice_message = f"Hello, it's your bear {bear_name}. I am coming to bite your arms off tonight while you're asleep. Unless you walk {steps_left} more steps to reach your goal. You have {time_remaining} left. Good luck. Bye."
        
        # Stuff passed to 46elks API
        fields = {
            'from': '[your 46elks number]',
            'to': phone_number,
            'voice_start': '{"play":"https://[this-service-on-internet]/speech?text=' + voice_message + '"}'
        }
        
        response = requests.post(
            "https://api.46elks.com/a1/calls",
            data=fields,
            auth=auth
        )
        print(response.text)
        

    cursor.close()
    conn.close()

@app.route('/threat', methods=['GET'])
def threat_route():
    threaten()
    return jsonify({'message': 'Location updated successfully'}), 200

@app.route('/me', methods=['GET'])
def get_user_info():
    uid = request.args.get('uid')
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT bear_name, hue_deg, my_invite_code, invite_code FROM users WHERE uid = %s", (uid,))
    user = cursor.fetchone()

    if not user:
        cursor.close()
        conn.close()
        return jsonify({'message': 'User not found'}), 404

    bear_name, hue_deg, my_invite_code, invited_by_code = user

    user_streak = calculate_streak(uid)

    time_remaining, is_critical = get_time_remaining()

    cursor.execute("""
        SELECT uid, hue_deg, bear_name 
        FROM users 
        WHERE invite_code = %s OR my_invite_code = %s
    """, (my_invite_code, invited_by_code))
    invited_users = cursor.fetchall()

    invited_users_list = []
    for invited_uid, invited_hue_deg, invited_bear_name in invited_users:
        invited_streak = calculate_streak(invited_uid)
        invited_users_list.append({
            'hue_deg': invited_hue_deg, 
            'bear_name': invited_bear_name, 
            'streak': invited_streak
        })

    cursor.close()
    conn.close()

    return jsonify({
        'bear_name': bear_name,
        'hue_deg': hue_deg,
        'my_invite_code': my_invite_code,
        'streak': user_streak,
        'time_remaining': time_remaining,
        'critical': is_critical,
        'invited_users': invited_users_list
    })

@app.route('/update', methods=['POST'])
def update_steps():
    data = request.json
    uid = data['uid']
    date = data['date']
    steps = data['steps']

    conn = get_db_connection()
    cursor = conn.cursor()

    query = """
    INSERT INTO steps (uid, date, steps) 
    VALUES (%s, %s, %s) 
    ON DUPLICATE KEY UPDATE steps = VALUES(steps)
    """
    values = (uid, date, steps)

    cursor.execute(query, values)
    conn.commit()

    cursor.close()
    conn.close()

    return jsonify({'message': 'Steps updated successfully'}), 200



from datetime import datetime, timedelta

def calculate_streak(uid):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT is_dead FROM users WHERE uid = %s", (uid,))
    is_dead = cursor.fetchone()[0]
    if is_dead:
        return -1  

    cursor.execute("SELECT date, steps FROM steps WHERE uid = %s ORDER BY date DESC", (uid,))
    steps_data = cursor.fetchall()

    if not steps_data:
        cursor.execute("SELECT DATE(your_registration_date_column) = CURRENT_DATE FROM users WHERE uid = %s", (uid,))
        is_new_user = cursor.fetchone()[0]
        if is_new_user:
            return 0  
        else:
            cursor.execute("UPDATE users SET is_dead = TRUE WHERE uid = %s", (uid,))
            conn.commit()
            return -1  
        
    cursor.execute("SELECT date, steps FROM steps WHERE uid = %s ORDER BY date DESC", (uid,))
    steps_data = cursor.fetchall()

    if not steps_data:
        return 0  

    streak = 0
    current_date = datetime.now().date()

    for step_date, step_count in steps_data:
        if isinstance(step_date, str):
            step_date = datetime.strptime(step_date, '%Y-%m-%d').date()

        if step_date == current_date and step_count >= 10000:
            streak += 1
            current_date -= timedelta(days=1)
        else:
            break

    cursor.close()
    conn.close()

    return streak



def get_time_remaining():
    now = datetime.now()
    end_of_today = datetime(now.year, now.month, now.day) + timedelta(days=1)
    remaining_time = end_of_today - now
    hours, remainder = divmod(int(remaining_time.total_seconds()), 3600)
    minutes, _ = divmod(remainder, 60)
    is_critical = hours < 3
    return f"{hours} hours, {minutes} minutes", is_critical

if __name__ == "__main__":
    app.run(debug=True)
