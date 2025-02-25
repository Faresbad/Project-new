from flask import Flask, request, jsonify
import boto3
import time
import os

app = Flask(__name__)

# AWS clients
sqs = boto3.client('sqs', region_name='us-west-2')
ssm = boto3.client('ssm', region_name='us-west-2')

# Environment variables
# QUEUE_URL = os.getenv('QUEUE_URL')
QUEUE_URL = "https://sqs.us-west-2.amazonaws.com/536697248264/my-sqs-queue"
TOKEN_PARAMETER_NAME = "/microservice/token"
# TOKEN_PARAMETER_NAME = os.getenv('TOKEN_PARAMETER_NAME')

def validate_token(input_token):
    # Retrieve the token from SSM Parameter Store
    try:
        response = ssm.get_parameter(Name=TOKEN_PARAMETER_NAME, WithDecryption=True)
        correct_token = response['Parameter']['Value']
        return input_token == correct_token
    except Exception as e:
        print("Error retrieving token:", e)
        return False


def validate_timestamp(timestamp):
    try:
        if timestamp is None:
            return False
        timestamp = int(timestamp)
        current_time = int(time.time())
        return timestamp <= current_time
    except ValueError:
        return False


@app.route('/', methods=['GET'])
def hello():
    return "hello aws"
@app.route('/process', methods=['POST'])
def process_request():
    data = request.json
    payload = data.get('data')
    token = data.get('token')

    # Validate token
    if not validate_token(token):
        return jsonify({"error": "Invalid token"}), 401

    # Validate timestamp
    if not validate_timestamp(payload.get('email_timestream')):
        return jsonify({"error": "Invalid timestamp"}), 400

    # Publish to SQS
    sqs.send_message(
        QueueUrl=  QUEUE_URL,
        MessageBody=str(payload)
    )

    return jsonify({"message": "Request processed successfully"}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)

