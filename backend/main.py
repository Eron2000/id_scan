# main.py
from fastapi import FastAPI, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import shutil
import os
from datetime import datetime

app = FastAPI()

# Allow Flutter (web or emulator) to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # change to your IP or domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Temporary in-memory database
violations_db = []

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

class Violation(BaseModel):
    name: str
    student_no: str
    course: str
    violations: List[str]
    date: str
    time: str
    image_url: Optional[str] = None


@app.post("/violations")
async def record_violation(
    name: str = Form(...),
    student_no: str = Form(...),
    course: str = Form(...),
    violations: str = Form(...),
    date: str = Form(...),
    time: str = Form(...),
    image: Optional[UploadFile] = None,
):
    image_path = None
    if image:
        image_filename = f"{datetime.now().timestamp()}_{image.filename}"
        image_path = os.path.join(UPLOAD_DIR, image_filename)
        with open(image_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)

    record = Violation(
        name=name,
        student_no=student_no,
        course=course,
        violations=violations.split(","),
        date=date,
        time=time,
        image_url=f"/{image_path}" if image_path else None,
    )
    violations_db.append(record.dict())
    return {"message": "Violation recorded", "data": record}


@app.get("/violations")
def get_violations():
    return {"violations": violations_db}
