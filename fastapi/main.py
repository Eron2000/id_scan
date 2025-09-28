from fastapi import FastAPI, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
from pydantic import BaseModel
import shutil
import os
import uuid

app = FastAPI()

# Allow requests from any origin (for Flutter app)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Directory to store uploaded images
UPLOAD_DIR = "evidence_images"
os.makedirs(UPLOAD_DIR, exist_ok=True)


@app.post("/record-violation/")
async def record_violation(
    full_name: str = Form(...),
    student_number: str = Form(...),
    course: str = Form(...),
    violations: List[str] = Form(...),
    evidence: Optional[UploadFile] = File(None)
):
    # Log the basic info
    print(f"📥 Received Violation Report:")
    print(f"Name: {full_name}")
    print(f"Student Number: {student_number}")
    print(f"Course: {course}")
    print(f"Violations: {violations}")
    
    # Save image if provided
    evidence_path = None
    if evidence:
        filename = f"{uuid.uuid4()}_{evidence.filename}"
        evidence_path = os.path.join(UPLOAD_DIR, filename)
        with open(evidence_path, "wb") as f:
            shutil.copyfileobj(evidence.file, f)
        print(f"📷 Evidence saved at: {evidence_path}")

    return {
        "status": "success",
        "message": "Violation recorded successfully",
        "data": {
            "full_name": full_name,
            "student_number": student_number,
            "course": course,
            "violations": violations,
            "evidence_path": evidence_path,
        }
    }
    