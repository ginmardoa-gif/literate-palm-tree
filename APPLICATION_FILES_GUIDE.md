# GPS Tracker - Application Files Guide

This document contains all the application files needed to complete your GPS Tracker setup. Follow the instructions in order.

---

## Table of Contents

1. [Backend Files](#backend-files)
2. [Frontend Files](#frontend-files)
3. [Mobile Files](#mobile-files)
4. [File Creation Order](#file-creation-order)

---

## Backend Files

### Directory: ~/gps-tracker-app/backend/

#### File 1: requirements.txt

```bash
nano ~/gps-tracker-app/backend/requirements.txt
```

**Contents:**

```
Flask==2.3.3
Flask-CORS==4.0.0
Flask-Login==0.6.2
Flask-Bcrypt==1.0.1
Flask-SQLAlchemy==3.0.5
psycopg2-binary==2.9.7
python-dotenv==1.0.0
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 2: Dockerfile

```bash
nano ~/gps-tracker-app/backend/Dockerfile
```

**Contents:**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Run application
CMD ["python", "-m", "flask", "--app", "app.main:app", "run", "--host", "0.0.0.0"]
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 3: app/__init__.py

```bash
mkdir -p ~/gps-tracker-app/backend/app
nano ~/gps-tracker-app/backend/app/__init__.py
```

**Contents:**

```python
# Empty file - marks this directory as a Python package
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 4: app/config.py

```bash
nano ~/gps-tracker-app/backend/app/config.py
```

**Contents:**

```python
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Database
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Security
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key')
    
    # Session Configuration
    FLASK_ENV = os.getenv('FLASK_ENV', 'development')
    SESSION_COOKIE_SECURE = os.getenv('FLASK_ENV') == 'production'
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'None' if os.getenv('FLASK_ENV') == 'production' else 'Lax'
    PERMANENT_SESSION_LIFETIME = 86400  # 24 hours
    
    # CORS
    CORS_ORIGINS = os.getenv('CORS_ORIGINS', 'http://localhost:3000')
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 5: app/models.py

```bash
nano ~/gps-tracker-app/backend/app/models.py
```

**Contents:**

```python
from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from datetime import datetime

db = SQLAlchemy()

class User(UserMixin, db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), default='viewer')
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<User {self.username}>'

class Vehicle(db.Model):
    __tablename__ = 'vehicles'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    device_id = db.Column(db.String(100), unique=True, nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    locations = db.relationship('Location', backref='vehicle', lazy=True, cascade='all, delete-orphan')
    saved_locations = db.relationship('SavedLocation', backref='vehicle', lazy=True, cascade='all, delete-orphan')
    
    def __repr__(self):
        return f'<Vehicle {self.name}>'

class Location(db.Model):
    __tablename__ = 'locations'
    
    id = db.Column(db.Integer, primary_key=True)
    vehicle_id = db.Column(db.Integer, db.ForeignKey('vehicles.id'), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    speed = db.Column(db.Float, default=0.0)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow, index=True)
    
    def __repr__(self):
        return f'<Location {self.id} for Vehicle {self.vehicle_id}>'

class SavedLocation(db.Model):
    __tablename__ = 'saved_locations'
    
    id = db.Column(db.Integer, primary_key=True)
    vehicle_id = db.Column(db.Integer, db.ForeignKey('vehicles.id'), nullable=False)
    name = db.Column(db.String(200), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    stop_duration_minutes = db.Column(db.Integer)
    visit_type = db.Column(db.String(50), default='manual')
    notes = db.Column(db.Text)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<SavedLocation {self.name}>'

class PlaceOfInterest(db.Model):
    __tablename__ = 'places_of_interest'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    address = db.Column(db.String(500))
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    category = db.Column(db.String(100), default='General')
    description = db.Column(db.Text)
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    creator = db.relationship('User', backref='places')
    
    def __repr__(self):
        return f'<PlaceOfInterest {self.name}>'
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 6: app/main.py

**Note:** This file is large. Create it carefully.

```bash
nano ~/gps-tracker-app/backend/app/main.py
```

**Contents:** See the backend_app_main.py file from earlier in the conversation. Copy all the content but with the CORS section updated to:

```python
import os

# Get CORS origins from environment variable
cors_origins = os.getenv('CORS_ORIGINS', 'http://localhost:3000').split(',')

CORS(app, 
     supports_credentials=True, 
     origins=cors_origins,
     allow_headers=['Content-Type', 'Authorization'],
     methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

## Frontend Files

### Directory: ~/gps-tracker-app/frontend/

**Note:** The frontend is a complete React application. For brevity, we'll provide the essential Dockerfile and a note about the application.

#### File 1: Dockerfile

```bash
nano ~/gps-tracker-app/frontend/Dockerfile
```

**Contents:**

```dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build application
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built files
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 2: nginx.conf

```bash
nano ~/gps-tracker-app/frontend/nginx.conf
```

**Contents:**

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:5000;
    }
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 3: package.json

```bash
nano ~/gps-tracker-app/frontend/package.json
```

**Contents:**

```json
{
  "name": "gps-tracker-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.14.0",
    "leaflet": "^1.9.4",
    "react-leaflet": "^4.2.1",
    "axios": "^1.4.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.15",
    "@types/react-dom": "^18.2.7",
    "@vitejs/plugin-react": "^4.0.3",
    "vite": "^4.4.5"
  }
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 4: vite.config.js

```bash
nano ~/gps-tracker-app/frontend/vite.config.js
```

**Contents:**

```javascript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: true
  }
})
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 5: index.html

```bash
nano ~/gps-tracker-app/frontend/index.html
```

**Contents:**

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>GPS Tracker</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 6: src/main.jsx

```bash
mkdir -p ~/gps-tracker-app/frontend/src
nano ~/gps-tracker-app/frontend/src/main.jsx
```

**Contents:**

```javascript
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 7: src/App.jsx

```bash
nano ~/gps-tracker-app/frontend/src/App.jsx
```

**Contents:**

```javascript
import { useState, useEffect } from 'react'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || '/api'

axios.defaults.baseURL = API_URL
axios.defaults.withCredentials = true

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    checkAuth()
  }, [])

  const checkAuth = async () => {
    try {
      const response = await axios.get('/auth/check')
      setIsAuthenticated(response.data.authenticated)
    } catch (error) {
      setIsAuthenticated(false)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return <div>Loading...</div>
  }

  return (
    <BrowserRouter>
      <Routes>
        <Route 
          path="/login" 
          element={
            isAuthenticated ? <Navigate to="/" /> : <Login onLogin={() => setIsAuthenticated(true)} />
          } 
        />
        <Route 
          path="/" 
          element={
            isAuthenticated ? <Dashboard onLogout={() => setIsAuthenticated(false)} /> : <Navigate to="/login" />
          } 
        />
      </Routes>
    </BrowserRouter>
  )
}

