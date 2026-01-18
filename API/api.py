from flask import Flask, request, jsonify, abort
from flask_sqlalchemy import SQLAlchemy
from functools import wraps
import db_config

app = Flask(__name__)

# Configure Database
app.config['SQLALCHEMY_DATABASE_URI'] = db_config.get_database_uri()
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Authentication
def require_api_key(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if request.headers.get('x-api-key') and request.headers.get('x-api-key') == db_config.API_KEY:
            return f(*args, **kwargs)
        else:
            abort(401, description="Invalid or missing API key")
    return decorated_function

# Models
class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(15), nullable=False)
    email = db.Column(db.String(100))
    passwordhash = db.Column(db.LargeBinary(64), nullable=False)
    dateofbirth = db.Column(db.Date, nullable=False)
    phonenumber = db.Column(db.String(20))

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'dateofbirth': str(self.dateofbirth),
            'phonenumber': self.phonenumber
        }

class UserHobbies(db.Model):
    __tablename__ = 'user_hobbies'
    id = db.Column(db.Integer, primary_key=True)
    userid = db.Column(db.Integer, db.ForeignKey('user.id'))
    hobby1 = db.Column(db.Integer)
    hobby2 = db.Column(db.Integer)
    hobby3 = db.Column(db.Integer)
    hobby4 = db.Column(db.Integer)
    hobby5 = db.Column(db.Integer)

    def to_dict(self):
        return {
            'hobby1': self.hobby1, 'hobby2': self.hobby2,
            'hobby3': self.hobby3, 'hobby4': self.hobby4,
            'hobby5': self.hobby5
        }

class UserPhotos(db.Model):
    __tablename__ = 'user_photos'
    id = db.Column(db.Integer, primary_key=True)
    userid = db.Column(db.Integer, db.ForeignKey('user.id'))
    photo1 = db.Column(db.String(255), nullable=False)
    photo2 = db.Column(db.String(255))
    photo3 = db.Column(db.String(255))
    photo4 = db.Column(db.String(255))
    photo5 = db.Column(db.String(255))

    def to_dict(self):
        return {
            'photo1': self.photo1, 'photo2': self.photo2,
            'photo3': self.photo3, 'photo4': self.photo4,
            'photo5': self.photo5
        }

class UserPrefs(db.Model):
    __tablename__ = 'user_prefs'
    id = db.Column(db.Integer, primary_key=True)
    userid = db.Column(db.Integer, db.ForeignKey('user.id'))
    gender = db.Column(db.Integer)
    height = db.Column(db.Integer)
    genderinterest = db.Column(db.Integer)
    relationshipinterest = db.Column(db.Integer)
    is_smoke = db.Column(db.Boolean)
    is_drink = db.Column(db.Boolean)
    religion = db.Column(db.Integer)
    bio = db.Column(db.String(255))
    openingmove = db.Column(db.String(100))
    # Handling spatial POINT can be complex. 
    # For now we'll imply it is managed/inserted via raw API or added later. 
    # To fully support it, we'd need GeoAlchemy2.
    # We will exclude reading it directly here to simple JSON for now unless requested.

    def to_dict(self):
        return {
            'gender': self.gender, 'height': self.height,
            'genderinterest': self.genderinterest,
            'relationshipinterest': self.relationshipinterest,
            'is_smoke': self.is_smoke, 'is_drink': self.is_drink,
            'religion': self.religion, 'bio': self.bio,
            'openingmove': self.openingmove
        }

# Routes
@app.route("/users", methods=['GET'])
@require_api_key
def get_users():
    users = User.query.limit(20).all()
    return jsonify([u.to_dict() for u in users])

@app.route("/users/<int:user_id>", methods=['GET'])
@require_api_key
def get_user(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404
    
    # Optional: fetch related data
    hobbies = UserHobbies.query.filter_by(userid=user_id).first()
    photos = UserPhotos.query.filter_by(userid=user_id).first()
    prefs = UserPrefs.query.filter_by(userid=user_id).first()
    
    data = user.to_dict()
    if hobbies: data['hobbies'] = hobbies.to_dict()
    if photos: data['photos'] = photos.to_dict()
    if prefs: data['prefs'] = prefs.to_dict()
    
    return jsonify(data)

@app.route("/users", methods=['POST'])
@require_api_key
def create_user():
    data = request.json
    if not data:
        return jsonify({"error": "No input data provided"}), 400
    
    try:
        # 1. Create User
        import hashlib
        pwd_hash = b''
        if 'password' in data:
            pwd_hash = hashlib.sha512(data['password'].encode('utf-8')).digest()
        
        new_user = User(
            name=data.get('name'),
            email=data.get('email'),
            passwordhash=pwd_hash,
            dateofbirth=data.get('dateofbirth'), # Format YYYY-MM-DD
            phonenumber=data.get('phonenumber')
        )
        db.session.add(new_user)
        db.session.flush() # flush to get new_user.id
        
        # 2. Related data if provided
        if 'hobbies' in data:
            h = data['hobbies']
            new_hobbies = UserHobbies(
                userid=new_user.id,
                hobby1=h.get('hobby1'), hobby2=h.get('hobby2'),
                hobby3=h.get('hobby3'), hobby4=h.get('hobby4'),
                hobby5=h.get('hobby5')
            )
            db.session.add(new_hobbies)
            
        if 'photos' in data:
            p = data['photos']
            new_photos = UserPhotos(
                userid=new_user.id,
                photo1=p.get('photo1'), photo2=p.get('photo2'),
                photo3=p.get('photo3'), photo4=p.get('photo4'),
                photo5=p.get('photo5')
            )
            db.session.add(new_photos)
            
        if 'prefs' in data:
            pr = data['prefs']
            new_prefs = UserPrefs(
                userid=new_user.id,
                gender=pr.get('gender'),
                height=pr.get('height'),
                genderinterest=pr.get('genderinterest'),
                relationshipinterest=pr.get('relationshipinterest'),
                is_smoke=pr.get('is_smoke'),
                is_drink=pr.get('is_drink'),
                religion=pr.get('religion'),
                bio=pr.get('bio'),
                openingmove=pr.get('openingmove')
                # geolocation skipped for now
            )
            db.session.add(new_prefs)
        
        db.session.commit()
        return jsonify({"message": "User created", "user_id": new_user.id}), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)