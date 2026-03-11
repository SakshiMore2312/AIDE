# Import all models here to register with Base.metadata
from app.models.user import User
from app.models.notification import Notification
from app.models.organization import Organization
from app.models.education.colleges import College
from app.models.education.schools import School
from app.models.education.coaching import Coaching
from app.models.education.mess import Mess
from app.models.stay.hostels import Hostel
from app.models.stay.pg import PG
