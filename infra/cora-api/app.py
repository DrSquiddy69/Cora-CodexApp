import hashlib
import secrets
import sqlite3
import uuid
from pathlib import Path
import shutil
from typing import Optional

from fastapi import FastAPI, File, HTTPException, Request, UploadFile
from passlib.hash import argon2
from pydantic import BaseModel, EmailStr, Field
from fastapi.staticfiles import StaticFiles

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / 'cora.db'
UPLOADS_DIR = BASE_DIR / 'uploads'
SAFE_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'

app = FastAPI(title='cora-api', version='1.0.0')
UPLOADS_DIR.mkdir(exist_ok=True)
app.mount('/uploads', StaticFiles(directory=UPLOADS_DIR), name='uploads')


def db() -> sqlite3.Connection:
    connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    return connection


def init_db() -> None:
    with db() as conn:
        conn.execute(
            '''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                friend_code TEXT UNIQUE NOT NULL,
                matrix_user_id TEXT UNIQUE NOT NULL,
                display_name TEXT NOT NULL,
                avatar_url TEXT,
                bio TEXT DEFAULT ''
            )
            '''
        )

        conn.execute(
            '''
            CREATE TABLE IF NOT EXISTS friend_requests (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                from_matrix_user_id TEXT NOT NULL,
                to_matrix_user_id TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'pending',
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(from_matrix_user_id, to_matrix_user_id)
            )
            '''
        )


class SignupRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    display_name: str = Field(min_length=1, max_length=40)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)


class FriendRequestCreate(BaseModel):
    from_matrix_user_id: str
    to_matrix_user_id: str


class FriendRequestUpdate(BaseModel):
    status: str = Field(pattern='^(accepted|denied)$')


class ProfileUpdateRequest(BaseModel):
    display_name: Optional[str] = Field(default=None, max_length=40)
    bio: Optional[str] = Field(default=None, max_length=320)
    avatar_url: Optional[str] = None


def hash_password(password: str) -> str:
    return argon2.hash(password)


def verify_password(password: str, encoded_hash: str) -> bool:
    try:
        return argon2.verify(password, encoded_hash)
    except ValueError:
        return False


def build_matrix_user_id(email: str) -> str:
    matrix_localpart = f"u_{hashlib.sha256(email.lower().strip().encode('utf-8')).hexdigest()[:12]}"
    return f'@{matrix_localpart}:cora.local'


def generate_friend_code(conn: sqlite3.Connection) -> str:
    while True:
        code = ''.join(secrets.choice(SAFE_CHARS) for _ in range(5))
        exists = conn.execute('SELECT 1 FROM users WHERE friend_code = ?', (code,)).fetchone()
        if not exists:
            return code


def safe_user_dict(row: sqlite3.Row) -> dict:
    return {
        'email': row['email'],
        'friend_code': row['friend_code'],
        'matrix_user_id': row['matrix_user_id'],
        'display_name': row['display_name'],
        'avatar_url': row['avatar_url'],
        'bio': row['bio'],
    }


@app.on_event('startup')
def startup() -> None:
    init_db()


@app.get('/health')
def health() -> dict:
    return {'ok': True}


@app.post('/signup', status_code=201)
def signup(payload: SignupRequest) -> dict:
    with db() as conn:
        existing = conn.execute('SELECT id FROM users WHERE email = ?', (payload.email,)).fetchone()
        if existing:
            raise HTTPException(status_code=409, detail='Email already exists')

        friend_code = generate_friend_code(conn)
        matrix_user_id = build_matrix_user_id(payload.email)

        try:
            conn.execute(
                '''
                INSERT INTO users (email, password_hash, friend_code, matrix_user_id, display_name)
                VALUES (?, ?, ?, ?, ?)
                ''',
                (
                    payload.email,
                    hash_password(payload.password),
                    friend_code,
                    matrix_user_id,
                    payload.display_name,
                ),
            )
        except sqlite3.IntegrityError as exc:
            raise HTTPException(status_code=409, detail='Account already exists') from exc

        row = conn.execute('SELECT * FROM users WHERE email = ?', (payload.email,)).fetchone()
        return safe_user_dict(row)


