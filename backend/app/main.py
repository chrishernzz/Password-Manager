# main driver to integrate all modules
import sqlite3
from flask import Flask, jsonify, request
from app.database import init_db, get_db_connection
from app.encryption import encrypt_password, decrypt_password
from app.config import SECRET_KEY

app = Flask(__name__)

# Initialize the database
init_db()

@app.route('/api/register', methods=['POST'])
def register():
    """
    Endpoint to handle user registration.
    """
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not all([username, password]):
        return jsonify({"status": "error", "message": "Missing fields"}), 400

    # Hash the password
    hashed_password = encrypt_password(password)  # Use a proper hash function in production

    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO users (username, password_hash) VALUES (?, ?)",
            (username, hashed_password)
        )
        conn.commit()
    except sqlite3.IntegrityError:
        return jsonify({"status": "error", "message": "Username already exists"}), 409
    finally:
        conn.close()

    return jsonify({"status": "success", "message": "User registered successfully"}), 201


@app.route('/api/login', methods=['POST'])
def login():
    """
    Endpoint to handle user login.
    """
    data = request.json
    username = data.get('username')
    password = data.get('password')

    conn = get_db_connection()
    cursor = conn.cursor()

    # Check if the user exists
    cursor.execute("SELECT password_hash FROM users WHERE username = ?", (username,))
    user = cursor.fetchone()
    conn.close()

    if not user:
        return jsonify({"status": "error", "message": "User not found"}), 404

    # Verify password
    hashed_password = user[0]
    if password == hashed_password:  # Replace with hash verification in production
        return jsonify({"status": "success", "message": "Login successful"}), 200
    else:
        return jsonify({"status": "error", "message": "Invalid credentials"}), 401


@app.route('/api/save-password', methods=['POST'])
def save_password():
    """
    Endpoint to save a password for a specific service.
    """
    data = request.json
    user_id = data.get('user_id')
    service_name = data.get('service_name')
    username = data.get('username')
    password = data.get('password')

    if not all([user_id, service_name, username, password]):
        return jsonify({"status": "error", "message": "Missing fields"}), 400

    # Encrypt the password
    encrypted_password = encrypt_password(password)

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO passwords (user_id, service_name, username, password_encrypted)
        VALUES (?, ?, ?, ?)
    """, (user_id, service_name, username, encrypted_password))
    conn.commit()
    conn.close()

    return jsonify({"status": "success", "message": "Password saved successfully"}), 201


@app.route('/api/get-passwords/<int:user_id>', methods=['GET'])
def get_passwords(user_id):
    """
    Endpoint to retrieve all saved passwords for a user.
    """
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT service_name, username, password_encrypted
        FROM passwords
        WHERE user_id = ?
    """, (user_id,))
    passwords = cursor.fetchall()
    conn.close()

    # Decrypt the passwords
    result = []
    for service_name, username, encrypted_password in passwords:
        decrypted_password = decrypt_password(encrypted_password)
        result.append({
            "service_name": service_name,
            "username": username,
            "password": decrypted_password
        })

    return jsonify({"status": "success", "data": result}), 200


if __name__ == '__main__':
    app.run(debug=True)
