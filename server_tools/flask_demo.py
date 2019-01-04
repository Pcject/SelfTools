from flask import Flask, request
import json
app = Flask(__name__)

@app.route('/notify',methods=['POST'])
def notify():
    form = request.form.to_dict()
    print form
    import ipdb;ipdb.set_trace()
    return 'success'

@app.route('/return')
def return_a():
    return json.dumps(request.args.to_dict(),indent=4)

# export FLASK_APP=test.py
# python -m flask run --host=0.0.0.0 --port=1234