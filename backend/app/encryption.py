from dotenv import load_dotenv
import os
from cryptography.fernet import Fernet

load_dotenv()

# Load the key from an environment variable
SECRET_KEY = os.getenv("SECRET_KEY")
if not SECRET_KEY:
    raise ValueError("SECRET_KEY environment variable not set")

cipher_suite = Fernet(SECRET_KEY.encode())

def encrypt_password(password: str) -> str:
    encrypted_password = cipher_suite.encrypt(password.encode())
    return encrypted_password.decode()

def decrypt_password(encrypted_password: str) -> str:
    decrypted_password = cipher_suite.decrypt(encrypted_password.encode())
    return decrypted_password.decode()



if __name__ == "__main__":
    # Test the encryption and decryption functionality
    test_password = "MySecurePassword123"
    print("Original Password:", test_password)

    # Encrypt the test password
    encrypted = encrypt_password(test_password)
    print("Encrypted Password:", encrypted)

    # Decrypt the encrypted password
    decrypted = decrypt_password(encrypted)
    print("Decrypted Password:", decrypted)
