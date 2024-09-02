from flask import Flask, render_template, request, redirect, url_for, flash, session, Blueprint, g
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, IntegerField
from wtforms.validators import DataRequired, Email, Length, Regexp, EqualTo, InputRequired, NumberRange
from flask_bcrypt import Bcrypt
from sqlalchemy.sql.expression import bindparam
from sqlalchemy import Integer
from sqlalchemy import update

import json
import boto3
import uuid

app = Flask(__name__)

app.config['SECRET_KEY'] = 'your_secret_key_here'

# SQLAlchemy 설정
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://myrouter:It12345!@10.0.0.200:6446/recapark'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)





# Flask-Login 설정
login_manager = LoginManager(app)
login_manager.login_view = 'login'
bcrypt = Bcrypt(app)
login_manager.init_app(app)

sqs = boto3.client('sqs', region_name='ap-northeast-2')
s3 = boto3.client('s3', region_name='ap-northeast-2')

class UserTicketAssociation(db.Model):
    __tablename__ = 'user_ticket_association'

    user_id = db.Column(db.Integer, db.ForeignKey('users.uid'), primary_key=True)
    ticket_id = db.Column(db.Integer, db.ForeignKey('new_ticket_table.id'), primary_key=True)
    quantity = db.Column(db.Integer, nullable=False, default=0)

    # users와의 관계 설정
    users = db.relationship('User', back_populates='user_ticket_association')
    tickets = db.relationship('Ticket', back_populates='user_ticket_association')




# 모델 클래스 정의
class User(UserMixin, db.Model):
    __tablename__ = 'users'
    uid = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(50), nullable=False)
    user_id = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    address = db.Column(db.String(255))
    phone = db.Column(db.String(15))
    tickets = db.relationship('Ticket', secondary='user_ticket_association', back_populates='users')
    user_ticket_association = db.relationship('UserTicketAssociation', back_populates='users')    
    payment_information = db.relationship('PaymentInformation', back_populates='user', uselist=False)
    
    def __init__(self, name, user_id, password, email, address=None, phone=None):
        self.name = name
        self.user_id = user_id
        self.password = bcrypt.generate_password_hash(password).decode('utf-8')
        self.email = email
        self.address = address
        self.phone = phone
    def get_id(self):
        return str(self.user_id)
        
class Ticket(db.Model):
    __tablename__ = 'new_ticket_table'
    id = db.Column(db.Integer, primary_key=True)
    event = db.Column(db.String(255), nullable=False)
    price = db.Column(db.Integer, nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    users = db.relationship('User', secondary='user_ticket_association', back_populates='tickets')
    user_ticket_association = db.relationship('UserTicketAssociation', back_populates='tickets')  # 수정
    

class PaymentInformation(db.Model):
    __tablename__ = 'payment_information'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.uid'), unique=True, nullable=False)
    card_number = db.Column(db.String(16), nullable=False)
    expiration_date = db.Column(db.String(5), nullable=False)
    cvv = db.Column(db.String(3), nullable=False)
    
    # users와의 관계 설정
    user = db.relationship('User', back_populates='payment_information')



with app.app_context():
    db.reflect()

# 로그인 폼 정의
class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Login')

# 회원가입 폼 정의
class RegistrationForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired()])
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[
        DataRequired(),
        Length(min=8, message='Password must be at least 8 characters long'),
        Regexp('^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]+$', message='Password must include at least one lowercase letter, one uppercase letter, one digit, and one special character')
    ])
    password_confirm = PasswordField('Confirm Password', validators=[DataRequired(), EqualTo('password', message='Passwords must match')])
    email = StringField('Email', validators=[DataRequired(), Email()])
    address = StringField('Address')
    phone = StringField('Phone')
    card_number = StringField('Card Number', validators=[InputRequired()])
    expiration_date = StringField('Expiration Date (MM/YY)', validators=[InputRequired()])
    cvv = StringField('CVV', validators=[InputRequired()])
    submit = SubmitField('Register')

# 티켓 구매 폼 정의
class BuyTicketForm(FlaskForm):
    quantity = IntegerField('Quantity', validators=[DataRequired()])
    submit = SubmitField('Buy')
    
