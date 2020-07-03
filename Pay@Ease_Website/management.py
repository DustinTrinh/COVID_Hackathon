import os
from flask import Flask, render_template, redirect, url_for, request, session
import requests
from requests.auth import HTTPBasicAuth
import secrets
import json
from datetime import datetime
import string 
import random
import pyqrcode 
import png 
from pyqrcode import QRCode 
from reportlab.pdfgen.canvas import Canvas
from reportlab.lib.utils import ImageReader

def checkSession():
    if not session.get("username") is None:
        return True
    else:
        return False
    

def addBill(receviverName, receiverEmail, billAmount, type, date):
    postURL = "pay@ease/register"
    data = {
        "BillID": billIDGenerator(),
        "ReceiverName": receviverName,
        "ReceiverEmail": receiverEmail,
        "BillAmount": 805,
        "Type": type,
        "Date": datetime.now(),
        "Status": "Open"
    }
    json_data = json.dumps(data)
    res = requests.post(postURL, data = json_data)

    if res.status_code == 200:
        return (str('Sucessfuly Add Bill'))
    else:
        print("Unsucessful Add Bill due to: "  + str(res))

def billIDGenerator(wholeList):
    billsID = wholeList
    your_letters='123456789'
    res = ''.join((random.choice(your_letters) for i in range(6)))
    count = 0
    save = ""
    print("LENGTH OF BILL ID")
    print(len(billsID['bill']))

    if len(billsID['bill']) == 0:
        return res
    else:

        for a in billsID['bill']:
            if res == a['billID']:
                count = count + 1
            else:
                save = res

        if count > 0:
            billIDGenerator(wholeList)
        else:
            print(save)
            return save     

def QRGenerator(billID, username, amount):
    data = billID  + " " + username + " " + amount
    imgName = billID + '.png'
    url = pyqrcode.create(data)
    url.png('./static/QRCode/' + imgName, scale = 8) 
    


def generateBill(billID, amount, name, username, password):
    #login()
    mock = {
        "billID":billID,
        "amount": amount,
        "name":name
    }
    headers = {'content-type': 'application/json'}
    url = "https://payatease.herokuapp.com/api/account/bill/generate/"
    res2 = requests.post(url,auth=HTTPBasicAuth(username, password), data = mock)

    if res2.status_code == 200:
        print("Post Success!")
        data = res2.json()
        print(data)
    elif res2.status_code == 404:
        print("Not Found.")
    else:
        print("Unsucessful: "  + str(res2))

def updateInfo(username, password):
    loginURL = 'https://payatease.herokuapp.com/api/account/detail/' + username
    res = requests.get(loginURL, auth=HTTPBasicAuth(username, password))
        
    if res.status_code == 200:
        data = res.json()
        userInfo = res.json()
    
        billLists = userInfo['bill']

        session['userInfo'] = userInfo
        session['billLists'] = billLists
        
    elif res.status_code == 404:
        print('Not Found.')
        error = 'Cannot find your account. Please Check Again Username and Password'
    else:
        error = 'Unsuccessful Sign in due to ' + str(res)    