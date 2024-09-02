FROM python:3.9-alpine
WORKDIR /app
COPY requirements.txt requirements.txt
RUN apk update && apk add --no-cache pkgconfig
RUN apk update && apk add --no-cache build-base mariadb-connector-c-dev
RUN pip3 install -r requirements.txt
COPY . .
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:80", "app:app"]

