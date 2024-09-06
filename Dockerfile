# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.13.0a4
FROM python:${PYTHON_VERSION}-alpine3.19 as base

# Prevent Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Prevent Python from buffering stdout and stderr.
ENV PYTHONUNBUFFERED=1

# Set the working directory to /app.
WORKDIR /app

# Upgrade Alpine packages to the latest versions, including expat.
RUN apk update && \
    apk upgrade && \
    apk add --no-cache expat

# Create a non-privileged user for running the application.
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Leverage a cache mount for pip to speed up subsequent builds and bind mount the requirements.txt.
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    python -m pip install --no-cache-dir -r requirements.txt

# Switch to the non-privileged user to run the application.
USER appuser

# Copy the source code into the container.
COPY counter-service.py .

# Expose port 8080 for the application.
EXPOSE 8080

# Command to run the application using Gunicorn with log output enabled.
CMD ["gunicorn", "counter-service:app", "--bind", "0.0.0.0:8080", "--access-logfile", "-", "--error-logfile", "-"]
