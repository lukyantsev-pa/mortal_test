from fastapi import FastAPI
from routers import mortality

app = FastAPI()

app.include_router(mortality.router)