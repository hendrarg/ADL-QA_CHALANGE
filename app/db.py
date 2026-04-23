
# In-memory "database" with intentional anomalies

# Users for login
USERS = {
    "admin@example.com": "password123"
}

# Invoices with dirty data
# 1. Valid Invoice
# 2. Invoice with Nulls
# 3. Invoice with Bad Date Format
INVOICES = [
    {
        "id": "inv_001",
        "invoiceNumber": "INV-2023-001",
        "totalAmount": 1500.00,
        "date": "2023-10-05",
        "status": "PAID"
    },
    {
        "id": "inv_002",
        "invoiceNumber": "INV-2023-002",
        "totalAmount": None,
        "date": "2023-10-06",
        "status": "PENDING"
    },
    {
        "id": "inv_003",
        "invoiceNumber": "INV-2023-003",
        "totalAmount": 200.50,
        "date": "07-10-2023",
        "status": "DRAFT"
    },
    {
        "id": "inv_004",
        "invoiceNumber": "INV-2023-004",
        "totalAmount": 3200.00,
        "date": "2023-10-08",
        "status": "PAID"
    },
    {
        "id": "inv_005",
        "invoiceNumber": "INV-2023-005",
        "totalAmount": 1000,
        "date": "10/09/2023",
        "status": "PENDING"
    },
    {
        "id": "inv_006",
        "invoiceNumber": "INV-2023-006",
        "totalAmount": 850.75,
        "date": "2023-10-10",
        "status": "PAID"
    },
    {
        "id": "inv_007",
        "invoiceNumber": "INV-2023-007",
        "totalAmount": 0,
        "date": "2023-10-11",
        "status": "DRAFT"
    },
    {
        "id": "inv_008",
        "invoiceNumber": "INV-2023-008",
        "totalAmount": 1200.00,
        "date": "12-10-2023",
        "status": "PENDING"
    },
    {
        "id": "inv_009",
        "invoiceNumber": "INV-2023-009",
        "totalAmount": 1250.00,
        "date": "2023-10-13",
        "status": "CANCELLED"
    },
    {
        "id": "inv_010",
        "invoiceNumber": "INV-2023-010",
        "totalAmount": 5500.00,
        "date": "2023-10-14",
        "status": "PAID"
    }
]
