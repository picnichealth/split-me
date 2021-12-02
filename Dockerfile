FROM python:3.7-alpine3.8
WORKDIR /src
RUN apk --no-cache add pdftk
COPY src/requirements.txt ./
RUN pip install -r requirements.txt
COPY src ./
CMD python server.py
