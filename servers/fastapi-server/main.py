from fastapi import FastAPI, Request, Response
from models import Event, CharmCompany

app = FastAPI()


@app.post("/")
async def root(event: Event):
    print(event)
    if event.type == 1: return {"type": 1}
    return {"type": -1}

@app.post("/company")
async def root(company: CharmCompany):
    return company