export default App
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 8: src/index.css

```bash
nano ~/gps-tracker-app/frontend/src/index.css
```

**Contents:**

```css
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#root {
  height: 100vh;
  width: 100vw;
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 9: src/pages/Login.jsx

```bash
mkdir -p ~/gps-tracker-app/frontend/src/pages
nano ~/gps-tracker-app/frontend/src/pages/Login.jsx
```

**Contents:**

```javascript
import { useState } from 'react'
import axios from 'axios'
import './Login.css'

function Login({ onLogin }) {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')

    try {
      await axios.post('/auth/login', { username, password })
      onLogin()
    } catch (err) {
      setError(err.response?.data?.error || 'Network error. Please try again.')
    }
  }

  return (
    <div className="login-container">
      <div className="login-card">
        <h1>📍 GPS Tracker</h1>
        <p>Sign in to your account</p>
        
        {error && <div className="error">{error}</div>}
        
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Username</label>
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="admin"
              required
            />
          </div>
          
          <div className="form-group">
            <label>Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              required
            />
          </div>
          
          <button type="submit">Sign In</button>
        </form>
        
        <div className="default-login">
          <p>Default Login:</p>
          <p>Username: <strong>admin</strong></p>
          <p>Password: <strong>admin123</strong></p>
        </div>
      </div>
    </div>
  )
}

export default Login
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 10: src/pages/Login.css

```bash
nano ~/gps-tracker-app/frontend/src/pages/Login.css
```

**Contents:**

