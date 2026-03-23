# Aide - Comprehensive Student & Essential Services Platform

**Aide** (formerly EduCare Connect) is a modern, high-performance platform designed to bridge the gap between students, parents, and essential local services. It provides a unified ecosystem for education, accommodation, and medical support, enhanced by real-time location-based searching.

This repository contains the **FastAPI-based Backend** that powers the **Aide Flutter Mobile Application**.

---

## 🚀 Key Features

### 🔐 1. Secure Authentication & Identity
- **JWT-Based Auth**: Secure login and registration with Access and Refresh token rotation.
- **Email Verification**: Mandatory account verification via **Mailgun SMTP** to ensure user authenticity.
- **Password Recovery**: Automated "Forgot Password" flow with secure reset tokens.
- **RBAC**: Multi-role system (Admin, Student) with granular permissions.

### 🎓 2. Education Hub
- **Database of Institutes**: Detailed listings for Colleges, Schools, and Coaching Classes.
- **Mess Services**: Integrated directory for student meal providers.
- **Advanced Filtering**: Sort by type (Government/Private), board (CBSE/ICSE), and more.

### 🏠 3. Stay & Accommodation
- **Hostels & PGs**: Comprehensive listings for student stays.
- **Smart Filters**: Filter by gender (Boys/Girls/Co-ed), rent, deposit, and specific amenities (AC/Wi-Fi).

### 🏥 4. Medical Emergency & Healthcare
- **Emergency Directory**: Quick access to Hospitals and Ambulance providers.
- **Blood Bank Tracker**: Real-time availability tracking for specific blood groups (A+, O-, etc.).
- **Doctor Directory**: Search for specialists across various hospitals.

### 📍 5. Geographic Intelligence
- **Nearby Search**: High-precision location-based search using the **Haversine Formula**.
- **Proximity Sorting**: All services (Education, Stay, Medical) can be sorted by real-time distance from the user.

---

## 🛠️ Technical Stack

### **Backend (FastAPI)**
- **Framework**: [FastAPI](https://fastapi.tiangolo.com/) (Python 3.11+)
- **Database**: **PostgreSQL** (Production-grade relational database)
- **ORM**: [SQLAlchemy](https://www.sqlalchemy.org/)
- **Migrations**: [Alembic](https://alembic.sqlalchemy.org/)
- **Validation**: [Pydantic v2](https://docs.pydantic.dev/) for strict type safety.
- **Email**: **Mailgun SMTP Integration** via `smtplib`.
- **Auth**: JWT with `python-jose` and Password hashing with `bcrypt`.

### **Frontend (Mobile)**
- **Framework**: **Flutter** (Cross-platform mobile application)
- **Primary Platform**: Android & iOS
- **Integration**: RESTful API communication with the FastAPI backend.

---

## 🏁 Getting Started

### 1. Prerequisites
- Python 3.11+
- **PostgreSQL** installed and running
- A Mailgun (or any SMTP) account for email features.

### 2. Backend Installation
```bash
# Navigate to the backend directory
cd backend

# Create and activate a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Environment Setup
Create a `.env` file in the `backend/` directory:
```env
DATABASE_URL=postgresql+psycopg2://user:password@localhost:5432/aide_db
SECRET_KEY=your_secure_random_key_here
ALGORITHM=HS256

# SMTP Configuration
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_USER=your_user@domain.com
SMTP_PASSWORD=your_password
SMTP_FROM_EMAIL=noreply@aide.com
SMTP_FROM_NAME="Aide Support"

# App Settings
SSO_BACKEND_PUBLIC_URL=http://localhost:8000
```

### 4. Database Initialization
```bash
# Apply migrations to create the schema
alembic upgrade head

# Create the initial Admin user
python scripts/init_db.py
```

### 5. Run the Server
```bash
uvicorn app.main:app --reload --port 8000
```
- **Swagger Documentation**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **ReDoc Documentation**: [http://localhost:8000/redoc](http://localhost:8000/redoc)

---

## 📍 Location Search Specs
The backend calculates geographic proximity in kilometers.
- **Param `lat`**: User's current latitude.
- **Param `lon`**: User's current longitude.
- **Param `radius`**: Maximum search radius (e.g., `10.0`).

## 🛡️ License
This project is for educational and service-oriented purposes. All rights reserved by the development team.
