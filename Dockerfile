# ---------------------------------------------------------------
# Container image for the app.
# Every choice here shrinks what an attacker could use if they got in.
# ---------------------------------------------------------------

# Pin an exact base image tag (never "latest"), so builds are repeatable
# and Trivy is scanning the same thing every time.
# "slim" = a cut-down Debian with fewer packages = fewer CVEs to inherit.
FROM python:3.12-slim

# Don't write .pyc files, and flush logs straight to the console.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy requirements FIRST, then install. Docker caches each step, so
# dependencies only reinstall when requirements.txt actually changes.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Now copy the app code.
COPY app/ ./app/

# Create an unprivileged user and switch to it.
# By default containers run as root. If someone exploited the app,
# they'd have root inside the container. As "appuser" they don't.
RUN useradd --create-home --shell /usr/sbin/nologin appuser
USER appuser

EXPOSE 8000

# Lets Docker check the app is actually alive, not just "running".
# slim images have no curl, so we use Python itself to hit /health.
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health')" || exit 1

# gunicorn is a production web server (Flask's built-in one is for dev only).
# Binding to 0.0.0.0 is correct INSIDE a container: Docker's own
# networking decides what's reachable from outside.
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.main:app"]