```css
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-card {
  background: white;
  padding: 40px;
  border-radius: 20px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 400px;
}

.login-card h1 {
  text-align: center;
  margin-bottom: 10px;
  font-size: 28px;
  color: #333;
}

.login-card > p {
  text-align: center;
  margin-bottom: 30px;
  color: #666;
}

.error {
  background: #fee;
  color: #c33;
  padding: 10px;
  border-radius: 5px;
  margin-bottom: 20px;
  text-align: center;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #333;
}

.form-group input {
  width: 100%;
  padding: 12px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 16px;
}

.form-group input:focus {
  outline: none;
  border-color: #667eea;
}

button[type="submit"] {
  width: 100%;
  padding: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s;
}

button[type="submit"]:hover {
  transform: translateY(-2px);
}

.default-login {
  margin-top: 30px;
  padding: 15px;
  background: #f5f5f5;
  border-radius: 8px;
  text-align: center;
  font-size: 14px;
}

.default-login p {
  margin: 5px 0;
  color: #666;
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 11: src/pages/Dashboard.jsx

```bash
nano ~/gps-tracker-app/frontend/src/pages/Dashboard.jsx
```

**Contents:**

```javascript
import { useState, useEffect } from 'react'
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import axios from 'axios'
import 'leaflet/dist/leaflet.css'
import './Dashboard.css'

function Dashboard({ onLogout }) {
  const [vehicles, setVehicles] = useState([])
  const [selectedVehicle, setSelectedVehicle] = useState(null)
  const [location, setLocation] = useState(null)

  useEffect(() => {
    fetchVehicles()
  }, [])

  useEffect(() => {
    if (selectedVehicle) {
      fetchLocation()
      const interval = setInterval(fetchLocation, 10000)
      return () => clearInterval(interval)
    }
  }, [selectedVehicle])

  const fetchVehicles = async () => {
    try {
      const response = await axios.get('/vehicles')
      setVehicles(response.data)
      if (response.data.length > 0) {
        setSelectedVehicle(response.data[0].id)
      }
    } catch (error) {
      console.error('Failed to fetch vehicles:', error)
    }
  }

  const fetchLocation = async () => {
    if (!selectedVehicle) return
    try {
      const response = await axios.get(`/vehicles/${selectedVehicle}/location`)
      setLocation(response.data)
    } catch (error) {
      console.error('Failed to fetch location:', error)
    }
  }

  const handleLogout = async () => {
    try {
      await axios.post('/auth/logout')
      onLogout()
    } catch (error) {
      console.error('Logout failed:', error)
    }
  }

  const center = location ? [location.latitude, location.longitude] : [5.8520, -55.2038]

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <h1>📍 GPS Tracker Dashboard</h1>
        <div className="header-actions">
          <select 
            value={selectedVehicle || ''} 
            onChange={(e) => setSelectedVehicle(Number(e.target.value))}
            className="vehicle-select"
          >
            {vehicles.map(v => (
              <option key={v.id} value={v.id}>{v.name}</option>
            ))}
          </select>
          <button onClick={handleLogout} className="logout-btn">Logout</button>
        </div>
      </header>

      <div className="dashboard-content">
        <div className="map-container">
          <MapContainer center={center} zoom={13} style={{ height: '100%', width: '100%' }}>
            <TileLayer
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            />
            {location && (
              <Marker position={[location.latitude, location.longitude]}>
                <Popup>
                  <strong>Current Location</strong><br />
                  Speed: {location.speed} km/h<br />
                  Updated: {new Date(location.timestamp).toLocaleString()}
                </Popup>
              </Marker>
            )}
          </MapContainer>
        </div>

        {location && (
          <div className="info-panel">
            <h3>Vehicle Information</h3>
            <p><strong>Latitude:</strong> {location.latitude.toFixed(6)}</p>
            <p><strong>Longitude:</strong> {location.longitude.toFixed(6)}</p>
            <p><strong>Speed:</strong> {location.speed} km/h</p>
            <p><strong>Last Update:</strong> {new Date(location.timestamp).toLocaleString()}</p>
          </div>
        )}
      </div>
    </div>
  )
}

export default Dashboard
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

#### File 12: src/pages/Dashboard.css

```bash
nano ~/gps-tracker-app/frontend/src/pages/Dashboard.css
```

