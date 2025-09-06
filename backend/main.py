from fastapi import FastAPI
from rag_pipeline import index_youtube_transcript, query_video
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or specify ["http://localhost:3000"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def health():
    return {"status": "ok"}

@app.post("/index")
def index(video_id: str):
    return index_youtube_transcript(video_id)

@app.post("/query")
def query(question: str):
    return query_video(question)
