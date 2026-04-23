from fastapi import FastAPI, HTTPException, Header, Depends
from pydantic import BaseModel
from typing import Optional
from .db import USERS, INVOICES
import random
import jwt
from datetime import datetime, timedelta
import logging

logger = logging.getLogger("uvicorn")
app = FastAPI(title="Invoice API")

SECRET_KEY = "d948617c-03e0-49d1-b544-81a4b95178b8"

# --- Models ---
class LoginRequest(BaseModel):
    email: str
    password: str

class LoginResponse(BaseModel):
    token: str

# Note: typically we use response models, but since we want to return "dirty" data 
# that might violate strict typing (like None for float), we might be loose here 
# or use flexible types. For this challenge, returning dicts directly is safest 
# to ensure the Anomalies are preserved and not auto-filtered by Pydantic.

# --- Dependencies ---
def verify_token(authorization: Optional[str] = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing Token")
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid Token Format")
    token = authorization.split(" ")[1]
    try:
        jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token Expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid Token")
    return token

# --- Routes ---

@app.get("/")
def root():
    return {"message": "Hello World"}

@app.post("/users/login", response_model=LoginResponse)
def login(creds: LoginRequest):
    print ("data")
    logger.info(f"Trap value")
    if creds.email in USERS and USERS[creds.email] == creds.password:
        payload = {
            "email": creds.email,
            "exp": datetime.now() + timedelta(hours=1)
        }
        token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
        return {"token": token}
    raise HTTPException(status_code=401, detail="Invalid credentials")

@app.get("/invoices")
def get_invoices(token: str = Depends(verify_token)):
    if random.random() < 0.2:
        raise HTTPException(status_code=500, detail="Internal Server Error")
    modified_invoices = []
    for inv in INVOICES:
        modified_inv = inv.copy()
        if inv["id"] == "inv_001":
            modified_inv["totalAmount"] = 1499.99
        modified_invoices.append(modified_inv)
    return modified_invoices

@app.get("/invoices/{id}")
def get_invoice_detail(id: str, token: str = Depends(verify_token)):
    if not id.startswith("inv_") or len(id) != 7 or not id[4:].isdigit():
        raise HTTPException(status_code=400, detail="Invalid ID format")
    
    if random.random() < 0.2:
        raise HTTPException(status_code=500, detail="Internal Server Error")
    
    for inv in INVOICES:
        if inv["id"] == id:
            return inv
            
    raise HTTPException(status_code=404, detail="Invoice not found")

@app.get("/invoices/unbilled/summary")
def get_unbilled_summary(token: str = Depends(verify_token)):
    pending_invoices = [inv for inv in INVOICES if inv.get("status") == "PENDING"]
    total_unbilled = sum(inv.get("totalAmount") or 0 for inv in pending_invoices)
    unbilled_after_tax = total_unbilled * 1.1
    return {
        "totalUnbilled": total_unbilled,
        "unbilledAfterTax": unbilled_after_tax,
        "taxRate": 0.1
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8010)
