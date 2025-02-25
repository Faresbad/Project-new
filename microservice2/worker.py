import boto3
import time
import os
from datetime import datetime

# AWS clients
sqs = boto3.client('sqs', region_name='us-west-2')
s3 = boto3.client('s3', region_name='us-west-2')

# Environment variables
# QUEUE_URL = os.getenv('QUEUE_URL')
QUEUE_URL="https://sqs.us-west-2.amazonaws.com/536697248264/my-sqs-queue"
BUCKET_NAME="my-s3-bucket-fares"
# BUCKET_NAME = os.getenv('BUCKET_NAME')

def process_messages():
    while True:
        # Pull messages from SQS
        response = sqs.receive_message(
            QueueUrl=QUEUE_URL,
            MaxNumberOfMessages=10,
            WaitTimeSeconds=10
        )
        print("waiting messages")
        if 'Messages' in response:
            for message in response['Messages']:
                # Upload message to S3
                timestamp = datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
                s3.put_object(
                    Bucket=BUCKET_NAME,
                    Key=f"messages/{timestamp}.json",
                    Body=message['Body']
                )
                # Delete the message from the queue
                sqs.delete_message(
                    QueueUrl=QUEUE_URL,
                    ReceiptHandle=message['ReceiptHandle']
                )
        time.sleep(60)  # Adjust the interval as needed

if __name__ == '__main__':
    process_messages()
