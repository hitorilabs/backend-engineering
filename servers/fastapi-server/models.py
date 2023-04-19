from datetime import datetime
from pydantic import BaseModel, HttpUrl, validator

# define event schema
class Event(BaseModel):
    type: int


# define company schema with generated synced_at column
class Company(BaseModel):
    domain: HttpUrl
    synced_at: datetime = datetime.utcnow()

    @validator('domain', pre=True)
    def prepend_http(cls, domain):
        if isinstance(domain, str) and not domain.startswith('https'):
            return f'https://{domain}'
        return domain


# define company schema with generated synced_at column
class CharmCompany(Company):
    pass
