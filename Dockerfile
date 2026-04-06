FROM python:3.10-slim-bookworm

# 1. Minimalism: Only install what is strictly needed for CCXT and Prediction Markets
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /octobot

# 2. Optimization: Disable pip cache to save disk/RAM during build
COPY requirements.txt .
RUN pip install --no-cache-dir -U pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt

# 3. Copy only the core application
COPY . .

# 4. CRITICAL: Remove the Web UI and unused exchanges BEFORE starting
# This physically shrinks the memory footprint
RUN rm -rf octobot/web tentacles/Services/gateio tentacles/Services/kucoin

# 5. Runtime Optimizations
ENV PYTHONOPTIMIZE=2
ENV DISABLE_UI=true
ENV OCTOBOT_SKIP_SETUP=true
ENV MALLOC_ARENA_MAX=2

# Bypassing the entrypoint script which often triggers a heavy setup wizard
CMD ["python", "start.py", "--headless", "--no-gui"]