class CancelReservationForm(FlaskForm):
    cancel_quantity = IntegerField('취소할 개수', validators=[InputRequired(), NumberRange(min=1)])
    submit = SubmitField('예매 취소')


def load_logged_in_user():
    user_id = session.get('user_id')
    if user_id is None:
        g.user = None
    else:
        g.user = User.query.get(user_id)
        
        
# 로그인 뷰
@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(user_id=form.username.data).first()
        if user and bcrypt.check_password_hash(user.password, form.password.data):
            session.clear()
            session['user_id'] = user.user_id
       
            flash('Login successful!', 'success')
            return redirect(url_for('index'))
        else:
            flash('Login failed. Check your username and password.', 'danger')
            return render_template('login.html', form=form)

    # 아래 라인 추가: form이 submit되었지만 validate에 실패했을 때의 처리
    elif request.method == 'POST':
        flash('Login failed.', 'danger')
    return render_template('login.html', form=form)


# 로그아웃 뷰
@app.route('/logout')
def logout():
    if 'user_id' not in session or session['user_id'] is None:
        # 로그인되지 않은 경우, 로그인 페이지로 리다이렉트 또는 다른 처리 수행
        return redirect(url_for('login'))
    session.clear()
    flash('Logout successful!', 'success')
    return render_template('index.html', tickets=Ticket.query.all())

# 회원가입 뷰
@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        existing_user = User.query.filter_by(user_id=form.username.data).first()
        existing_user_email = User.query.filter_by(email=form.email.data).first()        
        if existing_user:
            flash('Username already exists. Please choose a different one.', 'danger')
            return render_template('register.html', form=form, error='danger')
        elif existing_user_email:
            flash('Email address already exists. Please choose a different one.', 'danger')
            return render_template('register.html', form=form, error='danger')            
        else:
            new_user = User(
                name=form.name.data,
                user_id=form.username.data,
                password=form.password.data,
                email=form.email.data,
                address=form.address.data,
                phone=form.phone.data
            )
            db.session.add(new_user)
            db.session.commit()
            # 추가: 회원가입한 사용자의 ID를 가져와서 PaymentInformation을 생성하여 연결
            user_id = new_user.uid
            payment_info = PaymentInformation(
                user_id=user_id,
                card_number=form.card_number.data,
                expiration_date=form.expiration_date.data,
                cvv=form.cvv.data
            )
            db.session.add(payment_info)
            db.session.commit()            
            flash('Registration successful! Please log in.', 'success')
            return render_template('index.html', tickets=Ticket.query.all())
    return render_template('register.html', form=form)

# 구매 뷰
@app.route('/buy/<int:ticket_id>', methods=['GET', 'POST'])
def buy(ticket_id):
    if 'user_id' not in session or session['user_id'] is None:
        # 로그인되지 않은 경우, 로그인 페이지로 리다이렉트 또는 다른 처리 수행
        return redirect(url_for('login'))
    form = BuyTicketForm()
    ticket = Ticket.query.get(ticket_id)
    
    if ticket:
        if form.validate_on_submit():
            purchased_quantity = form.quantity.data
            if purchased_quantity <= ticket.quantity:
                # 여기에서 실제 구매 로직을 추가할 수 있습니다.
                # 예시로 구매 내용을 SQS로 전송합니다.
                purchase_data = {
                    'ticket_id': ticket_id,
                    'event': ticket.event,
                    'price': ticket.price,
                    'quantity': purchased_quantity,
                    'total_price': ticket.price * purchased_quantity,
                    'user_id': session['user_id'],
                    'type' : 'purchase'
                }

                # SQS에 메시지 전송
                sqs.send_message(
                    QueueUrl='https://sqs.ap-northeast-2.amazonaws.com/447079561480/Ticket-Buy-Queue.fifo',
                    MessageBody=json.dumps(purchase_data),
                    MessageGroupId=f'event_{ticket_id}',
                    MessageDeduplicationId=str(uuid.uuid4())
                )

                # 사용자와 티켓 연결
                user = User.query.filter_by(user_id=session['user_id']).first()
                

                      # user_ticket_association에 추가
                user_ticket_association_data = {
                    'user_id': user.uid,
                    'ticket_id': ticket.id,
                    'quantity': purchased_quantity
                }
                existing_association = UserTicketAssociation.query.filter_by(user_id=user.uid, ticket_id=ticket.id).first()
                if existing_association:
    # 이미 존재하는 경우, quantity만 증가시킴
                    existing_association.quantity += purchased_quantity
                else:
    # 존재하지 않는 경우, 새로운 association을 생성하여 추가
                    user_ticket_association = UserTicketAssociation(**user_ticket_association_data)
                    db.session.add(user_ticket_association)

          
               


                
                db.session.commit()
                flash('Purchase successful!', 'success')
                return redirect(url_for('index'))
            else:
                flash('남은 표 보다 많이 구매 요청하셨습니다!', 'danger')
                return render_template('buy.html', ticket=ticket, form=form)    
        else:
            flash(form.errors, 'success')
            return render_template('buy.html', ticket=ticket, form=form)

    else:
        flash('Ticket not found.', 'danger')
        return redirect(url_for('index'))

