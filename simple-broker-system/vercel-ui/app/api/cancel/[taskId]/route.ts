import { NextResponse } from 'next/server';

const BROKER_URL = process.env.BROKER_URL || 'http://localhost:8080';

export async function POST(
  request: Request,
  { params }: { params: { taskId: string } }
) {
  try {
    const response = await fetch(`${BROKER_URL}/api/cancel/${params.taskId}`, {
      method: 'POST'
    });
    const data = await response.json();
    return NextResponse.json(data);
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to cancel task' },
      { status: 500 }
    );
  }
}
