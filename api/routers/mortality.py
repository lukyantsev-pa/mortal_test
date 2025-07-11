from fastapi import APIRouter, Depends
from schemas import MortalityQuery
from crud import search_mortality_data
from database import get_db

router = APIRouter(prefix="/mortality", tags=["Mortality"])

@router.post("/search")
async def search_mortality(query: MortalityQuery, db=Depends(get_db)):
    return await search_mortality_data(db, query)