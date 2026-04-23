from fastapi import APIRouter

router = APIRouter()


@router.get("/")
def list_profiles():
    return []


@router.post("/")
def create_profile():
    return {}
