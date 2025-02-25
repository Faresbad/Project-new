FROM python:3.9-slim
WORKDIR /app
COPY ./microservice2/requirements.txt .
COPY ./microservice2/worker.py .
RUN pip install -r requirements.txt
COPY . .
#ENV QUEUE_URL="https://sqs.us-west-2.amazonaws.com/536697248264/my-sqs-queue"
#ENV BUCKET_NAME="my-s3-bucket-fares"
EXPOSE 8000
CMD ["python", "worker.py"]