# 구매 내역 뷰
@app.route('/purchase_history')
def purchase_history():
    if 'user_id' not in session or session['user_id'] is None:
        # 로그인되지 않은 경우, 로그인 페이지로 리다이렉트 또는 다른 처리 수행
        return redirect(url_for('login'))
    user = User.query.filter_by(user_id=session['user_id']).first()
    purchases = db.session.query(Ticket.event, Ticket.price, Ticket.id, UserTicketAssociation.quantity). \
        join(UserTicketAssociation). \
        join(User). \
        filter(User.uid == user.uid). \
        filter(Ticket.id == UserTicketAssociation.ticket_id).all()
    cancel_form = CancelReservationForm()

    return render_template('purchase_history.html', purchases=purchases, form=cancel_form)

# 초기 화면 뷰
@app.route('/')
def index():
    return render_template('index.html', tickets=Ticket.query.all())


@login_manager.user_loader
def load_user(user_id):
    return User.query.get(str(user_id))
    
    
@app.route('/cancel_reservation/<int:ticket_id>', methods=['GET', 'POST'])
def cancel_reservation(ticket_id):
    form = CancelReservationForm()

    if form.validate_on_submit():
        cancel_quantity = form.cancel_quantity.data
        ticket = Ticket.query.get(ticket_id)
        
        # 여기에서 예매 취소 로직을 추가
        # ticket_id와 cancel_quantity를 사용하여 예매 정보를 찾아 예매를 취소하는 코드를 작성

 
                # 여기에서 실제 구매 로직을 추가할 수 있습니다.
                # 예시로 구매 내용을 SQS로 전송합니다.
        cancel_data = {
            'ticket_id': ticket_id,
            'event': ticket.event,
            'price': ticket.price,
            'quantity': cancel_quantity,
            'total_price': ticket.price * cancel_quantity,
            'user_id': session['user_id'],
            'type' : 'cancel'
        }

                # SQS에 메시지 전송
        sqs.send_message(
            QueueUrl='https://sqs.ap-northeast-2.amazonaws.com/447079561480/Ticket-Buy-Queue.fifo',
            MessageBody=json.dumps(cancel_data),
            MessageGroupId=f'event_{ticket_id}',
            MessageDeduplicationId=str(uuid.uuid4())
        )
        
        
        
        user = User.query.filter_by(user_id=session['user_id']).first()
        
        existing_association = UserTicketAssociation.query.filter_by(user_id=user.uid, ticket_id=ticket_id).first()
        
        if existing_association:
            existing_association.quantity -= cancel_quantity        
            db.session.commit()
        else:
            flash('error', 'danger')
        
        flash(f'{cancel_quantity}개의 티켓이 취소되었습니다.', 'success')

        # 예매 취소 후, 구매 내역 페이지로 리다이렉트
        return redirect(url_for('purchase_history'))

    # GET 요청이면 폼을 렌더링
    return redirect(url_for('purchase_history'))   
    
    
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)
    

