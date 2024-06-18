from flask import Flask, request, jsonify
import sqlite3
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
DATABASE = 'usuarios.db'

def init_db():
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute('''CREATE TABLE IF NOT EXISTS usuarios (
                        id INTEGER PRIMARY KEY,
                        nombre TEXT NOT NULL,
                        apellido TEXT NOT NULL,
                        registro TEXT NOT NULL,
                        contraseña_hash TEXT NOT NULL)''')
    conn.commit()
    conn.close()

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    nombre = data['nombre']
    apellido = data['apellido']
    registro = data['registro']
    contraseña = data['contraseña']
    contraseña_hash = generate_password_hash(contraseña)
    
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute('INSERT INTO usuarios (nombre, apellido, registro, contraseña_hash) VALUES (?, ?, ?, ?)',
                   (nombre, apellido, registro, contraseña_hash))
    conn.commit()
    conn.close()
    
    return jsonify({'message': 'Usuario registrado con éxito'})

@app.route('/validate', methods=['POST'])
def validate():
    data = request.get_json()
    nombre = data['nombre']
    apellido = data['apellido']
    registro = data['registro']
    contraseña = data['contraseña']
    
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute('SELECT contraseña_hash FROM usuarios WHERE nombre=? AND apellido=? AND registro=?',
                   (nombre, apellido, registro))
    user = cursor.fetchone()
    conn.close()
    
    if user and check_password_hash(user[0], contraseña):
        return jsonify({'message': 'Validación exitosa'})
    else:
        return jsonify({'message': 'Validación fallida'})

if __name__ == '__main__':
    init_db()
    app.run(port=8500)
