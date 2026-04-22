import { NextResponse } from 'next/server';

const BROKER_URL = process.env.BROKER_URL || 'http://localhost:8080';

export async function GET() {
  try {
    const response = await fetch(`${BROKER_URL}/api/health`);
    const data = await response.json();
    return NextResponse.json(data);
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to get health' },
      { status: 500 }
    );
  }
}
