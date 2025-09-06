import { NextResponse } from "next/server";

export async function POST(req: Request) {
  const { searchParams } = new URL(req.url);
  const question = searchParams.get("question");

  if (!question) {
    return NextResponse.json({ error: "Missing question" }, { status: 400 });
  }

  try {
    const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/query?question=${question}`, {
      method: "POST",
    });

    const data = await res.json();
    return NextResponse.json(data);
  } catch (err) {
    return NextResponse.json({ error: "Backend error" }, { status: 500 });
  }
}
