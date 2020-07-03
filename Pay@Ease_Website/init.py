import os
from flask import Flask, render_template, redirect, url_for, request, session
import requests
from requests.auth import HTTPBasicAuth
import secrets
from management import *

secret = secrets.token_urlsafe(16)

QR_FOLDER = os.path.join('static', 'QRCode')


app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = QR_FOLDER


@app.route("/")
def main():
    return render_template("main.html");

@app.route('/login/', methods=['GET','POST'])
def login():
    error = ''
    if request.method == 'POST':
       
        loginURL = 'https://payatease.herokuapp.com/api/account/detail/' + request.form['username']
        res = requests.get(loginURL, auth=HTTPBasicAuth(request.form['username'], request.form['password']))
        
        if res.status_code == 200:
            data = res.json()
            userInfo = res.json()
            print(userInfo)
            #userInfo = getAll()
            billLists = userInfo['bill']
            session['username'] = request.form['username']
            session['password'] = request.form['password']
            session['userInfo'] = userInfo
            session['billLists'] = billLists
            return redirect(url_for('profile', userInfo = userInfo))
        elif res.status_code == 404:
            print('Not Found.')
            error = 'Cannot find your account. Please Check Again Username and Password'
        else:
            error = 'Unsuccessful Sign in due to ' + str(res)    



    return render_template('login.html', error = error)

@app.route('/signup/', methods=['GET','POST'])
def signup():
    error = ''
    if request.method == 'POST':
        data = {}
        if request.form['corp'] == "business":
            data = {
            "username" : request.form['username'],
            "password" : request.form['password'],
            "password2" : request.form['confirmPassword'],
            "email" : request.form['email'],
            "corporation" : True,
            "company_name" : request.form['company'],
            "industry" : request.form['industry'],
            "phone_number" : request.form['phone'],
            "address" : request.form['address'],
            "postal_code" : request.form['postal']
            }
        
        else:
            data = {
            "username" : request.form['username'],
            "password" : request.form['password'],
            "password2" : request.form['confirmPassword'],
            "email" : request.form['email'],
            "corporation" : False,
            "phone_number" : request.form['phone'],
            "address" : request.form['address'],
            "postal_code" : request.form['postal']
            }

        upload = json.dumps(data)
        headers = {'content-type': 'application/json'}
        registerURL = "https://payatease.herokuapp.com/api/account/register/"

        res = requests.post(registerURL, headers = headers, data = upload)
        if res.status_code == 200:
            return redirect(url_for('login'))
        elif res.status_code == 404:
            print('Not Found.')
        else:
            error = 'Unsuccessful Sign in due to ' + str(res)    


    return render_template('signup.html', error = error)

@app.route('/activeBills/')
def activeBills():
    a = checkSession()
    if a == False:
        return redirect(url_for('main'))
    else:
        username = session.get('username')
        password = session.get('password')

        updateInfo(username, password)

        billLists = session.get('billLists')
        openList = []
        for bills in billLists:

            if bills['paid'] == False:
                openList.append(bills)
            
        print(openList)
        return render_template('activeList.html', openList = openList)

    

@app.route('/closeBills/')
def closeBills():
    a = checkSession()
    if a == False:
        return redirect(url_for('main'))
    else:
        billLists = session.get('billLists')
        closeList = []
        username = session.get('username')
        for bills in billLists:
    
            if bills['paid'] == True:
                closeList.append(bills)
            
        print(closeList)
        return render_template('closeList.html', closeList = closeList, username = username)


@app.route('/instantBill/',methods=['GET','POST'])
def instantBill():
    a = checkSession()
    if a == False:
        return redirect(url_for('main'))
    else:
        username = session.get('username')
        password = session.get('password')
        userInfo = session.get('userInfo')
        billDetail = {}
        code = 0
        day = ""
        imgName = ""
        img = {
            "imageName": ""
        }
        if request.method == 'POST':
            billID = billIDGenerator(userInfo)
            print(billID)
            billDetail = {
                "billID": billID,
                "username": userInfo['username'],
                "amount": request.form['billAmount']
            }
            print("THIS IS ITTTT")
            print(billDetail)
            QRGenerator(billDetail['billID'], billDetail['username'], billDetail['amount'])
            code = 1
            day = datetime.now()
            imgName = billID + ".png"
            img ={
                "imageName":imgName
            }
            
            print("PRE GENERATE BILL")
            generateBill(billDetail['billID'], billDetail['amount'], billDetail['username'],  username, password)

            return render_template('instant_bill.html', billDetail = billDetail, code = code, day = day, imgName = imgName, img = img)
        

        return render_template('instant_bill.html', billDetail = billDetail, code = code, day = day, img = img)
    
@app.route('/profile/')
def profile():
    a = checkSession()
    if a == False:
        return redirect(url_for('main'))
    else:
        
        userInfo = session.get('userInfo')

        return render_template('user_profile.html', userInfo = userInfo)
    

@app.route('/logout/')
def logout():
    session.pop("username", None)
    session.pop("password", None)
    session.pop("userInfo", None)
    session.pop("billLists", None)

    return redirect(url_for('main'))

if __name__ == "__main__":
    app.config["SECRET_KEY"] = secret

    app.run(host='127.0.0.1', port=5000, debug=True, threaded = True)