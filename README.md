# counter-service
Develop a service called “counter-service.” It should maintain a web page with a counter for the number of POST requests it has served and return it for every GET request it gets.


Counter-Service Project
Overview
This project involves creating a simple Python-based counter service, containerizing it with Docker, and deploying it using AWS infrastructure with a CI/CD pipeline powered by GitHub Actions.

Implementation Steps
Create a GitHub Repository

Create a new repository on GitHub for the project.
Clone the repository to your local machine.
Develop the Counter-Service App

Implement the counter-service application in Python.
Test the application locally to ensure it functions correctly.
Create a Dockerfile

Create a Dockerfile to containerize the counter-service app.
Build the Docker image locally:
bash
Copy code
docker build --tag "counter-service-local:1.0.0" .
Run the image locally to test it:
bash
Copy code
docker run -d -p 8080:8080 --name counter-service counter-service-local:1.0.0
Set Up EC2 Instance

Create an EC2 Ubuntu instance.
Install Docker on the EC2 instance.
Push Code to GitHub

Commit and push your local code changes to the GitHub repository.
Create an ECR Repository

Create a repository in Amazon Elastic Container Registry (ECR) to store your Docker images.
CI Configuration with GitHub Actions

Write GitHub Actions workflows to handle Continuous Integration (CI):
Build the Docker image.
Push the image to ECR.
Integrate SonarCloud and Snyk for code quality and security tests.
CD Configuration with GitHub Actions

Write GitHub Actions workflows to handle Continuous Deployment (CD):
Pull the Docker image from ECR to the EC2 instance.
Run the Docker container using Docker Compose.
Domain Name Setup (Optional)

Purchase a domain name from AWS Route 53 (if needed).
Connect the domain to your EC2 instance.
Project Structure
css
Copy code
counter-service/
│
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── src/
│   └── counter_service.py
├── .gitignore
├── .dockerignore
├── README.md
└── .github/
    └── workflows/
        ├── ci.yml
        └── cd.yml
Dockerfile
Dockerfile
Copy code
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src/ .

CMD ["gunicorn", "counter_service:app", "--bind", "0.0.0.0:8080"]
Docker Compose Configuration
yaml
Copy code
version: '3.8'

services:
  counter-service:
    image: counter-service-local:1.0.0
    ports:
      - "8080:8080"
    volumes:
      - ./data:/data
    restart: always
    mem_limit: 256M
    cpus: 0.5
GitHub Actions Workflows
CI Workflow (.github/workflows/ci.yml)

yaml
Copy code
name: CI

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Build and push Docker image
      uses: docker/build-push-action@v3
      with:
        context: .
        push: true
        tags: ${{ secrets.ECR_REGISTRY }}/counter-service:latest

    - name: SonarCloud Scan
      uses: sonarsource/sonarcloud-github-action@v1
      with:
        args: scanner:sonar-scanner
      env:
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

    - name: Snyk Security Check
      uses: snyk/actions/github@v2
      with:
        args: test
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
CD Workflow (.github/workflows/cd.yml)

yaml
Copy code
name: CD

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Deploy to EC2
      uses: appleboy/drone-ssh@v1
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ${{ secrets.EC2_USER }}
        key: ${{ secrets.EC2_SSH_KEY }}
        script: |
          docker pull ${{ secrets.ECR_REGISTRY }}/counter-service:latest
          docker-compose -f /path/to/docker-compose.yml up -d
License
This project is licensed under the MIT License - see the LICENSE file for details.