**Contents:**

```css
.dashboard {
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.dashboard-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.dashboard-header h1 {
  margin: 0;
  font-size: 24px;
}

.header-actions {
  display: flex;
  gap: 15px;
  align-items: center;
}

.vehicle-select {
  padding: 8px 15px;
  border: none;
  border-radius: 5px;
  font-size: 14px;
  cursor: pointer;
}

.logout-btn {
  padding: 8px 20px;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid white;
  border-radius: 5px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.logout-btn:hover {
  background: white;
  color: #667eea;
}

.dashboard-content {
  flex: 1;
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 0;
  overflow: hidden;
}

.map-container {
  height: 100%;
  width: 100%;
}

.info-panel {
  padding: 20px;
  background: #f5f5f5;
  overflow-y: auto;
}

.info-panel h3 {
  margin-top: 0;
  margin-bottom: 20px;
  color: #333;
}

.info-panel p {
  margin: 10px 0;
  color: #666;
}

@media (max-width: 768px) {
  .dashboard-content {
    grid-template-columns: 1fr;
    grid-template-rows: 1fr auto;
  }
  
  .info-panel {
    max-height: 200px;
  }
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

## Mobile Files

### Directory: ~/gps-tracker-app/mobile/

#### File 1: index.html

```bash
nano ~/gps-tracker-app/mobile/index.html
```

**Contents:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>GPS Tracker - Mobile</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
            color: white;
        }

        .container {
            max-width: 500px;
            margin: 0 auto;
        }

        .card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 20px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            color: #333;
        }

        h1 {
            text-align: center;
            margin-bottom: 10px;
            font-size: 28px;
        }

        .subtitle {
            text-align: center;
            opacity: 0.9;
            margin-bottom: 30px;
            font-size: 14px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }

        input, select {
            width: 100%;
            padding: 12px;
            margin-bottom: 20px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 16px;
        }

        button {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-bottom: 10px;
            transition: transform 0.2s;
        }

        button:hover {
            transform: translateY(-2px);
        }

        .btn-start {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-stop {
            background: #f44336;
            color: white;
        }

        .btn-save {
            background: #ff9800;
            color: white;
        }

        .status {
            padding: 15px;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 20px;
            font-weight: 500;
        }

        .status-success {
            background: #d4edda;
            color: #155724;
        }

        .status-error {
            background: #f8d7da;
            color: #721c24;
        }

        .status-info {
            background: #d1ecf1;
            color: #0c5460;
        }

        .stats {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-top: 20px;
        }

        .stat {
            text-align: center;
        }

        .stat-label {
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
        }

        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #667eea;
        }

        .info {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 8px;
            margin-top: 20px;
        }

        .info p {
            margin: 5px 0;
            font-size: 14px;
            color: #666;
        }

        .info strong {
            color: #667eea;
        }

        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📍 GPS Tracker</h1>
        <p class="subtitle">Mobile Location Sender</p>

        <div class="card">
            <label for="serverUrl">Server URL</label>
            <input type="text" id="serverUrl" placeholder="https://gps.yourdomain.com">

            <label for="vehicleSelect">Select Vehicle</label>
            <select id="vehicleSelect">
                <option value="">-- Choose Vehicle --</option>
            </select>

            <label for="updateInterval">Update Interval</label>
            <select id="updateInterval">
                <option value="5000">Every 5 seconds</option>
                <option value="10000" selected>Every 10 seconds</option>
                <option value="30000">Every 30 seconds</option>
                <option value="60000">Every 1 minute</option>
            </select>

            <button id="startBtn" class="btn-start">Start Tracking</button>
            <button id="stopBtn" class="btn-stop hidden">Stop Tracking</button>
            <button id="saveBtn" class="btn-save">📌 Save Current Location</button>

            <div id="status" class="status hidden"></div>

            <div class="stats">
                <div class="stat">
                    <div class="stat-label">Updates Sent</div>
                    <div class="stat-value" id="updateCount">0</div>
                </div>
                <div class="stat">
                    <div class="stat-label">Current Speed</div>
                    <div class="stat-value" id="currentSpeed">0.0</div>
                </div>
            </div>

            <div class="info">
                <p><strong>Latitude:</strong> <span id="latitude">--</span></p>
                <p><strong>Longitude:</strong> <span id="longitude">--</span></p>
                <p><strong>Accuracy:</strong> <span id="accuracy">--m</span></p>
                <p><strong>Last Update:</strong> <span id="lastUpdate">--</span></p>
            </div>
        </div>
    </div>

    <script>
        const serverUrlInput = document.getElementById('serverUrl');
        const vehicleSelect = document.getElementById('vehicleSelect');
        const updateIntervalSelect = document.getElementById('updateInterval');
        const startBtn = document.getElementById('startBtn');
        const stopBtn = document.getElementById('stopBtn');
        const saveBtn = document.getElementById('saveBtn');
        const statusDiv = document.getElementById('status');
        const updateCountSpan = document.getElementById('updateCount');
        const currentSpeedSpan = document.getElementById('currentSpeed');
        const latitudeSpan = document.getElementById('latitude');
        const longitudeSpan = document.getElementById('longitude');
        const accuracySpan = document.getElementById('accuracy');
        const lastUpdateSpan = document.getElementById('lastUpdate');

        let trackingInterval = null;
        let updateCount = 0;
        let watchId = null;
        let currentPosition = null;

        // Set default server URL
        serverUrlInput.value = `https://${window.location.hostname}`;

        // Load vehicles on page load
        window.addEventListener('DOMContentLoaded', loadVehicles);

        async function loadVehicles() {
            const serverUrl = serverUrlInput.value.trim();
            if (!serverUrl) {
                showStatus('Please enter server URL', 'error');
                return;
            }

            try {
                const response = await fetch(`${serverUrl}/api/vehicles`, {
                    credentials: 'include'
                });

                if (!response.ok) {
                    showStatus('GPS ready', 'info');
                    return;
                }

                const vehicles = await response.json();
                vehicleSelect.innerHTML = '<option value="">-- Choose Vehicle --</option>';
                
                vehicles.forEach(vehicle => {
                    const option = document.createElement('option');
                    option.value = vehicle.device_id;
                    option.textContent = vehicle.name;
                    vehicleSelect.appendChild(option);
                });

                showStatus('GPS ready', 'info');
            } catch (error) {
                console.error('Failed to load vehicles:', error);
                showStatus('GPS ready', 'info');
            }
        }

        startBtn.addEventListener('click', startTracking);
        stopBtn.addEventListener('click', stopTracking);
        saveBtn.addEventListener('click', saveLocation);

        function startTracking() {
            const serverUrl = serverUrlInput.value.trim();
            const deviceId = vehicleSelect.value;

            if (!serverUrl) {
                showStatus('Please enter server URL', 'error');
                return;
            }

            if (!deviceId) {
                showStatus('Please select a vehicle', 'error');
                return;
            }

            if (!navigator.geolocation) {
                showStatus('Geolocation not supported', 'error');
                return;
            }

            // Start watching position
            watchId = navigator.geolocation.watchPosition(
                (position) => {
                    currentPosition = position;
                    updateDisplay(position);
                },
                (error) => {
                    showStatus(`Location error: ${error.message}`, 'error');
                },
                {
                    enableHighAccuracy: true,
                    timeout: 5000,
                    maximumAge: 0
                }
            );

            // Send updates at interval
            const interval = parseInt(updateIntervalSelect.value);
            trackingInterval = setInterval(() => {
                if (currentPosition) {
                    sendLocation(serverUrl, deviceId, currentPosition);
                }
            }, interval);

            startBtn.classList.add('hidden');
            stopBtn.classList.remove('hidden');
            serverUrlInput.disabled = true;
            vehicleSelect.disabled = true;
            updateIntervalSelect.disabled = true;

            showStatus('Tracking started...', 'info');
        }

        function stopTracking() {
            if (watchId) {
                navigator.geolocation.clearWatch(watchId);
                watchId = null;
            }

            if (trackingInterval) {
                clearInterval(trackingInterval);
                trackingInterval = null;
            }

            startBtn.classList.remove('hidden');
            stopBtn.classList.add('hidden');
            serverUrlInput.disabled = false;
            vehicleSelect.disabled = false;
            updateIntervalSelect.disabled = false;

            showStatus('Tracking stopped', 'info');
        }

        async function sendLocation(serverUrl, deviceId, position) {
            const data = {
                device_id: deviceId,
                latitude: position.coords.latitude,
                longitude: position.coords.longitude,
                speed: position.coords.speed || 0
            };

            try {
                const response = await fetch(`${serverUrl}/api/gps`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(data)
                });

                if (response.ok) {
                    updateCount++;
                    updateCountSpan.textContent = updateCount;
                    showStatus(`✓ Update #${updateCount} sent successfully`, 'success');
                } else {
                    const error = await response.json();
                    showStatus(`Error: ${error.error || 'Failed to send'}`, 'error');
                }
            } catch (error) {
                showStatus('Failed to send data. Check connection.', 'error');
                console.error('Send error:', error);
            }
        }

        async function saveLocation() {
            if (!currentPosition) {
                showStatus('No location available. Start tracking first.', 'error');
                return;
            }

            const serverUrl = serverUrlInput.value.trim();
            const deviceId = vehicleSelect.value;

            if (!serverUrl || !deviceId) {
                showStatus('Please configure server and vehicle', 'error');
                return;
            }

            // Get vehicle ID from device_id
            try {
                const vehiclesResponse = await fetch(`${serverUrl}/api/vehicles`, {
                    credentials: 'include'
                });
                
                if (!vehiclesResponse.ok) {
                    showStatus('Failed to save location', 'error');
                    return;
                }

                const vehicles = await vehiclesResponse.json();
                const vehicle = vehicles.find(v => v.device_id === deviceId);

                if (!vehicle) {
                    showStatus('Vehicle not found', 'error');
                    return;
                }

                const data = {
                    latitude: currentPosition.coords.latitude,
                    longitude: currentPosition.coords.longitude,
                    name: `Location ${new Date().toLocaleString()}`,
                    notes: 'Saved from mobile'
                };

                const response = await fetch(`${serverUrl}/api/vehicles/${vehicle.id}/saved-locations`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    credentials: 'include',
                    body: JSON.stringify(data)
                });

                if (response.ok) {
                    showStatus('📌 Location saved!', 'success');
                } else {
                    showStatus('Failed to save location', 'error');
                }
            } catch (error) {
                showStatus('Error saving location', 'error');
                console.error('Save error:', error);
            }
        }

        function updateDisplay(position) {
            latitudeSpan.textContent = position.coords.latitude.toFixed(6);
            longitudeSpan.textContent = position.coords.longitude.toFixed(6);
            accuracySpan.textContent = `${position.coords.accuracy.toFixed(1)}m`;
            
            const speed = position.coords.speed || 0;
            currentSpeedSpan.textContent = (speed * 3.6).toFixed(1); // Convert m/s to km/h
            
            const now = new Date();
            lastUpdateSpan.textContent = now.toLocaleTimeString();
        }

        function showStatus(message, type) {
            statusDiv.textContent = message;
            statusDiv.className = `status status-${type}`;
            statusDiv.classList.remove('hidden');
        }
    </script>
