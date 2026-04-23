from fastapi import APIRouter

router = APIRouter()


@router.get("/")
def list_users():
    return []


@router.post("/")
def create_user():
    return {}
