FROM python:3.12-slim@sha256:d66e2f0b09ca0b11eb1e40b25284f5e8c46c16bc58b16cf1e2fdf5188a3a8b3d

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Create non-root user
RUN chmod a-w /etc && \
    groupadd --gid 2000 mlflow && \
    useradd --uid 2000 --gid mlflow --shell /bin/bash --create-home mlflow

WORKDIR /home/mlflow

# Copy project config and install dependencies
COPY pyproject.toml .
RUN uv sync --frozen --no-dev

# Ensure python symlink for compatibility
RUN ln -s /usr/bin/python3.12 /usr/bin/python

# Switch to non-root user
USER mlflow

EXPOSE 8787

ENTRYPOINT ["/home/mlflow/.venv/bin/mlflow"]