</body>
</html>
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

## File Creation Order

Follow this order to set up all files:

### Step 1: Backend Files (in order)

```bash
cd ~/gps-tracker-app

# Create backend structure
mkdir -p backend/app

# Create files
nano backend/requirements.txt       # Copy content from above
nano backend/Dockerfile             # Copy content from above
nano backend/app/__init__.py        # Empty file
nano backend/app/config.py          # Copy content from above
nano backend/app/models.py          # Copy content from above
nano backend/app/main.py            # Copy content from document above
```

### Step 2: Frontend Files (in order)

```bash
cd ~/gps-tracker-app

# Create frontend structure
mkdir -p frontend/src/pages

# Create files
nano frontend/Dockerfile            # Copy content from above
nano frontend/nginx.conf            # Copy content from above
nano frontend/package.json          # Copy content from above
nano frontend/vite.config.js        # Copy content from above
nano frontend/index.html            # Copy content from above
nano frontend/src/main.jsx          # Copy content from above
nano frontend/src/App.jsx           # Copy content from above
nano frontend/src/index.css         # Copy content from above
nano frontend/src/pages/Login.jsx   # Copy content from above
nano frontend/src/pages/Login.css   # Copy content from above
nano frontend/src/pages/Dashboard.jsx   # Copy content from above
nano frontend/src/pages/Dashboard.css   # Copy content from above
```

