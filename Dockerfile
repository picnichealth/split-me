FROM python:3.7-alpine

RUN apk --no-cache add pdftk

COPY src/requirements.txt /src/requirements.txt

RUN pip install -r src/requirements.txt

COPY src /src

WORKDIR /src
CMD python server.py