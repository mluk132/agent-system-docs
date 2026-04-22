import { NextResponse } from 'next/server';

const BROKER_URL = process.env.BROKER_URL || 'http://localhost:8080';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    
    const response = await fetch(`${BROKER_URL}/api/submit`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    });
    
    const data = await response.json();
    return NextResponse.json(data);
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to submit task' },
      { status: 500 }
    );
  }
}
