FROM hashicorp/terraform:1.6.6

# ----------------------------
# Install OS dependencies
# ----------------------------
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git \
    bash \
    curl

# ----------------------------
# Create Python virtualenv
# ----------------------------
RUN python3 -m venv /opt/venv

# Make venv the default Python
ENV PATH="/opt/venv/bin:$PATH"

# ----------------------------
# Install Python dependencies
# ----------------------------
COPY requirements.txt /tmp/requirements.txt

RUN pip install --no-cache-dir -r /tmp/requirements.txt

# ----------------------------
# Sanity checks (fail fast)
# ----------------------------
RUN terraform version \
 && python --version \
 && python -c "import yaml; print('PyYAML OK')"

# Jenkins workspace
WORKDIR /workspace
