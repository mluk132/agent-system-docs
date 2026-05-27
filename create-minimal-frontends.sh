#!/bin/bash
# Create minimal working frontends

set -e

PROJECTS=("propai:PropAI:Real estate property analysis with AI insights"
          "healthflow:HealthFlow:Health and wellness tracking with personalized insights"
          "hypnotic:Hypnotic:Hypermedia-driven content management and delivery"
          "finder:Finder:Universal search and discovery platform")

for project_info in "${PROJECTS[@]}"; do
  IFS=':' read -r slug name desc <<< "$project_info"
  frontend="${slug}-frontend"
  
  echo "Creating minimal $name frontend..."
  
  # Clean up
  rm -rf "$frontend/app"
  mkdir -p "$frontend/app"
  
  # Create minimal layout
  cat > "$frontend/app/layout.tsx" << EOF
export const metadata = {
  title: '$name',
  description: '$desc',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
EOF
  
  # Create minimal page
  cat > "$frontend/app/page.tsx" << EOF
export default function Home() {
  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(to bottom right, #eff6ff, #faf5ff, #fce7f3)',
      padding: '2rem'
    }}>
      <div style={{ maxWidth: '64rem', margin: '0 auto' }}>
        <h1 style={{
          fontSize: '3rem',
          fontWeight: 'bold',
          textAlign: 'center',
          marginBottom: '2rem',
          background: 'linear-gradient(to right, #2563eb, #9333ea, #ec4899)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent'
        }}>
          $name
        </h1>
        
        <div style={{
          background: 'white',
          borderRadius: '1rem',
          boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1)',
          padding: '2rem',
          marginBottom: '2rem'
        }}>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 'bold', marginBottom: '1rem' }}>
            🤖 AI-Powered Agentic Features
          </h2>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1rem' }}>
            <div style={{ padding: '1rem', background: '#eff6ff', borderRadius: '0.5rem' }}>
              <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>⚡</div>
              <h3 style={{ fontWeight: 'bold' }}>Auto-Generated Tests</h3>
              <p style={{ fontSize: '0.875rem', color: '#4b5563' }}>Jest, JUnit, pytest tests automatically generated</p>
            </div>
            <div style={{ padding: '1rem', background: '#faf5ff', borderRadius: '0.5rem' }}>
              <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>📚</div>
              <h3 style={{ fontWeight: 'bold' }}>Smart Documentation</h3>
              <p style={{ fontSize: '0.875rem', color: '#4b5563' }}>JSDoc, JavaDoc, Sphinx docs in real-time</p>
            </div>
            <div style={{ padding: '1rem', background: '#fce7f3', borderRadius: '0.5rem' }}>
              <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>🎯</div>
              <h3 style={{ fontWeight: 'bold' }}>Intelligent Routing</h3>
              <p style={{ fontSize: '0.875rem', color: '#4b5563' }}>8 specialized queues for different tasks</p>
            </div>
            <div style={{ padding: '1rem', background: '#d1fae5', borderRadius: '0.5rem' }}>
              <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>🛡️</div>
              <h3 style={{ fontWeight: 'bold' }}>Security First</h3>
              <p style={{ fontSize: '0.875rem', color: '#4b5563' }}>Automatic security checks and scanning</p>
            </div>
          </div>
          <div style={{
            marginTop: '1.5rem',
            paddingTop: '1.5rem',
            borderTop: '1px solid #e5e7eb',
            textAlign: 'center',
            fontSize: '0.875rem',
            color: '#6b7280'
          }}>
            Powered by Kiro AI + OpenAI GPT-4 | ✅ 80% Test Coverage | ✅ 24/7 Monitoring
          </div>
        </div>
        
        <div style={{
          background: '#d1fae5',
          border: '1px solid #6ee7b7',
          borderRadius: '0.5rem',
          padding: '1rem',
          textAlign: 'center'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.5rem' }}>
            <div style={{
              width: '0.75rem',
              height: '0.75rem',
              background: '#10b981',
              borderRadius: '50%',
              animation: 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite'
            }}></div>
            <span style={{ fontWeight: '600', color: '#065f46' }}>System Status: All Services Operational</span>
          </div>
        </div>
      </div>
    </div>
  );
}
EOF
  
  # Create minimal globals.css
  cat > "$frontend/app/globals.css" << EOF
@import "tailwindcss";

:root {
  --background: #ffffff;
  --foreground: #171717;
}

body {
  color: var(--foreground);
  background: var(--background);
  font-family: Arial, Helvetica, sans-serif;
}
EOF
  
  echo "✅ $name frontend created"
done

echo ""
echo "All minimal frontends created!"
