from fastapi import APIRouter

router = APIRouter()


@router.get("/")
def list_jobs():
    return []


@router.post("/{job_id}/magic-button")
def trigger_magic_button(job_id: int):
    # TODO: AI tailoring → submission → log
    return {"status": "triggered", "job_id": job_id}
