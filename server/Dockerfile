FROM tiangolo/uvicorn-gunicorn:python3.11

EXPOSE 8000

WORKDIR /code
COPY . /code/

RUN python -m pip install --upgrade pip
RUN pip install .

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "1", "-k", "uvicorn.workers.UvicornWorker", "hammyws:app"]