### Step 3: Mobile Files

```bash
cd ~/gps-tracker-app

# Create mobile directory
mkdir -p mobile

# Create file
nano mobile/index.html              # Copy content from above
```

### Step 4: Verify File Structure

```bash
cd ~/gps-tracker-app
tree -L 3
```

**Expected output:**

```
.
├── backend
│   ├── Dockerfile
│   ├── app
│   │   ├── __init__.py
│   │   ├── config.py
│   │   ├── main.py
│   │   └── models.py
│   └── requirements.txt
├── database
├── docker-compose.yml
├── .env
├── frontend
│   ├── Dockerfile
│   ├── index.html
│   ├── nginx.conf
│   ├── package.json
│   ├── src
│   │   ├── App.jsx
│   │   ├── index.css
│   │   ├── main.jsx
│   │   └── pages
│   └── vite.config.js
└── mobile
    └── index.html
```

### Step 5: Build and Deploy

```bash
cd ~/gps-tracker-app

# Build containers
docker compose build --no-cache

# Start services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

---

## Verification Checklist

After creating all files:

- [ ] All backend files created in `~/gps-tracker-app/backend/`
- [ ] All frontend files created in `~/gps-tracker-app/frontend/`
- [ ] Mobile file created in `~/gps-tracker-app/mobile/`
- [ ] `.env` file exists with correct values
- [ ] `docker-compose.yml` file exists
- [ ] Nginx configuration exists at `/etc/nginx/sites-available/gps-tracker`
- [ ] SSL certificate obtained
- [ ] All containers running: `docker compose ps`
- [ ] Can access dashboard: `https://YOUR_DOMAIN`
- [ ] Can access mobile: `https://YOUR_DOMAIN/mobile`
- [ ] Can login with admin/admin123
- [ ] GPS tracking works

