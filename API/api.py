from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from functools import wraps
import os
import uuid
from werkzeug.utils import secure_filename
from PIL import Image
import pillow_heif
import logging
from sqlalchemy.sql import func
import db_config

# Register HEIF opener
pillow_heif.register_heif_opener()

app = Flask(__name__)

# Configure Database
app.config['SQLALCHEMY_DATABASE_URI'] = db_config.get_database_uri()
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Configure Upload Folder
# Configure Upload Folder
basedir = os.path.abspath(os.path.dirname(__file__))
UPLOAD_FOLDER = os.path.join(basedir, 'static', 'uploads')

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

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

@app.route("/upload", methods=['POST'])
@require_api_key
def upload_file():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
        
    if file:
        try:
            # Generate unique filename
            unique_id = str(uuid.uuid4())
            unique_filename = f"{unique_id}.jpg" # Always save as jpg
            final_path = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
            
            # Save incoming file to a temporary file first to ensure complete download
            # and avoid "image file is truncated" errors from Pillow
            import tempfile
            fd, temp_path = tempfile.mkstemp()
            os.close(fd)
            file.save(temp_path)
            
            # Open image using Pillow (handles HEIC via pillow_heif register_opener)
            img = Image.open(temp_path)
            img = img.convert("RGB") # Convert to RGB for JPEG compatibility
            
            # 1. Resize if too large (max 1920px max dimension)
            max_dimension = 1920
            if max(img.size) > max_dimension:
                ratio = max_dimension / max(img.size)
                new_size = (int(img.width * ratio), int(img.height * ratio))
                img = img.resize(new_size, Image.Resampling.LANCZOS)
            
            # 2. Compress loop to get under 100KB
            quality = 90
            target_size = 100 * 1024 # 100KB
            
            # Save initially
            img.save(final_path, "JPEG", quality=quality)
            
            # If initial save is too big, apply the 50% resize user permitted
            if os.path.getsize(final_path) > target_size:
                # Resize to 50%
                new_size = (int(img.width * 0.5), int(img.height * 0.5))
                img = img.resize(new_size, Image.Resampling.LANCZOS)
                # Reset quality for the loop
                quality = 90
                img.save(final_path, "JPEG", quality=quality)

            # Loop quality reduction if STILL too big
            while os.path.getsize(final_path) > target_size and quality > 30:
                quality -= 10
                img.save(final_path, "JPEG", quality=quality)
            
            return jsonify({"filename": unique_filename}), 201
            
        except Exception as e:
            if 'final_path' in locals() and os.path.exists(final_path):
                os.remove(final_path)
            return jsonify({"error": f"Image processing failed: {str(e)}"}), 500
        finally:
            # Clean up the temporary file
            if 'temp_path' in locals() and os.path.exists(temp_path):
                os.remove(temp_path)
        
    return jsonify({"error": "Upload failed"}), 500

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

class UserLike(db.Model):
    __tablename__ = 'user_like'
    id = db.Column(db.Integer, primary_key=True)
    userid = db.Column(db.Integer) # Target User
    wholikesid = db.Column(db.Integer) # Source User
    likedate = db.Column(db.Date) # Date of like

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
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    lastlogin = db.Column(db.DateTime)
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
            'openingmove': self.openingmove,
            'lastlogin': self.lastlogin.isoformat() if self.lastlogin else None,
            'latitude': self.latitude,
            'longitude': self.longitude
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
    
    
    if hobbies: data['hobbies'] = hobbies.to_dict()
    if photos: data['photos'] = photos.to_dict()
    if prefs: data['prefs'] = prefs.to_dict()
    
    return jsonify(data)

@app.route("/login", methods=['POST'])
@require_api_key
def login():
    data = request.json
    if not data or 'phonenumber' not in data or 'password' not in data:
        return jsonify({"error": "Missing phone number or password"}), 400
        
    phone = data['phonenumber']
    password = data['password']
    
    user = User.query.filter_by(phonenumber=phone).first()
    
    if user:
        import hashlib
        # Hash the provided password to compare with stored hash
        pwd_hash = hashlib.sha512(password.encode('utf-8')).digest()
        
        if pwd_hash == user.passwordhash:
             # Update Last Login
             from datetime import datetime
             prefs = UserPrefs.query.filter_by(userid=user.id).first()
             if prefs:
                 prefs.lastlogin = datetime.now()
             else:
                 prefs = UserPrefs(userid=user.id, lastlogin=datetime.now())
                 db.session.add(prefs)
             
             db.session.commit()

             return jsonify({
                "message": "Login successful", 
                "user": user.to_dict()
            }), 200
        else:
             return jsonify({"error": "Invalid password"}), 401
    else:
        return jsonify({"error": "User not found"}), 404

