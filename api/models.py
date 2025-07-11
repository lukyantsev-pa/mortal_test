from sqlalchemy import Column, Integer, String, SmallInteger, Boolean, ARRAY, CHAR, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class ICDBase(Base):
    __abstract__ = True
    cause_code = Column(String(5), primary_key=True)
    description = Column(String, nullable=False)

# Конкретные реализации ICD таблиц
class ICD_07A(ICDBase):
    __tablename__ = 'icd_07a'

class ICD_07B(ICDBase):
    __tablename__ = 'icd_07b'

class ICD_08A(ICDBase):
    __tablename__ = 'icd_08a'

class ICD_08B(ICDBase):
    __tablename__ = 'icd_08b'

class ICD_09M(ICDBase):
    __tablename__ = 'icd_09m'

class ICD_09N(ICDBase):
    __tablename__ = 'icd_09n'

class ICD_09C(ICDBase):
    __tablename__ = 'icd_09c'

class ICD_UE1(ICDBase):
    __tablename__ = 'icd_ue1'

class ICD_101(ICDBase):
    __tablename__ = 'icd_101'

class ICD_10M(ICDBase):
    __tablename__ = 'icd_10m'

class Country(Base):
    __tablename__ = "countries"
    country_code = Column(SmallInteger, primary_key=True)
    name = Column(String(100), nullable=False)
    mortality_records = relationship("MortalityData", back_populates="country")

class ListTypeMapping(Base):
    __tablename__ = "list_type_mapping"
    list_type = Column(CHAR(3), primary_key=True)
    table_name = Column(String(10), nullable=False)
    mortality_records = relationship("MortalityData", back_populates="icd_list_type")

class MortalityData(Base):
    __tablename__ = "mortality_data"
    id = Column(Integer, primary_key=True)
    year = Column(SmallInteger, primary_key=True)
    country_code = Column(SmallInteger, ForeignKey("countries.country_code"), nullable=False)
    admin1 = Column(String(5))
    subdiv = Column(String(5))
    list_type = Column(CHAR(3), ForeignKey("list_type_mapping.list_type"), nullable=False)
    cause_code = Column(String(5), nullable=False)
    sex = Column(Boolean, nullable=False)
    format_code = Column(CHAR(2))
    im_format = Column(CHAR(2))
    deaths = Column(ARRAY(Integer))
    im_deaths = Column(ARRAY(Integer))
    
    country = relationship("Country", back_populates="mortality_records")
    icd_list_type = relationship("ListTypeMapping", back_populates="mortality_records")