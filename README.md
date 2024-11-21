# Password Manager

## Setup Instructions

1. **Clone the repository**:
```bash
https://github.com/chrishernzz/Password-Manager.git
```
2. **Create a virtual environment**:
- if on backend:
```bash
cd backend
python -m venv venv
```
3. **Activate the virtual environment**:
- On Windows:
```bash
venv\Scripts\activate
```
- on macOS and Linux:
```bash
source venv/bin/activate
```
4. **Install the required packages**:
```bash
pip install -r requirements.txt
```

## Project Structure Backend
- Password-Manager
    - backend/
        - app/
            - __init__.py
            - models.py
            - encryption.py
            - password_utils.py
            - database.py
            - config.py
            - main.py
            - .env
        - venv/
        - .gitignore
        - requirements.txt
        - readme.md
        - server.py