@app.route("/explore", methods=['GET'])
@require_api_key
def explore_users():
    current_user_id = request.args.get('current_user_id')
    if not current_user_id:
        return jsonify({"error": "Missing current_user_id"}), 400
    
    # Logic: Get users who I haven't liked yet, and exclude myself
    # Access: userid (Target), wholikesid (Me)
    
    # Subquery: Users I have already liked
    liked_subquery = db.session.query(UserLike.userid).filter(UserLike.wholikesid == current_user_id)
    
    # Query: Users NOT in subquery AND NOT me
    users = User.query.filter(
        User.id != current_user_id,
        ~User.id.in_(liked_subquery)
    ).order_by(func.random()).limit(30).all() # Limit to prevent overload
    
    results = []
    for user in users:
        # Construct full profile for card
        hobbies = UserHobbies.query.filter_by(userid=user.id).first()
        photos = UserPhotos.query.filter_by(userid=user.id).first()
        prefs = UserPrefs.query.filter_by(userid=user.id).first()
        
        u_dict = user.to_dict()
        if hobbies: u_dict['hobbies'] = hobbies.to_dict()
        if photos: u_dict['photos'] = photos.to_dict()
        if prefs: u_dict['prefs'] = prefs.to_dict()
        results.append(u_dict)
        
    return jsonify(results)

@app.route("/like", methods=['POST'])
@require_api_key
def like_user():
    data = request.json
    target_id = data.get('target_user_id')
    source_id = data.get('source_user_id')
    
    if not target_id or not source_id:
        return jsonify({"error": "Missing IDs"}), 400
        
    # Check if already liked
    existing = UserLike.query.filter_by(userid=target_id, wholikesid=source_id).first()
    if existing:
        return jsonify({"message": "Already liked"}), 200
        
    from datetime import date
    new_like = UserLike(userid=target_id, wholikesid=source_id, likedate=date.today())
    db.session.add(new_like)
    db.session.commit()
    
    return jsonify({"message": "Liked"}), 200

@app.route("/matches", methods=['GET'])
@require_api_key
def get_matches():
    current_user_id = request.args.get('current_user_id')
    if not current_user_id:
        return jsonify({"error": "Missing current_user_id"}), 400
        
    # 1. Liked Me (People who liked current_user)
    liked_me_ids = db.session.query(UserLike.wholikesid).filter(UserLike.userid == current_user_id).all()
    liked_me_ids = [i[0] for i in liked_me_ids]
    
    # 2. My Likes (People current_user liked)
    my_likes_ids = db.session.query(UserLike.userid).filter(UserLike.wholikesid == current_user_id).all()
    my_likes_ids = [i[0] for i in my_likes_ids]
    
    def fetch_users(user_ids):
        users = User.query.filter(User.id.in_(user_ids)).all()
        results = []
        for user in users:
             hobbies = UserHobbies.query.filter_by(userid=user.id).first()
             photos = UserPhotos.query.filter_by(userid=user.id).first()
             prefs = UserPrefs.query.filter_by(userid=user.id).first()
             
             u_dict = user.to_dict()
             if hobbies: u_dict['hobbies'] = hobbies.to_dict()
             if photos: u_dict['photos'] = photos.to_dict()
             if prefs: u_dict['prefs'] = prefs.to_dict()
             results.append(u_dict)
        return results

    return jsonify({
        "liked_me": fetch_users(liked_me_ids),
        "my_likes": fetch_users(my_likes_ids)
    })

