import uvicorn

if __name__ == "__main__":
    print ("start")
    uvicorn.run("app.server:app", host="0.0.0.0", port=8010, reload=True, log_level="debug")
