import mysql.connector
from datetime import datetime, timedelta
from routes import get_time_remaining, get_db_connection, calculate_streak, auth
import requests


def get_today_steps(uid, cursor):
    today = datetime.now().strftime('%Y-%m-%d')
    cursor.execute("SELECT steps FROM steps WHERE uid = %s AND date = %s", (uid, today))
    result = cursor.fetchone()
    return result[0] if result else 0

def main():
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

if __name__ == "__main__":
    main()
