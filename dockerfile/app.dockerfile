FROM cgr.dev/chainguard/python:latest-dev AS builder

WORKDIR /app

COPY ./app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt --user

FROM cgr.dev/chainguard/python:latest

WORKDIR /app
# Make sure you update Python version in path
COPY --from=builder /home/nonroot/.local/lib/python3.12/site-packages /home/nonroot/.local/lib/python3.12/site-packages
COPY --from=builder /home/nonroot/.local/bin/flask /home/nonroot/.local/bin/flask


COPY ./app/app.py .
COPY ./app/templates templates/
COPY ./app/static static/
ENV PATH="/home/nonroot/.local/bin:${PATH}"
EXPOSE 5000

ENTRYPOINT ["flask", "run", "--host=0.0.0.0"]