---

## Quick Create Script (Optional)

If you want to automate file creation, save this as `~/create-files.sh`:

```bash
#!/bin/bash

echo "This script helps create the file structure."
echo "You'll still need to paste the content into each file manually."
echo ""

cd ~/gps-tracker-app

# Backend
mkdir -p backend/app
touch backend/requirements.txt
touch backend/Dockerfile
touch backend/app/__init__.py
touch backend/app/config.py
touch backend/app/models.py
touch backend/app/main.py

# Frontend
mkdir -p frontend/src/pages
touch frontend/Dockerfile
touch frontend/nginx.conf
touch frontend/package.json
touch frontend/vite.config.js
touch frontend/index.html
touch frontend/src/main.jsx
touch frontend/src/App.jsx
touch frontend/src/index.css
touch frontend/src/pages/Login.jsx
touch frontend/src/pages/Login.css
touch frontend/src/pages/Dashboard.jsx
touch frontend/src/pages/Dashboard.css

# Mobile
mkdir -p mobile
touch mobile/index.html

echo "✓ File structure created!"
echo "Now edit each file with nano and paste the content."
echo ""
echo "Example: nano backend/requirements.txt"
```

**Make executable and run:**

```bash
chmod +x ~/create-files.sh
~/create-files.sh
```

---

## Troubleshooting File Issues

### Issue: "File not found" errors

**Solution:**
```bash
# Verify you're in the correct directory
cd ~/gps-tracker-app
pwd

# List all files
find . -type f
```

### Issue: Docker build fails

**Solution:**
```bash
# Check if all required files exist
ls -la backend/
ls -la frontend/
ls -la mobile/

# View build logs
docker compose build 2>&1 | tee build.log
```

### Issue: Syntax errors in files

**Solution:**
- Double-check quotes, brackets, and commas
- Ensure no extra spaces or line breaks
- Compare with original content

---

## Summary

You now have all the files needed for:

✅ **Backend** - Flask API with PostgreSQL  
✅ **Frontend** - React dashboard with Leaflet maps  
✅ **Mobile** - HTML/JavaScript GPS sender  

**Next steps:**

1. Create all files as shown above
2. Build containers: `docker compose build`
3. Start services: `docker compose up -d`
4. Access your application!

---

*Document Version: 1.0*  
*Companion to: GPS Tracker Installation Manual*
