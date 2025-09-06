import os
from youtube_transcript_api import YouTubeTranscriptApi, TranscriptsDisabled
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_community.vectorstores import FAISS
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from dotenv import load_dotenv

load_dotenv()

EMBED_MODEL = "text-embedding-ada-002"
LLM_MODEL = "gpt-4"
INDEX_PATH = "faiss_index"

# Shared FAISS retriever
vector_store = None
retriever = None


def index_youtube_transcript(video_id: str):
    global vector_store, retriever

    try:
        transcript_list = YouTubeTranscriptApi().fetch(video_id=video_id, languages=['en'])
        transcript = " ".join(snippet.text for snippet in transcript_list.snippets)
    except TranscriptsDisabled:
        return {"error": "Transcript is disabled for this video."}

    # Split into chunks
    splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
    chunks = splitter.create_documents([transcript])

    # Embed + FAISS
    embeddings = OpenAIEmbeddings(model=EMBED_MODEL)
    vector_store = FAISS.from_documents(chunks, embeddings)
    retriever = vector_store.as_retriever(search_type="similarity", search_kwargs={"k": 4})

    # Save FAISS index
    vector_store.save_local(INDEX_PATH)

    return {"status": "indexed", "chunks": len(chunks)}


def query_video(question: str):
    global vector_store, retriever
    if vector_store is None or retriever is None:
        # Load existing FAISS index if available
        if os.path.exists(INDEX_PATH):
            embeddings = OpenAIEmbeddings(model=EMBED_MODEL)
            vector_store = FAISS.load_local(INDEX_PATH, embeddings, allow_dangerous_deserialization=True)
            retriever = vector_store.as_retriever(search_type="similarity", search_kwargs={"k": 4})
        else:
            return {"error": "No video indexed yet."}

    docs = retriever.get_relevant_documents(question)
    context = "\n\n".join([doc.page_content for doc in docs])

    prompt = PromptTemplate(
        template="""You are a helpful assistant.  
Answer ONLY from the provided transcript context.  
If the answer is not found, say "I don't know".  

Context: {context}  
Question: {question}""",
        input_variables=["context", "question"]
    )

    llm = ChatOpenAI(temperature=0, model_name=LLM_MODEL)
    parser = StrOutputParser()

    final_prompt = prompt.format(context=context, question=question)
    #answer = parser.parse(llm.invoke(final_prompt))
    response = llm.invoke(final_prompt)
    answer_text = response.content if hasattr(response, 'content') else str(response)


    return {"question": question, "answer": answer_text}
