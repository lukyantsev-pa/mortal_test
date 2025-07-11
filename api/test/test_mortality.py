import pytest
sys.path.append("..")
from models import MortalityData, Country
from database import AsyncSessionLocal

@pytest.mark.asyncio
async def test_search_mortality_empty(client):
    res = await client.post("/mortality/search", json={})
    assert res.status_code == 200
    assert isinstance(res.json(), list)

@pytest.mark.asyncio
async def test_search_mortality_with_data(client):
    async with AsyncSessionLocal() as session:
        session.add(Country(country_code=36, name="Testland"))
        session.add(MortalityData(
            id=1,
            year=1995,
            country_code=36,
            list_type="101",
            cause_code="A01",
            sex=True,
            deaths=[1]*26,
            im_deaths=[2]*4
        ))
        await session.commit()

    res = await client.post("/mortality/search", json={
        "country_code": 36,
        "year": 1995,
        "sex": True,
        "cause_code": "A01",
        "list_type": "101"
    })
    assert res.status_code == 200
    data = res.json()
    assert isinstance(data, list)
    assert len(data) == 1
