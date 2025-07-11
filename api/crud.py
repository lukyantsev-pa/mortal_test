from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from models import MortalityData, Country, ListTypeMapping
from schemas import MortalityQuery
from utils import get_icd_table_model
from fastapi import HTTPException

async def search_mortality_data(db: AsyncSession, query: MortalityQuery):
    # Проверить существование list_type в mapping таблице
    mapping = await db.execute(
        select(ListTypeMapping).where(ListTypeMapping.list_type == query.list_type)
    )
    if not mapping.scalar():
        raise HTTPException(
            status_code=400,
            detail=f"List type {query.list_type} not found in mapping table"
        )

    icd_table = get_icd_table_model(query.list_type)
    if not icd_table:
        raise HTTPException(
            status_code=400,
            detail=f"No ICD table model for list type {query.list_type}"
        )
    
    stmt = select(
        MortalityData,
        Country.name.label("country_name"),
        icd_table.description.label("cause_description")
    ).join(
        Country, MortalityData.country_code == Country.country_code
    ).outerjoin(
        icd_table, MortalityData.cause_code == icd_table.cause_code
    )

    filters = []
    if query.country_code:
        filters.append(MortalityData.country_code == query.country_code)
    if query.year:
        filters.append(MortalityData.year == query.year)
    if query.sex is not None:
        filters.append(MortalityData.sex == query.sex)
    if query.cause_code:
        filters.append(MortalityData.cause_code == query.cause_code)
    if query.list_type:
        filters.append(MortalityData.list_type == query.list_type)
    if query.country_substr:
        filters.append(func.lower(Country.name).ilike(f"%{query.country_substr.lower()}%"))
    if query.cause_substr:
        filters.append(func.lower(icd_table.description).ilike(f"%{query.cause_substr.lower()}%"))

    stmt = stmt.where(*filters).order_by(MortalityData.year.desc()).limit(query.limit).offset(query.offset)

    result = await db.execute(stmt)
    return [
        {
            **row.MortalityData.__dict__,
            "country_name": row.country_name,
            "cause_description": row.cause_description
        } for row in result.fetchall()
    ]