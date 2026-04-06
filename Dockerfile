FROM python:3.10-slim-bookworm

# 1. Install system-level dependencies for psutil and crypto
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git build-essential gcc python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /octobot

# 2. Install CORE dependencies + psutil (manual)
# This bypasses the memory-heavy [full] installation
COPY requirements.txt .
RUN pip install --no-cache-dir -U pip setuptools wheel \
    && pip install --no-cache-dir psutil cryptography \
    && pip install --no-cache-dir -r requirements.txt

# 3. Copy application files
COPY . .

# 4. Remove UI to stay under 512MB
RUN rm -rf octobot/web tentacles/Services/gateio tentacles/Services/kucoin

# 5. Global Optimizations
ENV PYTHONOPTIMIZE=2
ENV DISABLE_UI=true
ENV OCTOBOT_SKIP_SETUP=true
ENV MALLOC_ARENA_MAX=2

# Start the engine
CMD ["python", "start.py", "--headless", "--no-gui"]
