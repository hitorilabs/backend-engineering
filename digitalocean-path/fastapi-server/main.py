from typing import Union

from fastapi import FastAPI, Request

app = FastAPI()

PLACEHOLDER=[
    {
        "name": "Bocchi the Rock!", 
        "rating": 10, 
        "review": "Only slice of life I'll ever watch"
    },
    {
        "name": "Bleach", 
        "rating": 10, 
        "review": "I watched all of it over 5 days to catch up to Thousand Year Blood War. Skip the filler and it might just be GOAT"
    },
]

@app.get("/")
def base(request: Request):
    client_host = request.client.host
    return {
        "path": request.url.path,
        "client_host": client_host, 
        "response": "Hello World"
        }


@app.get("/anime")
def list_anime():
    '''
    Returns all anime that I've watched
    '''
    return PLACEHOLDER