@app.post('/login')
def login(payload: LoginRequest) -> dict:
    with db() as conn:
        row = conn.execute('SELECT * FROM users WHERE email = ?', (payload.email,)).fetchone()
        if not row or not verify_password(payload.password, row['password_hash']):
            raise HTTPException(status_code=401, detail='Invalid credentials')
        return safe_user_dict(row)


@app.get('/me/{email}')
def me(email: EmailStr) -> dict:
    with db() as conn:
        row = conn.execute('SELECT * FROM users WHERE email = ?', (email,)).fetchone()
        if not row:
            raise HTTPException(status_code=404, detail='User not found')
        return safe_user_dict(row)


@app.get('/friendcode/{friend_code}')
def lookup(friend_code: str) -> dict:
    if len(friend_code) != 5 or any(ch not in SAFE_CHARS for ch in friend_code.upper()):
        raise HTTPException(status_code=400, detail='Invalid friend code format')

    with db() as conn:
        row = conn.execute(
            'SELECT matrix_user_id, display_name, avatar_url FROM users WHERE friend_code = ?',
            (friend_code.upper(),),
        ).fetchone()
        if not row:
            raise HTTPException(status_code=404, detail='Friend code not found')
        return dict(row)


@app.post('/friend-requests', status_code=201)
def create_friend_request(payload: FriendRequestCreate) -> dict:
    with db() as conn:
        try:
            conn.execute(
                '''
                INSERT INTO friend_requests (from_matrix_user_id, to_matrix_user_id)
                VALUES (?, ?)
                ''',
                (payload.from_matrix_user_id, payload.to_matrix_user_id),
            )
        except sqlite3.IntegrityError as exc:
            raise HTTPException(status_code=409, detail='Friend request already exists') from exc
    return {'ok': True}


@app.get('/friend-requests/{matrix_user_id}')
def list_friend_requests(matrix_user_id: str) -> dict:
    with db() as conn:
        rows = conn.execute(
            '''
            SELECT * FROM friend_requests
            WHERE to_matrix_user_id = ? AND status = 'pending'
            ORDER BY created_at DESC
            ''',
            (matrix_user_id,),
        ).fetchall()
    return {'requests': [dict(row) for row in rows]}


@app.patch('/friend-requests/{request_id}')
def update_friend_request(request_id: int, payload: FriendRequestUpdate) -> dict:
    with db() as conn:
        conn.execute('UPDATE friend_requests SET status = ? WHERE id = ?', (payload.status, request_id))
        row = conn.execute('SELECT * FROM friend_requests WHERE id = ?', (request_id,)).fetchone()
        if not row:
            raise HTTPException(status_code=404, detail='Request not found')
    return dict(row)


@app.patch('/profile/{email}')
def update_profile(email: EmailStr, payload: ProfileUpdateRequest) -> dict:
    updates = []
    values = []
    for field in ('display_name', 'bio', 'avatar_url'):
        value = getattr(payload, field)
        if value is not None:
            updates.append(f'{field} = ?')
            values.append(value)

    if not updates:
        raise HTTPException(status_code=400, detail='No fields to update')

    values.append(email)

    with db() as conn:
        conn.execute(f'UPDATE users SET {", ".join(updates)} WHERE email = ?', values)
        row = conn.execute('SELECT * FROM users WHERE email = ?', (email,)).fetchone()
        if not row:
            raise HTTPException(status_code=404, detail='User not found')
        return safe_user_dict(row)


@app.post('/upload/avatar', status_code=201)
async def upload_avatar(request: Request, file: UploadFile = File(...)) -> dict:
    suffix = Path(file.filename or '').suffix.lower()
    if suffix not in {'.png', '.jpg', '.jpeg', '.webp', '.gif'}:
        raise HTTPException(status_code=400, detail='Unsupported image format')

    filename = f"{uuid.uuid4().hex}{suffix}"
    destination = UPLOADS_DIR / filename

    with destination.open('wb') as output:
        shutil.copyfileobj(file.file, output)

    base_url = str(request.base_url).rstrip('/')
    return {'avatar_url': f'{base_url}/uploads/{filename}'}
