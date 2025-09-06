import { NextResponse } from "next/server";

export async function POST(req: Request) {
  const { searchParams } = new URL(req.url);
  const video_id = searchParams.get("video_id");

  if (!video_id) {
    return NextResponse.json({ error: "Missing video_id" }, { status: 400 });
  }

  try {
    const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/index?video_id=${video_id}`, {
      method: "POST",
    });

    const data = await res.json();
    return NextResponse.json(data);
  } catch (err) {
    return NextResponse.json({ error: "Backend error" }, { status: 500 });
  }
}
