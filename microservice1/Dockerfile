FROM python:3.9-slim
WORKDIR /app
COPY ./microservice1/requirements.txt .
COPY ./microservice1/app.py .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8080
CMD ["python", "app.py"]