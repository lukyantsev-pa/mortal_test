from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    database_url: str = Field(description='URL to db')
    database_pool_size: int = Field(description='Max connections to db')
    database_max_overflow: int = Field(description='Max overflow connections to db')


settings = Settings()