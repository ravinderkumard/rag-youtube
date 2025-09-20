"use client";

import { useState } from "react";
import axios from "axios";

export default function QueryForm() {
  const [videoId, setVideoId] = useState("");
  const [question, setQuestion] = useState("");
  const [answer, setAnswer] = useState("");
  const [loading, setLoading] = useState(false);

  // Read backend URL from environment variable
  const backendUrl = process.env.NEXT_PUBLIC_API_URL || "http://backend:18000";

  const handleIndex = async () => {
    setLoading(true);
    try {
      await axios.post(`${backendUrl}/api/index`, null, {
        params: { video_id: videoId },
      });
      alert("Video indexed successfully!");
    } catch (err) {
      console.error(err);
      alert("Error indexing video");
    }
    setLoading(false);
  };

  const handleQuery = async () => {
    setLoading(true);
    try {
      const res = await axios.post(`${backendUrl}/api/query`, null, {
        params: { question },
      });
      setAnswer(res.data.answer);
    } catch (err) {
      console.error(err);
      alert("Error querying video");
    }
    setLoading(false);
  };

  return (
    <div className="max-w-xl mx-auto mt-10 p-4 border rounded-lg shadow">
      <h1 className="text-xl font-bold mb-4">YouTube RAG Chat</h1>
      
      <input
        type="text"
        placeholder="Enter YouTube Video ID"
        className="border p-2 w-full mb-2"
        value={videoId}
        onChange={(e) => setVideoId(e.target.value)}
      />
      <button
        className="bg-blue-500 text-white px-4 py-2 rounded mb-4 w-full"
        onClick={handleIndex}
        disabled={loading}
      >
        Index Video
      </button>

      <input
        type="text"
        placeholder="Ask a question"
        className="border p-2 w-full mb-2"
        value={question}
        onChange={(e) => setQuestion(e.target.value)}
      />
      <button
        className="bg-green-500 text-white px-4 py-2 rounded w-full"
        onClick={handleQuery}
        disabled={loading}
      >
        Ask Question
      </button>

      {answer && (
        <div className="mt-4 p-3 border rounded bg-gray-100">
          <h2 className="font-bold">Answer:</h2>
          <p>{answer}</p>
        </div>
      )}
    </div>
  );
}
