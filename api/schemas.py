from pydantic import BaseModel, Field, validator
from typing import Optional, List

class MortalityQuery(BaseModel):
    country_code: Optional[int] = Field(None, ge=0, description="Numeric country code identifier", example=36)
    year: Optional[int] = Field(None, ge=1950, le=2030, description="Year of mortality data", example=2010)
    sex: Optional[bool] = Field(None, description="Sex indicator (True for male, False for female)", example=True)
    cause_code: Optional[str] = Field(None, min_length=1, max_length=5,description="Cause of death code according to ICD classification", example="A01")
    list_type: str = Field(..., description="ICD list type identifier", example="101")
    cause_substr: Optional[str] = Field(None, min_length=2, description="Substring to search in cause description", example="tuberculosis")
    country_substr: Optional[str] = Field(None, min_length=2, description="Substring to search in country name", example="United")
    limit: Optional[int] = Field(100, ge=1, le=1000, description="Maximum number of results to return", example=100)
    offset: Optional[int] = Field(0, ge=0, description="Number of results to skip for pagination", example=0)

    @validator('list_type')
    def validate_list_type(cls, v):
        valid_types = ["07a", "07b", "08a", "08b", "09m", 
                      "09n", "09c", "ue1", "101", "10m"]
        if v.lower() not in valid_types:
            raise ValueError(f"Invalid list type. Must be one of: {valid_types}")
        return v.lower()

class MortalityOut(BaseModel):
    id: int = Field(..., description="Unique record identifier")
    year: int = Field(..., description="Year of data", example=2010)
    country_code: int = Field(..., description="Country code", example=36)
    country_name: str = Field(..., description="Country name", example="Testland")
    cause_code: str = Field(..., description="Cause of death code", example="A01")
    cause_description: Optional[str] = Field(None, description="Description of the cause of death", example="Tuberculosis")
    deaths: Optional[List[int]] = Field(None, description="Array of death counts by age groups", example=[1, 2, 3, 0, 5])

class CountryOut(BaseModel):
    country_code: int = Field(..., example=36)
    name: str = Field(..., example="Testland")

class CauseOut(BaseModel):
    cause_code: str = Field(..., example="A01")
    description: str = Field(..., example="Tuberculosis")

class MortalitySearchRequest(BaseModel):
    country_codes: Optional[List[int]] = Field(None, description="Список кодов стран")
    cause_codes: Optional[List[str]] = Field(None, description="Список кодов причин")
    list_type: str = Field(..., description="Тип классификации")
    sex: Optional[str] = Field(None, description="Пол: 'male', 'female' или None для обоих")
    year_from: Optional[int] = Field(None, ge=1950, description="Начальный год")
    year_to: Optional[int] = Field(None, le=2030, description="Конечный год")
    limit: int = Field(100, ge=1, le=1000)
    offset: int = Field(0, ge=0)