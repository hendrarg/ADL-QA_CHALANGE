import uvicorn

if __name__ == "__main__":
    print ("start")
    uvicorn.run("app.server:app", host="localhost", port=8010, reload=True, log_level="debug")
