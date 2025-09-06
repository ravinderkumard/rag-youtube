# YouTube Transcript Q&A

This project reads transcripts from YouTube videos using their **video ID**, generates **embeddings**, stores them in a **file-based vector store**, and allows users to **ask questions** about the video content.  
The entire application is containerized and can be run easily using **Docker Compose**.

---

## Features
- Fetches transcripts directly from YouTube using a video ID.
- Creates embeddings from transcripts for semantic search.
- Stores embeddings in a **file-based vector store** for persistence.
- Provides a simple **Q&A interface** for querying video content.
- Fully containerized with **Docker Compose** for easy deployment.

---
## Features
Composed of 2 project:

1. Backend(Python, FAST API)
2. Frontend(NextJS)

---
## Prerequisites
- [Docker](https://www.docker.com/get-started) installed on your system  
- [Docker Compose](https://docs.docker.com/compose/) installed  

---

## Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
```

## Configure Environment Variables
OPENAI_API_KEY=your_openai_key_here

## Build and Run with Docker Compose
docker-compose up --build


## Demo
1. Launch Page: http://localhost:3000/
   <img width="593" height="285" alt="image" src="https://github.com/user-attachments/assets/c71270cc-ed70-4147-b0ef-960533a81e38" />

