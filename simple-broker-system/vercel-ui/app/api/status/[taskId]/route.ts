import { NextResponse } from 'next/server';

const BROKER_URL = process.env.BROKER_URL || 'http://localhost:8080';

export async function GET(
  request: Request,
  { params }: { params: { taskId: string } }
) {
  try {
    const response = await fetch(`${BROKER_URL}/api/status/${params.taskId}`);
    const data = await response.json();
    return NextResponse.json(data);
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to get status' },
      { status: 500 }
    );
  }
}
