from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import shutil
import os

app = FastAPI()

# Allow Flutter app access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # for dev; restrict in prod
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory DB
violations_db: List[dict] = []

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


class ViolationRecord(BaseModel):
    name: str
    student_no: str
    course: str
    department: str
    violations: List[str]
    offense: str
    time: str
    evidence_url: Optional[str] = None


def get_offense_count(student_no: str) -> str:
    """Return offense as 1st, 2nd, 3rd based on student history"""
    count = sum(1 for v in violations_db if v["student_no"] == student_no)
    if count == 0:
        return "1st"
    elif count == 1:
        return "2nd"
    elif count == 2:
        return "3rd"
    else:
        return f"{count+1}th"


@app.post("/violations/")
async def record_violation(
    name: str = Form(...),
    student_no: str = Form(...),
    course: str = Form(...),
    department: str = Form(...),
    violations: str = Form(...),  # comma-separated
    evidence: Optional[UploadFile] = File(None),
):
    evidence_url = None
    if evidence:
        file_path = os.path.join(UPLOAD_DIR, evidence.filename)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(evidence.file, buffer)
        evidence_url = f"/{file_path}"

    offense = get_offense_count(student_no)

    record = {
        "name": name,
        "student_no": student_no,
        "course": course,
        "department": department,
        "violations": violations.split(","),
        "offense": offense,
        "time": datetime.now().strftime("%Y-%m-%d %H:%M"),
        "evidence_url": evidence_url,
    }

    violations_db.append(record)
    return {"message": "Violation recorded", "record": record}


@app.get("/violations/")
async def get_violations():
    return {"records": violations_db}
