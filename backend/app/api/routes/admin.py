from fastapi import APIRouter

router = APIRouter()


@router.get("/users")
def admin_list_users():
    return []


@router.get("/costs")
def admin_cost_dashboard():
    return {"total_tokens": 0, "total_cost_usd": 0}