@app.route("/delete_user", methods=['POST'])
@require_api_key
def delete_user():
    data = request.json
    user_id = data.get('user_id')
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400
        
    try:
        # Cascade Delete
        # 1. UserLike (where user is target OR source)
        UserLike.query.filter((UserLike.userid == user_id) | (UserLike.wholikesid == user_id)).delete()
        
        # 2. Related Tables
        UserPhotos.query.filter_by(userid=user_id).delete()
        UserHobbies.query.filter_by(userid=user_id).delete()
        UserPrefs.query.filter_by(userid=user_id).delete()
        
        # 3. User Table
        User.query.filter_by(id=user_id).delete()
        
        db.session.commit()
        return jsonify({"message": "User deleted successfully"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route("/change_password", methods=['POST'])
@require_api_key
def change_password():
    data = request.json
    if not data or 'user_id' not in data or 'old_password' not in data or 'new_password' not in data:
        return jsonify({"error": "Missing required fields"}), 400

    user_id = data['user_id']
    old_password = data['old_password']
    new_password = data['new_password']

    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404
        
    import hashlib
    # Verify old password
    old_pwd_hash = hashlib.sha512(old_password.encode('utf-8')).digest()
    if old_pwd_hash != user.passwordhash:
        return jsonify({"error": "Incorrect old password"}), 401
        
    # Set new password
    new_pwd_hash = hashlib.sha512(new_password.encode('utf-8')).digest()
    user.passwordhash = new_pwd_hash
    
    try:
        db.session.commit()
        return jsonify({"message": "Password changed successfully"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route('/uploads/<filename>')
def get_photo(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

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
            # Use raw SQL to insert UserPrefs with geolocation
            pr = data['prefs']
            lat = pr.get('latitude', 0.0)
            lon = pr.get('longitude', 0.0)
            
            sql = """
            INSERT INTO user_prefs (
                userid, gender, height, genderinterest, relationshipinterest, 
                is_smoke, is_drink, religion, bio, openingmove, geolocation,
                latitude, longitude
            ) VALUES (
                :userid, :gender, :height, :genderinterest, :relationshipinterest,
                :is_smoke, :is_drink, :religion, :bio, :openingmove,
                ST_GeomFromText(:pt, 4326),
                :latitude, :longitude
            )
            """
            
            pt_str = f'POINT({lon} {lat})'
            
            db.session.execute(db.text(sql), {
                'userid': new_user.id,
                'gender': pr.get('gender'),
                'height': pr.get('height'),
                'genderinterest': pr.get('genderinterest'),
                'relationshipinterest': pr.get('relationshipinterest'),
                'is_smoke': pr.get('is_smoke'),
                'is_drink': pr.get('is_drink'),
                'religion': pr.get('religion'),
                'bio': pr.get('bio'),
                'openingmove': pr.get('openingmove'),
                'pt': pt_str,
                'latitude': lat,
                'longitude': lon
            })
                
        
        db.session.commit()
        return jsonify({"message": "User created", "user_id": new_user.id}), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route("/users/<int:user_id>", methods=['PUT'])
@require_api_key
def update_user(user_id):
    try:
        data = request.get_json()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({"error": "User not found"}), 404

        # 1. Update User (Name, etc.)
        if 'name' in data:
            user.name = data['name']
        
        # 2. Update User Prefs
        if 'prefs' in data:
            user_prefs_data = data['prefs']
            prefs = UserPrefs.query.filter_by(userid=user_id).first()
            if not prefs:
                # Create if not exists (should theoretically exist)
                prefs = UserPrefs(userid=user_id)
                db.session.add(prefs)
            
            # Map fields
            if 'bio' in user_prefs_data: prefs.bio = user_prefs_data['bio']
            if 'openingmove' in user_prefs_data: prefs.openingmove = user_prefs_data['openingmove']
            if 'gender' in user_prefs_data: prefs.gender = user_prefs_data['gender']
            if 'height' in user_prefs_data: prefs.height = user_prefs_data['height']
            if 'genderinterest' in user_prefs_data: prefs.genderinterest = user_prefs_data['genderinterest']
            if 'relationshipinterest' in user_prefs_data: prefs.relationshipinterest = user_prefs_data['relationshipinterest']
            if 'religion' in user_prefs_data: prefs.religion = user_prefs_data['religion']
            if 'is_smoke' in user_prefs_data: prefs.is_smoke = user_prefs_data['is_smoke']
            if 'is_drink' in user_prefs_data: prefs.is_drink = user_prefs_data['is_drink']
            if 'latitude' in user_prefs_data: prefs.latitude = user_prefs_data['latitude']
            if 'longitude' in user_prefs_data: prefs.longitude = user_prefs_data['longitude']

        # 3. Update Photos
        if 'photos' in data:
            photos_data = data['photos']
            user_photos = UserPhotos.query.filter_by(userid=user_id).first()
            if not user_photos:
                user_photos = UserPhotos(userid=user_id)
                db.session.add(user_photos)
            
            # Update specific keys provided in map
            if 'photo1' in photos_data: user_photos.photo1 = photos_data['photo1']
            if 'photo2' in photos_data: user_photos.photo2 = photos_data['photo2']
            if 'photo3' in photos_data: user_photos.photo3 = photos_data['photo3']
            if 'photo4' in photos_data: user_photos.photo4 = photos_data['photo4']
            if 'photo5' in photos_data: user_photos.photo5 = photos_data['photo5']

        # 4. Update Hobbies
        if 'hobbies' in data:
            # Assuming 'hobbies' is a dict like {'hobby1': 1, ...} based on registration logic
            # OR a list of IDs if we change frontend. Let's support the Dict as per AuthRepo
            hobbies_map = data['hobbies']
            
            # Retrieve existing record or create new
            user_hobbies = UserHobbies.query.filter_by(userid=user_id).first()
            if not user_hobbies:
                user_hobbies = UserHobbies(userid=user_id)
                db.session.add(user_hobbies)

            # Clear existing columns first (optional, but safer if we want to replace list)
            # Or just overwrite based on keys 'hobby1'...'hobby5'
            
            # Map keys from frontend (hobby1..hobby5) to columns
            if isinstance(hobbies_map, dict):
                # Reset all first if needed, or just overwrite
                user_hobbies.hobby1 = hobbies_map.get('hobby1', None)
                user_hobbies.hobby2 = hobbies_map.get('hobby2', None)
                user_hobbies.hobby3 = hobbies_map.get('hobby3', None)
                user_hobbies.hobby4 = hobbies_map.get('hobby4', None)
                user_hobbies.hobby5 = hobbies_map.get('hobby5', None)

        db.session.commit()
        return jsonify({"message": "User updated successfully"}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, threaded=True, host='0.0.0.0')